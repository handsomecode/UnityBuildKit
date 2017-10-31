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

struct Config: Decodable {

    enum ConfigKeys: String, CodingKey {
        case ios
        case unity
    }

    let iOS: iOSConfig
    let unity: UnityConfig

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ConfigKeys.self)
        self.iOS = try iOSConfig(from: container.superDecoder(forKey: .ios))
        self.unity = try UnityConfig(from: container.superDecoder(forKey: .unity))
    }
}

struct iOSConfig: Decodable {
    let projectName: String
    let bundleId: String
    let projectPath: String

    private enum Keys: String, CodingKey {
        case projectName
        case bundleId
        case projectPath
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let projectName = try container.decode(String.self, forKey: .projectName)
        guard !projectName.isEmpty else {
            throw UBKitError.invalidConfigArgument(Keys.projectName.rawValue)
        }

        let bundleId = try container.decode(String.self, forKey: .bundleId)
        guard !bundleId.isEmpty else {
            throw UBKitError.invalidConfigArgument(Keys.bundleId.rawValue)
        }

        let projectPath: String
        if let path = try? container.decode(String.self, forKey: .projectPath), !path.isEmpty {
            projectPath = path
        } else {
            projectPath = FileManager.default.currentDirectoryPath.appending("/iOS/")
        }

        self.projectName = projectName
        self.bundleId = bundleId
        self.projectPath = projectPath
    }
}

struct UnityConfig {
    let projectName: String
    let applicationPath: String
    let version: String
    let projectPath: String
    let sceneNames: [String]
    let relativeIOSBuildPath: String
    let relativeClassesPath: String
    let relativeLibrariesPath: String
    let relativeDataPath: String

    private enum Keys: String, CodingKey {
        case applicationPath
        case version
        case projectPath
        case projectName
        case sceneNames
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let projectName = try container.decode(String.self, forKey: .projectName)
        guard !projectName.isEmpty else {
            throw UBKitError.invalidConfigArgument(Keys.projectName.rawValue)
        }

        let appPath = try container.decode(String.self, forKey: .applicationPath)
        guard !appPath.isEmpty else {
            throw UBKitError.invalidConfigArgument(Keys.applicationPath.rawValue)
        }

        let version = try container.decode(String.self, forKey: .version)
        guard !version.isEmpty else {
            throw UBKitError.invalidConfigArgument(Keys.version.rawValue)
        }

        let projectPath: String
        if let path = try? container.decode(String.self, forKey: .projectPath), !path.isEmpty {
            projectPath = path
        } else {
            projectPath = FileManager.default.currentDirectoryPath.appending("/Unity/")
        }

        let sceneNames = try container.decode([String].self, forKey: .sceneNames)
        guard sceneNames.count > 0 else {
            throw UBKitError.invalidConfigArgument(Keys.sceneNames.rawValue)
        }

        self.projectName = projectName
        self.applicationPath = appPath
        self.version = version
        self.projectPath = projectPath
        self.sceneNames = sceneNames

        self.relativeIOSBuildPath = projectName.appending("/ios_build/")
        self.relativeClassesPath = self.relativeIOSBuildPath.appending("Classes/")
        self.relativeLibrariesPath = self.relativeIOSBuildPath.appending("Libraries/")
        self.relativeDataPath = self.relativeIOSBuildPath.appending("Data/")
    }
}
