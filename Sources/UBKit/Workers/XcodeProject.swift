//
//  XcodeProject.swift
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

class XcodeProject {

    private let config: Config
    private let projectPath: String
    private let vendorFolderPath: String
    private let vendorClassesFolderPath: String
    private let vendorLibrariesFolderPath: String
    private let specFileName: String
    private let bridgingFilesPath: String

    private let fileManager = FileManager()
    private var error: Error?

    init(config: Config) {
        self.config = config

        self.projectPath = config.iOS.projectPath.appending(config.iOS.projectName).appending("/")
        self.vendorFolderPath = config.iOS.projectPath.appending("Vendor/UBK/")
        self.vendorClassesFolderPath = vendorFolderPath.appending("Classes")
        self.vendorLibrariesFolderPath = vendorFolderPath.appending("Libraries")
        self.specFileName = "project.yml"
        self.bridgingFilesPath = projectPath.appending("UnityBridge/")
    }

    func create() -> Result {
        print("iOS Project Path: \(config.iOS.projectPath)")
        let iOSFolderResult = createiOSFolder()
        guard iOSFolderResult == .success else {
            return iOSFolderResult
        }

        let specFileResult = createSpecFile()
        guard specFileResult == .success else {
            return specFileResult
        }

        let projectFolderResult = createProjectFolder()
        guard projectFolderResult == .success else {
            return projectFolderResult
        }

        let sourceFileResult = createSourceFiles()
        guard sourceFileResult == .success else {
            return sourceFileResult
        }

        let assetCatalogResult = createAssetCatalog()
        guard assetCatalogResult == .success else {
            return assetCatalogResult
        }

        let unityFilesResult = createUnityBridgeFiles()
        guard unityFilesResult == .success else {
            return unityFilesResult
        }

        let unityFoldersResult = createUnityVendorFolders()
        guard unityFoldersResult == .success else {
            return unityFoldersResult
        }

        let projectGenerationResult = generateXcodeProject()
        guard projectGenerationResult == .success else {
            return projectGenerationResult
        }

        return .success
    }
}

private extension XcodeProject {

    func createiOSFolder() -> Result {
        do {
            try fileManager.createDirectory(
                atPath: config.iOS.projectPath,
                withIntermediateDirectories: false,
                attributes: nil)

            return .success
        } catch {
            return .failure(error)
        }
    }

    func createSpecFile() -> Result {
        guard UBKit.validatePath(config.iOS.projectPath, isDirectory: true) else {
            return .failure(UBKitError.invalidFolder(config.iOS.projectPath))
        }

        let contents = File.specFile(
            iOSProjectName: config.iOS.projectName,
            bundleIdentifier: config.iOS.bundleId,
            unityProjectName: config.unity.projectName,
            unityVersion: config.unity.version
        )

        guard fileManager.createFile(
            atPath: config.iOS.projectPath.appending(specFileName),
            contents: contents,
            attributes: nil) else {
                return .failure(UBKitError.unableToCreateFile("Spec file"))
        }

        return .success
    }

    func createProjectFolder() -> Result {
        do {
            try fileManager.createDirectory(
                atPath: projectPath,
                withIntermediateDirectories: false,
                attributes: nil)

            return .success
        } catch {
            return .failure(error)
        }
    }

    func createSourceFiles() -> Result {
        guard UBKit.validatePath(projectPath, isDirectory: true) else {
            return .failure(UBKitError.invalidFolder(projectPath))
        }

        guard fileManager.createFile(
            atPath: projectPath.appending("AppDelegate.swift"),
            contents: File.appDelegateFile(),
            attributes: nil) else {
            return .failure(UBKitError.unableToCreateFile("App Delegate"))
        }

        guard fileManager.createFile(
            atPath: projectPath.appending("ViewController.swift"),
            contents: File.viewControllerFile(),
            attributes: nil) else {
            return .failure(UBKitError.unableToCreateFile("View Controller"))
        }

        guard fileManager.createFile(
            atPath: projectPath.appending("Info.plist"),
            contents: File.infoPlistFile(),
            attributes: nil) else {
            return .failure(UBKitError.unableToCreateFile("Info.plist"))
        }

        guard fileManager.createFile(
            atPath: projectPath.appending("LaunchScreen.storyboard"),
            contents: File.launchScreenFile(),
            attributes: nil) else {
            return .failure(UBKitError.unableToCreateFile("Launch storyboard"))
        }
        
        guard fileManager.createFile(
            atPath: projectPath.appending("Main.storyboard"),
            contents: File.mainStoryboardFile(),
            attributes: nil) else {
            return .failure(UBKitError.unableToCreateFile("Main storyboard"))
        }
        
        return .success
    }

    func createAssetCatalog() -> Result {
        guard UBKit.validatePath(projectPath, isDirectory: true) else {
            return .failure(UBKitError.invalidFolder(projectPath))
        }

        let assetsFilePath = projectPath.appending("Assets.xcassets/")
        let appIconFilePath = assetsFilePath.appending("AppIcon.appiconset/")

        do {
            try fileManager.createDirectory(atPath: assetsFilePath, withIntermediateDirectories: false, attributes: nil)
            try fileManager.createDirectory(atPath: appIconFilePath, withIntermediateDirectories: false, attributes: nil)

            guard fileManager.createFile(
                atPath: appIconFilePath.appending("Contents.json"),
                contents: File.appIconContentsFile(),
                attributes: nil) else {
                return .failure(UBKitError.unableToCreateFile("App Icon Contents"))
            }

            return .success
        } catch {
            return .failure(error)
        }
    }

    func createUnityVendorFolders() -> Result {
        do {
            try fileManager.createDirectory(atPath: vendorFolderPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: vendorClassesFolderPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(atPath: vendorLibrariesFolderPath, withIntermediateDirectories: true, attributes: nil)

            return .success
        } catch {
            return .failure(error)
        }
    }

    func createUnityBridgeFiles() -> Result {
        do {
            try fileManager.createDirectory(
                atPath: bridgingFilesPath,
                withIntermediateDirectories: false,
                attributes: nil)
        } catch {
            return .failure(UBKitError.unableToCreateFile("Unity Bridging Header"))
        }

        guard fileManager.createFile(
            atPath: bridgingFilesPath.appending("UnityBridge.h"),
            contents: File.unityBridgeFile(),
            attributes: nil) else {
            return .failure(UBKitError.unableToCreateFile("Unity Bridging Header"))
        }

        guard fileManager.createFile(
            atPath: bridgingFilesPath.appending("UnityUtils.h"),
            contents: File.unityUtilsHeaderFile(),
            attributes: nil) else {
            return .failure(UBKitError.unableToCreateFile("Unity Utils Header"))
        }

        guard fileManager.createFile(
            atPath: bridgingFilesPath.appending("UnityUtils.mm"),
            contents: File.unityUtilsFile(),
            attributes: nil) else {
            return .failure(UBKitError.unableToCreateFile("Unity Utils"))
        }

        guard fileManager.createFile(
            atPath: bridgingFilesPath.appending("UnityMessageBridge.h"),
            contents: File.unityMessageBridgeFile(),
            attributes: nil) else {
            return .failure(UBKitError.unableToCreateFile("Unity Message Bridge"))
        }

        return .success
    }

    func generateXcodeProject() -> Result {
        let generator = XcodeGenerator(path: config.iOS.projectPath, fileName: specFileName)
        return generator.generateProject()
    }
}
