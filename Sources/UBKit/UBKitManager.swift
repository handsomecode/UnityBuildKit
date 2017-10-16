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
    private let workingiOSFolderPath: String
    private let workingUnityFolderPath: String

    private let fileManager = FileManager.default

    init(config: Config) {
        self.config = config

        self.workingFolderPath = fileManager.currentDirectoryPath.appending("/")
        self.workingiOSFolderPath = workingFolderPath.appending("iOS/")
        self.workingUnityFolderPath = workingFolderPath.appending("Unity/")
        self.xcodeProjectYMLFileName = "project.yml"
    }

    func performTasks() -> Result {
        print("\n----------")
        print("Creating iOS Project")
        print("----------")
        let iOSGenerationResult = createiOSProject()
        guard iOSGenerationResult == .success else {
            return iOSGenerationResult
        }

        print("\n----------")
        print("Creating Unity Project")
        print("----------")
        let unityGenerationResult = createUnityProject()
        guard unityGenerationResult == .success else {
            return unityGenerationResult
        }

        print("\n----------")
        print("Initializing projects")
        print("----------")
        let refreshResult = refreshProjects()
        guard refreshResult == .success else {
            return refreshResult
        }

        print("\n----------")
        print("Copying Unity Files")
        print("----------")
        let copyFilesResult = copyUnityFiles()
        guard copyFilesResult == .success else {
            return copyFilesResult
        }

        return .success
    }

    func createiOSProject() -> Result {
        let xcodeProject = XcodeProject(
            projectName: config.projectName,
            bundleIdentifier: config.bundleID,
            workingPath: workingiOSFolderPath,
            unityVersion: config.unityVersion
        )
        return xcodeProject.create()
    }

    func createUnityProject() -> Result {
        let unityProject = UnityProject(
            projectName: config.projectName,
            workingPath: workingUnityFolderPath,
            unityAppPath: config.unityPath
        )
        return unityProject.create()
    }

    func refreshProjects() -> Result {
        let refreshser = ProjectRefresher(
            projectName: config.projectName,
            workingPath: workingFolderPath,
            sceneName: config.unitySceneName
        )
        return refreshser.refresh()
    }

    func copyUnityFiles() -> Result {
        let fileCopier = FileCopier(
            config: config,
            workingPath: workingUnityFolderPath,
            xcodeProjectPath: workingiOSFolderPath
        )
        return fileCopier.copyFiles()
    }
}
