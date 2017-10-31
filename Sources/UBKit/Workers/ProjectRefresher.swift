//
//  ProjectRefresher.swift
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

class ProjectRefresher {

    private let config: Config
    private let workingPath: String

    private let fileManager = FileManager()
    private lazy var shell = Shell()

    init(config: Config) {
        self.config = config
        self.workingPath = config.unityProjectPath
    }

    func refresh() -> Result {
        let buildUnityResult = buildUnityProject()
        guard buildUnityResult == .success else {
            return buildUnityResult
        }

        return .success
    }
}

private extension ProjectRefresher {

    func buildUnityProject() -> Result {
        let semaphore = DispatchSemaphore(value: 0)
        var statusCode: Int32 = 999
        let projectPath = workingPath.appending(config.projectName)
        let outputLocation = projectPath.appending("/").appending("ios_build")

        // MARK: - Main
        print("Building \(config.unitySceneName) for iOS...")
        print("This will take some time to complete\n")
        shell.perform(
            config.unityPath,
            Unity.Arguments.batchmode,
            Unity.Arguments.projectPath,
            projectPath,
            Unity.Arguments.outputLocation,
            outputLocation,
            Unity.Arguments.sceneName,
            config.unitySceneName,
            Unity.Arguments.executeMethod,
            Unity.buildAction,
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
                return .failure(UBKitError.shellCommand("Building Unity Project"))
            }
        case .timedOut:
            return .failure(UBKitError.waitTimedOut)
        }
    }

    func refreshUnityProject() -> Result {
        let semaphore = DispatchSemaphore(value: 0)
        var statusCode: Int32 = 999
        let projectPath = workingPath.appending(config.projectName)
        let outputLocation = projectPath.appending("/").appending("ios_build")

        // MARK: - Main
        print("Building \(config.unitySceneName) for iOS...")
        print("This will take some time to complete\n")
        shell.perform(
            config.unityPath,
            Unity.Arguments.batchmode,
            Unity.Arguments.projectPath,
            projectPath,
            Unity.Arguments.outputLocation,
            outputLocation,
            Unity.Arguments.sceneName,
            config.unitySceneName,
            Unity.Arguments.executeMethod,
            Unity.refreshAction,
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
                return .failure(UBKitError.shellCommand("Building Unity Project"))
            }
        case .timedOut:
            return .failure(UBKitError.waitTimedOut)
        }
    }
}
