//
//  Config.swift
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
    let unityProjectPath: String
    let iOSProjectPath: String

    let relativeIOSBuildPath: String
    let relativeUnityClassesPath: String
    let relativeUnityLibrariesPath: String
    let relativeUnityDataPath: String


    init?(json: [String : String], currentPath: String) {
        guard let projectName = json[Keys.projectName],
            let bundleID = json[Keys.bundleID], !bundleID.isEmpty,
            let unityPath = json[Config.Keys.unityPath], !unityPath.isEmpty,
            let unityVersion = json[Config.Keys.unityVersion], !unityVersion.isEmpty,
            let sceneName = json[Config.Keys.unitySceneName] else {
                return nil
        }

        if projectName.isEmpty {
            guard let folderName = currentPath.components(separatedBy: "/").last else {
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

        self.unityProjectPath = currentPath.appending("/Unity/")
        self.iOSProjectPath = currentPath.appending("/iOS/")

        self.relativeIOSBuildPath = self.projectName.appending("/ios_build/")
        self.relativeUnityClassesPath = self.projectName.appending("/ios_build/Classes/")
        self.relativeUnityLibrariesPath = self.projectName.appending("/ios_build/Libraries/")
        self.relativeUnityDataPath = self.projectName.appending("/ios_build/Data/")
    }
}
