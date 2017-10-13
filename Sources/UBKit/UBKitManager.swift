//
//  UBKitManager.swift
//  unity.embed
//
//  Created by Eric Miller on 10/10/17.
//  Copyright © 2017 Handsome, LLC. All rights reserved.
//

import Foundation

class UBKitManager {

    private let projectName: String
    private let bundleIdentifier: String
    private let xcodeProjectYMLFileName: String
    private let workingFolderPath: String
    private let workingiOSFolderPath: String
    private let workingUnityFolderPath: String

    private let fileManager = FileManager.default

    init(projectName: String, bundleIdentifier: String) {
        self.projectName = projectName
        self.bundleIdentifier = bundleIdentifier

        self.workingFolderPath = fileManager.currentDirectoryPath.appending("/")
        self.workingiOSFolderPath = workingFolderPath.appending("iOS/")
        self.workingUnityFolderPath = workingFolderPath.appending("Unity/")
        self.xcodeProjectYMLFileName = "project.yml"
    }

    /**
     Performs the following tasks
     - Generate the iOS project's YAML file
     - Generate the iOS project's source folders/files
     - Gerenate the iOS project's Unity bridging folders/files
     - Create the iOS Xcode project
     
     - Create the Unity project
     - Generate the project refresh script
     */
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
        let xcodeProject = XcodeProject(projectName: projectName, bundleIdentifier: bundleIdentifier, workingPath: workingiOSFolderPath)
        return xcodeProject.create()
    }

    func createUnityProject() -> Result {
        let unityProject = UnityProject(projectName: projectName, workingPath: workingUnityFolderPath)
        return unityProject.create()
    }

    func refreshProjects() -> Result {
        let refreshser = ProjectRefresher(projectName: projectName, workingPath: workingFolderPath)
        return refreshser.refresh()
    }

    func copyUnityFiles() -> Result {
        let fileCopier = FileCopier(projectName: projectName, workingPath: workingUnityFolderPath, xcodeProjectPath: workingiOSFolderPath)
        return fileCopier.copyFiles()
    }
}

enum UBKitError: Error {
    case error(Error)
    case unableToCreateFile(String)
    case invalidFolder
    case invalidXcodeProject
    case missingGroup(String)
    case invalidUnityProject
    case unableToCreateXcodeProjectGroup
    case unableToSaveXcodeProject
    case waitTimedOut
    case shellCommand
}
