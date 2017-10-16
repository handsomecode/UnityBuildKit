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

    private let projectName: String
    private let bundleIdentifier: String
    private let workingPath: String
    private let unityVersion: String

    private let fileManager = FileManager()
    private let projectPath: String
    private let vendorFolderPath: String
    private let specFileName: String
    private var error: Error?

    init(projectName: String, bundleIdentifier: String, workingPath: String, unityVersion: String) {
        self.projectName = projectName
        self.bundleIdentifier = bundleIdentifier
        self.workingPath = workingPath
        self.unityVersion = unityVersion

        self.projectPath = workingPath.appending(projectName).appending("/")
        self.vendorFolderPath = workingPath.appending("Vendor/Unity/")
        self.specFileName = "project.yml"
    }

    func create() -> Result {
        let iOSFolderResult = createiOSFolder()
        guard iOSFolderResult == .success else {
            return iOSFolderResult
        }

        print("Generating iOS spec file")
        let specFileResult = createSpecFile()
        guard specFileResult == .success else {
            return specFileResult
        }

        let projectFolderResult = createProjectFolder()
        guard projectFolderResult == .success else {
            return projectFolderResult
        }

        print("Generating iOS source files")
        let sourceFileResult = createSourceFiles()
        guard sourceFileResult == .success else {
            return sourceFileResult
        }

        let assetCatalogResult = createAssetCatalog()
        guard assetCatalogResult == .success else {
            return assetCatalogResult
        }

        let unityFolderResult = createUnityVendorFolder()
        guard unityFolderResult == .success else {
            return unityFolderResult
        }

        print("Generating Unity bridging files")
        let unityFilesResult = createUnityBridgeFiles()
        guard unityFilesResult == .success else {
            return unityFilesResult
        }

        print("Generating iOS project")
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
                atPath: workingPath,
                withIntermediateDirectories: false,
                attributes: nil)

            return .success
        } catch {
            return .failure(error)
        }
    }

    func createSpecFile() -> Result {
        guard UBKit.validatePath(workingPath, isDirectory: true) else {
            return .failure(UBKitError.invalidFolder(workingPath))
        }

        let contents = File.specFile(
            projectName: projectName,
            bundleIdentifier: bundleIdentifier,
            unityVersion: unityVersion
        )
        let success = fileManager.createFile(
            atPath: workingPath.appending(specFileName),
            contents: contents,
            attributes: nil)

        return success ? .success : .failure(UBKitError.unableToCreateFile("Spec File"))
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

    func createUnityVendorFolder() -> Result {
        do {
            try fileManager.createDirectory(atPath: vendorFolderPath, withIntermediateDirectories: true, attributes: nil)

            return .success
        } catch {
            return .failure(error)
        }
    }

    func createUnityBridgeFiles() -> Result {
        guard fileManager.createFile(
            atPath: workingPath.appending("UnityBridge.h"),
            contents: File.unityBridgeFile(),
            attributes: nil) else {
            return .failure(UBKitError.unableToCreateFile("Unity Bridging Header"))
        }

        guard fileManager.createFile(
            atPath: workingPath.appending("UnityUtils.h"),
            contents: File.unityUtilsHeaderFile(),
            attributes: nil) else {
            return .failure(UBKitError.unableToCreateFile("Unity Utils Header"))
        }

        guard fileManager.createFile(
            atPath: workingPath.appending("UnityUtils.mm"),
            contents: File.unityUtilsFile(),
            attributes: nil) else {
            return .failure(UBKitError.unableToCreateFile("Unity Utils"))
        }

        guard fileManager.createFile(
            atPath: workingPath.appending("UnityMessageBridge.h"),
            contents: File.unityMessageBridgeFile(),
            attributes: nil) else {
            return .failure(UBKitError.unableToCreateFile("Unity Message Bridge"))
        }

        return .success
    }

    func generateXcodeProject() -> Result {
        let generator = XcodeGenerator(path: workingPath, fileName: specFileName)
        return generator.generateProject()
    }
}