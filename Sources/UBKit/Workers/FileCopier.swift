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
    private lazy var shell = Shell()
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

    func copyFiles() -> Result {
        let parseProjectResult = parseProjectFile()
        guard parseProjectResult == .success else {
            return parseProjectResult
        }

//        print("Preparing Build Phase")
        let frameworkPhaseResult = addFrameworksBuildPhase()
        guard frameworkPhaseResult == .success else {
            return frameworkPhaseResult
        }

//        print("Saving Xcode project")
        let saveResult = saveProject()
        guard saveResult == .success else {
            return saveResult
        }

//        print("Changing Unity Files")
        let changeFilesResult = changeUnityFiles()
        guard changeFilesResult == .success else {
            return changeFilesResult
        }

//        print("Adding Unity Files")
        let unityFilesResult = addUnityFiles()
        guard unityFilesResult == .success else {
            return unityFilesResult
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

    func addFrameworksBuildPhase() -> Result {
        guard let project = project else {
            return .failure(UBKitError.invalidXcodeProject("Failed to find project file"))
        }

        guard let mainTarget = project.pbxproj.nativeTargets.filter({ $0.name == config.iOS.projectName }).first else {
            return .failure(UBKitError.invalidXcodeProject("Missing main target"))
        }

        let frameworksBuildPhase = PBXFrameworksBuildPhase(reference: generateUUID(PBXFrameworksBuildPhase.self,
                                                                                   "frameworks".appending(nameSalt)))
        mainTarget.buildPhases.append(frameworksBuildPhase.reference)
        project.pbxproj.addObject(frameworksBuildPhase)

        return .success
    }

    func changeUnityFiles() -> Result {
        let mainFilePath = workingPath.appending(config.unity.projectName).appending("/ios_build/Classes/main.mm")
        guard fileManager.fileExists(atPath: mainFilePath) else {
            return .failure(UBKitError.missingUnityFile("main.mm"))
        }
        let changeInitResult = changeUnityInitMethod(pathString: mainFilePath)
        guard changeInitResult == .success else {
            return changeInitResult
        }

        let appControllerFilePath = workingPath.appending(config.unity.projectName).appending("/ios_build/Classes/UnityAppController.h")
        guard fileManager.fileExists(atPath: appControllerFilePath) else {
            return .failure(UBKitError.missingUnityFile("UnityAppController.h"))
        }
        let changeAppControllerResult = changeUnityAppControllerMethod(pathString: appControllerFilePath)
        guard changeAppControllerResult == .success else {
            return changeAppControllerResult
        }

        let metalHelperFilePath = workingPath.appending(config.unity.projectName).appending("/ios_build/Classes/Unity/MetalHelper.mm")
        guard fileManager.fileExists(atPath: metalHelperFilePath) else {
            return .failure(UBKitError.missingUnityFile("MetalHelper.mm"))
        }
        let changeMetalResult = changeUnityMetalHelper(pathString: metalHelperFilePath)
        guard changeMetalResult == .success else {
            return changeMetalResult
        }
        return .success
    }

    func addUnityFiles() -> Result {
        let semaphore = DispatchSemaphore(value: 0)
        var statusCode: Int32 = 999

        shell.perform(
            config.unity.applicationPath,
            UnityCommandLine.Arguments.batchmode,
            UnityCommandLine.Arguments.buildPath,
            workingPath.appending(config.unity.projectName).appending("/ios_build"),
            UnityCommandLine.Arguments.executeMethod,
            UnityCommandLine.refreshAction,
            UnityCommandLine.Arguments.quit,
            terminationHandler: { (process) in
                statusCode = process.terminationStatus
                semaphore.signal()
        })

        let timeout = semaphore.wait(timeout: DispatchTime.now()+60.0)
        switch timeout {
        case .success:
            if statusCode == 0 {
                return .success
            } else {
                return .failure(UBKitError.shellCommand("Adding files to  Unity project"))
            }
        case .timedOut:
            return .failure(UBKitError.waitTimedOut)
        }
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

    func changeUnityInitMethod(pathString: String) -> Result {
        do {
            let fileString = try String(contentsOfFile: pathString)
            let unityString = "int main(int argc, char* argv[])"
            let replacementString = "int main_unity_default(int argc, char* argv[])"
            let newFileString = fileString.replacingOccurrences(of: unityString, with: replacementString)

            try newFileString.data(using: .utf8)?.write(to: URL(fileURLWithPath: pathString))
        } catch {
            return .failure(UBKitError.missingUnityFile("main.mm"))
        }

        return .success
    }

    func changeUnityAppControllerMethod(pathString: String) -> Result {
        do {
            let fileString = try String(contentsOfFile: pathString)
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
            try newFileString.data(using: .utf8)?.write(to: URL(fileURLWithPath: pathString))
        } catch {
            return .failure(UBKitError.missingUnityFile("UnityAppController.h"))
        }

        return .success
    }

    func changeUnityMetalHelper(pathString: String) -> Result {
        do {
            let fileString = try String(contentsOfFile: pathString)
            let unityString = "surface->stencilRB = [surface->device newTextureWithDescriptor: stencilTexDesc];"
            let replacementString = "stencilTexDesc.usage |= MTLTextureUsageRenderTarget;\n    surface->stencilRB = [surface->device newTextureWithDescriptor: stencilTexDesc];"
            let newFileString = fileString.replacingOccurrences(of: unityString, with: replacementString)
            try newFileString.data(using: .utf8)?.write(to: URL(fileURLWithPath: pathString))
        } catch {
            return .failure(UBKitError.missingUnityFile("MetalHelper.mm"))
        }

        return .success
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
        let classAcronym = className.filter({ String($0).lowercased() != String($0) })
        let stringID = String(abs(id.hashValue).description.prefix(10 - classAcronym.utf8.count))
        repeat {
            counter += 1
            uuid = "\(classAcronym)\(stringID)\(String(format: "%02d", counter))"
        } while (uuids.contains(uuid))
        uuids.insert(uuid)
        return uuid
    }
}
