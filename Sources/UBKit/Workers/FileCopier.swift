//
//  FileCopier.swift
//
//  Copyright (c) 2017 Handsome
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import xcproj
import PathKit

class FileCopier {

    struct SourceFile {
        let path: Path
        let fileReference: String
        let buildFile: PBXBuildFile
    }

    private let config: Config
    private let workingPath: String
    private let xcodeProjectPath: String
    private let xcodeProjectFilePath: String

    private lazy var fileManager = FileManager.default
    private lazy var nameSalt = "x1y2z3"
    private var uuids: Set<String> = []
    private var fileReferencesByPath: [Path: String] = [:]
    private var project: XcodeProj?
    private var classesGroup: PBXGroup?
    private var libsGroup: PBXGroup?

    init(config: Config) {
        self.config = config
        self.workingPath = config.unity.projectPath
        self.xcodeProjectPath = config.iOS.projectPath
        self.xcodeProjectFilePath = String(format: "%@%@%@", xcodeProjectPath, config.iOS.projectName, ".xcodeproj")
    }

    func copyFiles(refresh: Bool) -> Result {
        let parseProjectResult = parseProjectFile()
        guard parseProjectResult == .success else {
            return parseProjectResult
        }

        if refresh {
            let deleteFilesResult = deleteUnityFiles()
            guard deleteFilesResult == .success else {
                return deleteFilesResult
            }
        } else {
            let addBridgeFilesResult = addUnityBridgingFiles()
            guard addBridgeFilesResult == .success else {
                return addBridgeFilesResult
            }
        }

        let createGroupsResult = createUnityFileGroups()
        guard createGroupsResult == .success else {
            return createGroupsResult
        }

        print("Adding Unity files to Xcode project")
        let classesPath = workingPath.appending(config.unity.relativeClassesPath)
        guard let classesGroup = classesGroup else {
            return .failure(UBKitError.invalidUnityProject)
        }
        let addClassesFilesResult = addFiles(workingPath: classesPath, parentGroup: classesGroup)
        guard addClassesFilesResult == .success else {
            return addClassesFilesResult
        }

        let librariesPath = workingPath.appending(config.unity.relativeLibrariesPath)
        guard let libsGroup = libsGroup else {
            return .failure(UBKitError.invalidUnityProject)
        }
        let addLibrariesFilesResult = addFiles(workingPath: librariesPath, parentGroup: libsGroup)
        guard addLibrariesFilesResult == .success else {
            return addLibrariesFilesResult
        }

        let copyDataResult = copyUnityDataFolder()
        guard copyDataResult == .success else {
            return copyDataResult
        }

        print("Saving Xcode project")
        let saveResult = saveProject()
        guard saveResult == .success else {
            return saveResult
        }

        return .success
    }
}

private extension FileCopier {

    func parseProjectFile() -> Result {
        let projectPath = Path(xcodeProjectFilePath)
        do {
            project = try XcodeProj(path: projectPath)
            return .success
        } catch {
            return .failure(error)
        }
    }

    func addUnityBridgingFiles() -> Result {
        guard let project = project else {
            return .failure(UBKitError.invalidXcodeProject("Failed to find project file"))
        }

        let sourceBuildPhases = project.pbxproj.sourcesBuildPhases
        guard sourceBuildPhases.count == 1, let sourceBuildPhase = sourceBuildPhases.first else {
            return .failure(UBKitError.invalidXcodeProject("Missing sources build phase"))
        }

        guard let targetGroup = project.pbxproj.groups.filter({ $0.path == config.iOS.projectName }).first else {
            return .failure(UBKitError.missingGroup(config.iOS.projectName))
        }

        do {
            let pathStrings = try fileManager.contentsOfDirectory(atPath: xcodeProjectPath)
            for pathString in pathStrings {
                let path = Path("../".appending(pathString))
                if (getBuildPhaseForPath(path) == .sources || getBuildPhaseForPath(path) == .headers) &&
                    pathString.hasPrefix("Unity") {
                    guard let source = generateSourceFile(path: path, in: targetGroup, name: pathString) else {
                        return .failure(UBKitError.unableToCreateFile(path.string))
                    }

                    targetGroup.children.append(source.fileReference)
                    if getBuildPhaseForPath(path) == .sources {
                        sourceBuildPhase.files.append(source.buildFile.reference)
                    }
                    project.pbxproj.addObject(source.buildFile)
                }
            }
        } catch {
            return .failure(UBKitError.error(error))
        }

        return .success
    }

