//
//  FileCopier.swift
//  UEKit
//
//  Created by Eric Miller on 10/13/17.
//

import Foundation
import xcproj
import PathKit

class FileCopier {

    struct SourceFile {
        let path: Path
        let fileReference: String
        let buildFile: PBXBuildFile
    }

    private let projectName: String
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

    init(projectName: String, workingPath: String, xcodeProjectPath: String) {
        self.projectName = projectName
        self.workingPath = workingPath
        self.xcodeProjectPath = xcodeProjectPath
        self.xcodeProjectFilePath = String(format: "%@%@%@", xcodeProjectPath, projectName, ".xcodeproj")
    }

    func copyFiles() -> Result {
        let parseProjectResult = parseProjectFile()
        guard parseProjectResult == .success else {
            return parseProjectResult
        }

        let addBridgeFilesResult = addUnityBridgingFiles()
        guard addBridgeFilesResult == .success else {
            return addBridgeFilesResult
        }

        let createGroupsResult = createUnityFileGroups()
        guard createGroupsResult == .success else {
            return createGroupsResult
        }

        print("Adding Unity files to Xcode project")
        let classesPath = workingPath.appending(projectName).appending("/ios_build/Classes/")
        guard let classesGroup = classesGroup else {
            return .failure(UBKitError.invalidUnityProject)
        }
        let addClassesFilesResult = addFiles(workingPath: classesPath, parentGroup: classesGroup)
        guard addClassesFilesResult == .success else {
            return addClassesFilesResult
        }

        let librariesPath = workingPath.appending(projectName).appending("/ios_build/Libraries/")
        guard let libsGroup = libsGroup else {
            return .failure(UBKitError.invalidUnityProject)
        }
        let addLibrariesFilesResult = addFiles(workingPath: librariesPath, parentGroup: libsGroup)
        guard addLibrariesFilesResult == .success else {
            return addLibrariesFilesResult
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
            print("Failure: \(error.localizedDescription)")
            return .failure(UBKitError.invalidXcodeProject)
        }
    }

    func addUnityBridgingFiles() -> Result {
        guard let project = project else {
            return .failure(UBKitError.invalidXcodeProject)
        }

        let sourceBuildPhases = project.pbxproj.sourcesBuildPhases
        guard sourceBuildPhases.count == 1, let sourceBuildPhase = sourceBuildPhases.first else {
            return .failure(UBKitError.invalidXcodeProject)
        }

        guard let targetGroup = project.pbxproj.groups.filter({ $0.path == projectName }).first else {
            return .failure(UBKitError.missingGroup(projectName))
        }

        do {
            let pathStrings = try fileManager.contentsOfDirectory(atPath: xcodeProjectPath)
            for pathString in pathStrings {
                let path = Path("../".appending(pathString))
                if (getBuildPhaseForPath(path) == .sources || getBuildPhaseForPath(path) == .headers) && pathString.hasPrefix("Unity") {
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

    func createUnityFileGroups() -> Result {
        guard let project = project else {
            return .failure(UBKitError.invalidXcodeProject)
        }

        guard let unityGroup = project.pbxproj.groups.filter({ $0.path == "Unity" }).first else {
            return .failure(UBKitError.invalidXcodeProject)
        }

        if let classesGroup = generateGroup("Classes", sourceTree: .absolute) {
            classesGroup.path = workingPath.appending(projectName).appending("/ios_build/Classes")
            project.pbxproj.addObject(classesGroup)
            self.classesGroup = classesGroup
            unityGroup.children.append(classesGroup.reference)
        }

        if let librariesGroup = generateGroup("Libraries", sourceTree: .absolute) {
            librariesGroup.path = workingPath.appending(projectName).appending("/ios_build/Libraries")
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

    @discardableResult
    func addFiles(workingPath: String, parentGroup: PBXGroup) -> Result {
        guard let project = project else {
            return .failure(UBKitError.invalidXcodeProject)
        }

        let sourceBuildPhases = project.pbxproj.sourcesBuildPhases
        guard sourceBuildPhases.count == 1, let sourceBuildPhase = sourceBuildPhases.first else {
            return .failure(UBKitError.invalidXcodeProject)
        }

        let frameworksBuildPhases = project.pbxproj.frameworksBuildPhases
        guard frameworksBuildPhases.count == 1, let frameworksBuildPhase = frameworksBuildPhases.first else {
            return .failure(UBKitError.invalidXcodeProject)
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
                            return .failure(UBKitError.unableToCreateXcodeProjectGroup)
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

    func saveProject() -> Result {
        guard let project = project else {
            return .failure(UBKitError.invalidXcodeProject)
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
        let referencePath = Path(xcodeProjectPath.appending(projectName).appending("/").appending(projectName))
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
