//
//  UBKitManager.swift
//  unity.embed
//
//  Created by Eric Miller on 10/10/17.
//  Copyright © 2017 Handsome, LLC. All rights reserved.
//

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