    func deleteUnityFiles() -> Result {
        guard let project = project else {
            return .failure(UBKitError.invalidXcodeProject(""))
        }

        guard let ubkGroup = project.pbxproj.groups.filter({
            $0.path == "UBK"
        }).first else {
            return .failure(UBKitError.invalidXcodeProject("Missing Vendor/UBK/ folder"))
        }

        guard let frameworksBuildPhase = project.pbxproj.frameworksBuildPhases.first else {
            return .failure(UBKitError.invalidXcodeProject("Missing frameworks build phase"))
        }

        guard let sourcesBuildPhase = project.pbxproj.sourcesBuildPhases.first else {
            return .failure(UBKitError.invalidXcodeProject("Missing sources build phase"))
        }

        guard let resourcesBuildPhase = project.pbxproj.resourcesBuildPhases.first else {
            return .failure(UBKitError.invalidXcodeProject("Missing resources build phase"))
        }

        func removeFile(reference: String) {
            if let (buildFile, index) = buildFileIndex(for: reference, in: project.pbxproj) {
                if let idx = frameworksBuildPhase.files.index(of: buildFile.reference) {
                    frameworksBuildPhase.files.remove(at: idx)
                }

                if let idx = sourcesBuildPhase.files.index(of: buildFile.reference) {
                    sourcesBuildPhase.files.remove(at: idx)
                }

                if let idx = resourcesBuildPhase.files.index(of: buildFile.reference) {
                    resourcesBuildPhase.files.remove(at: idx)
                }

                project.pbxproj.buildFiles.remove(at: index)
            }

            if let index = fileReferenceIndex(for: reference, in: project.pbxproj) {
                project.pbxproj.fileReferences.remove(at: index)
            }
        }

        func removeGroup(reference: String) {
            if let group = project.pbxproj.groups.filter({ $0.reference == reference }).first {
                for ref in group.children {
                    var handled = false
                    for group in project.pbxproj.groups where group.reference == ref {
                        removeGroup(reference: ref)
                        handled = true
                        break
                    }
                    if !handled {
                        removeFile(reference: ref)
                    }
                }

                if let index = project.pbxproj.groups.index(of: group) {
                    project.pbxproj.groups.remove(at: index)
                }
            }
        }

        for folderRef in ubkGroup.children {
            var handled = false
            for group in project.pbxproj.groups where group.reference == folderRef {
                removeGroup(reference: folderRef)
                handled = true
                break
            }
            if !handled {
                removeFile(reference: folderRef)
            }
        }

        ubkGroup.children.removeAll()

        return .success
    }

    func createUnityFileGroups() -> Result {
        guard let project = project else {
            return .failure(UBKitError.invalidXcodeProject("Failed to find project file"))
        }

        guard let unityGroup = project.pbxproj.groups.filter({ $0.path == "UBK" }).first else {
            return .failure(UBKitError.invalidXcodeProject("Missing Vendor/UBK/ folder"))
        }

        if let classesGroup = generateGroup("Classes", sourceTree: .absolute) {
            classesGroup.path = workingPath.appending(config.unity.relativeClassesPath)
            project.pbxproj.addObject(classesGroup)
            self.classesGroup = classesGroup
            unityGroup.children.append(classesGroup.reference)
        }

        if let librariesGroup = generateGroup("Libraries", sourceTree: .absolute) {
            librariesGroup.path = workingPath.appending(config.unity.relativeLibrariesPath)
            project.pbxproj.addObject(librariesGroup)
            self.libsGroup = librariesGroup
            unityGroup.children.append(librariesGroup.reference)
        }

        return .success
    }

    func generateGroup(_ name: String, sourceTree: PBXSourceTree = .group) -> PBXGroup? {
        let saltedName = name.appending(nameSalt)
        let group = PBXGroup(reference: generateUUID(PBXGroup.self, saltedName), children: [], sourceTree: sourceTree)
        group.name = name

        return group
    }

    func buildFileIndex(for fileRef: String, in proj: PBXProj) -> (PBXBuildFile, Int)? {
        for (index, buildFile) in proj.buildFiles.enumerated() {
            if buildFile.fileRef == fileRef {
                return (buildFile, index)
            }
        }

        return nil
    }

    func fileReferenceIndex(for fileRef: String, in proj: PBXProj) -> Int? {
        var index: Int?
        for (idx, ref) in proj.fileReferences.enumerated() {
            if ref.reference == fileRef {
                index = idx
                break
            }
        }
        return index
    }

