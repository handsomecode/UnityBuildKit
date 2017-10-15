//
//  Config.swift
//  UBKit
//
//  Created by Eric Miller on 10/15/17.
//

import Foundation

struct Config {

    struct Keys {
        static let projectName = "project_name"
        static let bundleID = "bundle_id"
        static let unityPath = "unity_path"
        static let unityVersion = "unity_version"
        static let unitySceneName = "unity_scene_name"
    }

    let projectName: String
    let bundleID: String
    let unityPath: String
    let unityVersion: String
    let unitySceneName: String
    let relativeIOSBuildPath: String
    let relativeUnityClassesPath: String
    let relativeUnityLibrariesPath: String
    let relativeUnityDataPath: String

    init?(json: [String : String]) {
        guard let projectName = json[Keys.projectName],
            let bundleID = json[Keys.bundleID], !bundleID.isEmpty,
            let unityPath = json[Config.Keys.unityPath], !unityPath.isEmpty,
            let unityVersion = json[Config.Keys.unityVersion], !unityVersion.isEmpty,
            let sceneName = json[Config.Keys.unitySceneName] else {
                return nil
        }

        if projectName.isEmpty {
            guard let folderName = FileManager.default.currentDirectoryPath.components(separatedBy: "/").last else {
                return nil
            }
            self.projectName = folderName
        } else {
            self.projectName = projectName
        }

        if sceneName.isEmpty {
            self.unitySceneName = self.projectName
        } else {
            self.unitySceneName = sceneName
        }

        self.bundleID = bundleID
        self.unityPath = unityPath
        self.unityVersion = unityVersion

        self.relativeIOSBuildPath = self.projectName.appending("/ios_build/")
        self.relativeUnityClassesPath = self.projectName.appending("/ios_build/Classes/")
        self.relativeUnityLibrariesPath = self.projectName.appending("/ios_build/Libraries/")
        self.relativeUnityDataPath = self.projectName.appending("/ios_build/Data/")
    }
}
