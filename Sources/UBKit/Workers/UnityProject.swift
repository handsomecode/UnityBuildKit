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

    /**
     A helper class for interacting with the Unity command line.
     */
    struct Unity {
        static let buildAction = "iOSBuilder.Perform"

        struct Arguments {
            static let projectPath = "-projectPath"
            static let createProject = "-createProject"
            static let outputLocation = "-outputLocation"
            static let sceneName = "-sceneName"
            static let executeMethod = "-executeMethod"
            static let batchmode = "-batchmode"
            static let quit = "-quit"
        }
    }

    private let workingPath: String
    private let projectName: String

    private let fileManager = FileManager()
    private lazy var shell = Shell()
    private let unityAppPath: String

    init(projectName: String, workingPath: String, unityAppPath: String) {
        self.projectName = projectName
        self.workingPath = workingPath

        self.unityAppPath = unityAppPath
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
        print("This will take some time to complete\n")
        let projectGenerationResult = generateUnityProject()
        guard projectGenerationResult == .success else {
            return projectGenerationResult
        }

        print("\nGenerating Unity Editor scripts")
        let editorScriptsResult = createUnityEditorScripts()
        guard editorScriptsResult == .success else {
            return editorScriptsResult
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
            Unity.Arguments.batchmode,
            Unity.Arguments.createProject,
            unityProjectPath,
            Unity.Arguments.quit,
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
            contents: File.unityBuildScriptFile(),
            attributes: nil) else {
            return .failure(UBKitError.unableToCreateFile("Unity iOS Build Script"))
        }

        return .success
    }

}