    @discardableResult
    func addFiles(workingPath: String, parentGroup: PBXGroup) -> Result {
        guard let project = project else {
            return .failure(UBKitError.invalidXcodeProject("Failed to find project file"))
        }

        let sourceBuildPhases = project.pbxproj.sourcesBuildPhases
        guard sourceBuildPhases.count == 1, let sourceBuildPhase = sourceBuildPhases.first else {
            return .failure(UBKitError.invalidXcodeProject("Missing sources build phase"))
        }

        guard let mainTarget = project.pbxproj.nativeTargets.filter({ $0.name == config.iOS.projectName }).first else {
            return .failure(UBKitError.invalidXcodeProject("Missing main target"))
        }

        let frameworksBuildPhase: PBXFrameworksBuildPhase
        if project.pbxproj.frameworksBuildPhases.count > 0 {
            frameworksBuildPhase = project.pbxproj.frameworksBuildPhases.first!
            if !mainTarget.buildPhases.contains(frameworksBuildPhase.reference) {
                mainTarget.buildPhases.append(frameworksBuildPhase.reference)
            }
        } else {
            frameworksBuildPhase = PBXFrameworksBuildPhase(reference: generateUUID(PBXFrameworksBuildPhase.self,
                                                                                   "frameworks".appending(nameSalt)))
            if parentGroup.name == "Libraries" {
                mainTarget.buildPhases.append(frameworksBuildPhase.reference)
            }
            project.pbxproj.addObject(frameworksBuildPhase)
        }

        @discardableResult
        func add(toPath: String, parentGroup: PBXGroup) -> Result {
            do {
                let pathStrings = try fileManager.contentsOfDirectory(atPath: toPath)
                for pathString in pathStrings {
                    guard shouldHandlePathString(pathString) else {
                        continue
                    }

                    let path = Path(pathString)
                    if getBuildPhaseForPath(path) == nil {
                        guard let group = generateGroup(path.string) else {
                            return .failure(UBKitError.unableToCreateXcodeProjectGroup(path.string))
                        }
                        group.path = path.string
                        parentGroup.children.append(group.reference)
                        project.pbxproj.addObject(group)

                        let result = add(toPath: String(format: "%@%@/", workingPath, path.string), parentGroup: group)
                        if result != .success {
                            return result
                        }
                    } else if getBuildPhaseForPath(path) == .resources {
                        guard let source = generateSourceFile(path: path, in: parentGroup, name: path.string) else {
                            return .failure(UBKitError.unableToCreateFile(path.string))
                        }
                        parentGroup.children.append(source.fileReference)
                        frameworksBuildPhase.files.append(source.buildFile.reference)
                        project.pbxproj.addObject(source.buildFile)
                    } else {
                        if parentGroup.name == "Classes" {
                            if path.string == "main.mm" {
                                changeUnityInitMethod(pathString: path.string, groupPathString: parentGroup.path)
                            } else if path.string == "UnityAppController.h" {
                                changeUnityAppControllerMethod(pathString: path.string, groupPathString: parentGroup.path)
                            }
                        }

                        guard let source = generateSourceFile(path: path, in: parentGroup, name: path.string) else {
                            return .failure(UBKitError.unableToCreateFile(path.string))
                        }

                        parentGroup.children.append(source.fileReference)
                        if getBuildPhaseForPath(path) == .sources {
                            sourceBuildPhase.files.append(source.buildFile.reference)
                        }
                        project.pbxproj.addObject(source.buildFile)
                    }
                }
                return .success
            } catch {
                return .failure(UBKitError.error(error))
            }
        }
        return add(toPath: workingPath, parentGroup: parentGroup)
    }

    func copyUnityDataFolder() -> Result {
        guard let project = project else {
            return .failure(UBKitError.invalidXcodeProject("Failed to find project file"))
        }

        guard let unityGroup = project.pbxproj.groups.filter({ $0.path == "UBK" }).first else {
            return .failure(UBKitError.invalidXcodeProject("Missing Vendor/UBK/ folder"))
        }

        let resourcesBuildPhases = project.pbxproj.resourcesBuildPhases
        guard resourcesBuildPhases.count == 1, let resourcesBuildPhase = resourcesBuildPhases.first else {
            return .failure(UBKitError.invalidXcodeProject("Missing resources build phase"))
        }

        let fileReference = PBXFileReference(reference: generateUUID(PBXFileReference.self, "data".appending(nameSalt)),
                                                                sourceTree: .absolute)
        fileReference.name = "Data"
        fileReference.path = workingPath.appending(config.unity.relativeDataPath)
        fileReference.lastKnownFileType = "folder"
        unityGroup.children.append(fileReference.reference)
        project.pbxproj.addObject(fileReference)

        let buildFile = PBXBuildFile(reference: generateUUID(PBXBuildFile.self, "data".appending(nameSalt)),
                                     fileRef: fileReference.reference)
        project.pbxproj.addObject(buildFile)
        resourcesBuildPhase.files.append(buildFile.reference)

        return .success
    }

    func saveProject() -> Result {
        guard let project = project else {
            return .failure(UBKitError.invalidXcodeProject("Failed to find project file"))
        }

        let projectPath = Path(xcodeProjectFilePath)
        do {
            try project.write(path: projectPath)
            return .success
        } catch {
            return .failure(UBKitError.unableToSaveXcodeProject)
        }
    }

