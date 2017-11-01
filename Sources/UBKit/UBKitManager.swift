//
//  UBKitManager.swift
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

class UBKitManager {

    private let config: Config
    private let xcodeProjectYMLFileName: String
    private let workingFolderPath: String

    private let fileManager = FileManager.default

    init(config: Config) {
        self.config = config

        self.workingFolderPath = fileManager.currentDirectoryPath.appending("/")
        self.xcodeProjectYMLFileName = "project.yml"
    }

    func performInitializeTasks() -> Result {
        print("\n----------")
        print("⚙️ Initializing")
        print("----------")

        let initResult = initializeConfiguration()
        guard initResult == .success else {
            return initResult
        }

        return .success
    }

    func performGenerateTasks() -> Result {
        print("\n----------")
        print("⚙️  Creating iOS Project")
        print("----------")
        let iOSGenerationResult = createiOSProject()
        guard iOSGenerationResult == .success else {
            return iOSGenerationResult
        }

        print("\n----------")
        print("⚙️  Creating Unity Project")
        print("----------")
        let unityGenerationResult = createUnityProject()
        guard unityGenerationResult == .success else {
            return unityGenerationResult
        }

        print("\n----------")
        print("⚙️  Copying Unity Files")
        print("----------")
        let copyFilesResult = copyUnityFiles()
        guard copyFilesResult == .success else {
            return copyFilesResult
        }

        return .success
    }
}

// MARK: - Generate
private extension UBKitManager {

    func initializeConfiguration() -> Result {
        guard fileManager.createFile(
            atPath: workingFolderPath.appending("ubconfig.json"),
            contents: File.configFile(),
            attributes: nil) else {
                return .failure(UBKitError.unableToCreateFile("Configuration file"))
        }

        return .success
    }

    func createiOSProject() -> Result {
        let xcodeProject = XcodeProject(config: config)
        return xcodeProject.create()
    }

    func createUnityProject() -> Result {
        let unityProject = UnityProject(config: config)
        return unityProject.create()
    }

    func copyUnityFiles() -> Result {
        let fileCopier = FileCopier(config: config)
        return fileCopier.copyFiles()
    }
}
