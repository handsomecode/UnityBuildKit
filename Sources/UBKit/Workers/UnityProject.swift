//
//  UnityProject.swift
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

class UnityProject {

    private let config: Config
    private let workingPath: String
    private let projectName: String
    private let unitySceneNames: [String]

    private let fileManager = FileManager()
    private lazy var shell = Shell()
    private let unityAppPath: String

    init(config: Config) {
        self.config = config
        self.projectName = config.iOS.projectName
        self.workingPath = config.unity.projectPath
        self.unityAppPath = config.unity.applicationPath
        self.unitySceneNames = config.unity.sceneNames
    }

    func create() -> Result {
        guard UBKit.validatePath(unityAppPath, isDirectory: false) else {
            return .failure(UBKitError.invalidFolder(unityAppPath))
        }

        let unityFolderResult = createUnityFolder()
        guard unityFolderResult == .success else {
            return unityFolderResult
        }

        print("Generating Unity project")
        print("This may take some time to complete\n")
        let projectGenerationResult = generateUnityProject()
        guard projectGenerationResult == .success else {
            return projectGenerationResult
        }

        print("\nGenerating Unity Editor scripts")
        let editorScriptsResult = createUnityEditorScripts()
        guard editorScriptsResult == .success else {
            return editorScriptsResult
        }

        print("\n----------")
        print("⚙️  Initializing projects")
        print("----------")
        let initializationResult = runInitialProjectBuild()
        guard initializationResult == .success else {
            return initializationResult
        }

        return .success
    }
}

private extension UnityProject {

    func createUnityFolder() -> Result {
        do {
            try fileManager.createDirectory(
                atPath: workingPath,
                withIntermediateDirectories: false,
                attributes: nil)
        } catch {
            return .failure(error)
        }

        return .success
    }

    func generateUnityProject() -> Result {
        let semaphore = DispatchSemaphore(value: 0)
        let unityProjectPath = workingPath.appending(projectName)
        var statusCode: Int32 = 0

        shell.perform(
            unityAppPath,
            UnityCommandLine.Arguments.batchmode,
            UnityCommandLine.Arguments.createProject,
            unityProjectPath,
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
                return .failure(UBKitError.shellCommand("Generate Unity Project"))
            }
        case .timedOut:
            return .failure(UBKitError.waitTimedOut)
        }
    }

    func createUnityEditorScripts() -> Result {
        let assetsFilePath = workingPath.appending(projectName).appending("/Assets/")
        guard UBKit.validatePath(assetsFilePath, isDirectory: true) else {
            return .failure(UBKitError.invalidFolder(assetsFilePath))
        }
        let editorFilePath = assetsFilePath.appending("Editor/")
        let scenesFilePath = assetsFilePath.appending("Scenes/")

        do {
            try fileManager.createDirectory(atPath: editorFilePath, withIntermediateDirectories: false, attributes: nil)
            try fileManager.createDirectory(atPath: scenesFilePath, withIntermediateDirectories: false, attributes: nil)
        } catch {
            return .failure(error)
        }

        guard fileManager.createFile(
            atPath: editorFilePath.appending("iOSBuildScript.cs"),
            contents: File.unityBuildScriptFile(iOSProjectFolderPath: config.iOS.projectPath, iOSProjectName: projectName),
            attributes: nil) else {
                return .failure(UBKitError.unableToCreateFile("Unity iOS Build Script"))
        }

        guard fileManager.createFile(
            atPath: editorFilePath.appending("XcodeProjectRefresher.cs"),
            contents: File.unityProjectScriptFile(projectName: projectName, iOSProjectPath: config.iOS.projectPath),
            attributes: nil) else {
                return .failure(UBKitError.unableToCreateFile("Unity Project Script"))
        }

        guard fileManager.createFile(
            atPath: editorFilePath.appending("XcodeFrameworks.cs"),
            contents: File.unityFrameworksScriptFile(projectName: projectName, iOSProjectPath: config.iOS.projectPath),
            attributes: nil) else {
                return .failure(UBKitError.unableToCreateFile("Xcode Frameworks Script"))
        }

        return .success
    }

    func runInitialProjectBuild() -> Result {
        let semaphore = DispatchSemaphore(value: 0)
        var statusCode: Int32 = 999
        let projectPath = workingPath.appending(projectName)
        let outputLocation = projectPath.appending("/").appending("ios_build")

        // MARK: - Main
        print("Initializing Unity scene \(unitySceneNames[0]) for iOS...")
        print("This will take some time to complete\n")
        shell.perform(
            unityAppPath,
            UnityCommandLine.Arguments.batchmode,
            UnityCommandLine.Arguments.projectPath,
            projectPath,
            UnityCommandLine.Arguments.outputLocation,
            outputLocation,
            UnityCommandLine.Arguments.sceneName,
            unitySceneNames[0],
            UnityCommandLine.Arguments.executeMethod,
            UnityCommandLine.buildAction,
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
                return .failure(UBKitError.shellCommand("Initializing Unity Project"))
            }
        case .timedOut:
            return .failure(UBKitError.waitTimedOut)
        }
    }
}