    func shouldHandlePathString(_ pathString: String) -> Bool {
        let dsStore = pathString != ".DS_Store"
        let libil2cpp = pathString != "libil2cpp"

        return dsStore && libil2cpp
    }

    func changeUnityInitMethod(pathString: String, groupPathString: String?) {
        guard let groupPathString = groupPathString else {
            return
        }

        do {
            let filePathString = groupPathString.appending("/").appending(pathString)
            let fileString = try String(contentsOfFile: filePathString)
            let unityString = "int main(int argc, char* argv[])"
            let replacementString = "int main_unity_default(int argc, char* argv[])"
            let newFileString = fileString.replacingOccurrences(of: unityString, with: replacementString)

            try newFileString.data(using: .utf8)?.write(to: URL(fileURLWithPath: filePathString))
        } catch {
            print("FAILED TO READ FILE")
        }
    }

    func changeUnityAppControllerMethod(pathString: String, groupPathString: String?) {
        guard let groupPathString = groupPathString else {
            return
        }

        do {
            let filePathString = groupPathString.appending("/").appending(pathString)
            let fileString = try String(contentsOfFile: filePathString)
            let unityString = """
            inline UnityAppController*  GetAppController()
            {
                return (UnityAppController*)[UIApplication sharedApplication].delegate;
            }
            """
            let replacementString = """
            NS_INLINE UnityAppController* GetAppController()
            {
                NSObject<UIApplicationDelegate>* delegate = [UIApplication sharedApplication].delegate;
                UnityAppController* currentUnityController = (UnityAppController *)[delegate valueForKey:@"currentUnityController"];
                return currentUnityController;
            }
            """
            let newFileString = fileString.replacingOccurrences(of: unityString, with: replacementString)
            try newFileString.data(using: .utf8)?.write(to: URL(fileURLWithPath: filePathString))
        } catch {
            print("FAILED TO READ FILE")
        }
    }
}

/**
 The following private methods are credited to XcodeGenKit and
 are used with little to no modifications.
 */
private extension FileCopier {

    func generateUUID<T: PBXObject>(_ element: T.Type, _ id: String) -> String {
        var uuid: String = ""
        var counter: UInt = 0
        let className: String = String(describing: T.self).replacingOccurrences(of: "PBX", with: "")
        let classAcronym = String(className.characters.filter { String($0).lowercased() != String($0) })
        let stringID = String(abs(id.hashValue).description.characters.prefix(10 - classAcronym.characters.count))
        repeat {
            counter += 1
            uuid = "\(classAcronym)\(stringID)\(String(format: "%02d", counter))"
        } while (uuids.contains(uuid))
        uuids.insert(uuid)
        return uuid
    }

    func getFileReference(path: Path, inPath: Path, name: String? = nil) -> String? {
        guard let project = project else {
            return nil
        }

        let key = Path(inPath.string.appending("/").appending(path.string))
        if let fileReference = fileReferencesByPath[key] {
            return fileReference
        } else {
            let fileReference = PBXFileReference(reference: generateUUID(PBXFileReference.self, path.lastComponent),
                                                 sourceTree: .group,
                                                 path: path.byRemovingBase(path: inPath).string)
            fileReference.name = name
            project.pbxproj.addObject(fileReference)
            fileReferencesByPath[key] = fileReference.reference
            return fileReference.reference
        }
    }
    
    func getBuildPhaseForPath(_ path: Path) -> BuildPhase? {
        if path.lastComponent == "Info.plist" {
            return nil
        }
        if let fileExtension = path.extension {
            switch fileExtension {
            case "swift", "m", "cpp", "mm": return .sources
            case "h", "hh", "hpp", "ipp", "tpp", "hxx", "def", "pch": return .headers
            case "xcconfig": return nil
            default: return .resources
            }
        }
        return nil
    }

    func generateSourceFile(path: Path, in group: PBXGroup, name: String) -> SourceFile? {
        let referencePath = Path(xcodeProjectPath.appending(config.iOS.projectName).appending("/").appending(config.iOS.projectName))
        guard let fileReference = getFileReference(path: path, inPath: referencePath, name: name) else {
            return nil
        }

        var settings: [String: Any] = [:]
        if getBuildPhaseForPath(path) == .headers {
            settings["ATTRIBUTES"] = ["Public"]
        }
        let buildFile = PBXBuildFile(reference: generateUUID(PBXBuildFile.self, fileReference),
                                     fileRef: fileReference,
                                     settings: settings)
        let sourceFile = SourceFile(path: path, fileReference: fileReference, buildFile: buildFile)
        return sourceFile
    }
}

/**
 This Path extension is credited to XcodeGenKit
 */
extension Path {
    func byRemovingBase(path: Path) -> Path {
        return Path(normalize().string.replacingOccurrences(of: "\(path.normalize().string)/", with: ""))
    }
}
