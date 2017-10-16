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

    private let workingPath: String
    private let projectName: String

    private let fileManager = FileManager()
    private lazy var shell = Shell()
    private let refreshScriptName: String
    private let unitySceneName: String

    init(projectName: String, workingPath: String, sceneName: String) {
        self.projectName = projectName
        self.workingPath = workingPath

        self.refreshScriptName = "refreshProjects.swift"
        self.unitySceneName = sceneName
    }

    func refresh() -> Result {
        let projectRefreshScriptResult = createProjectRefreshScript()
        guard projectRefreshScriptResult == .success else {
            return projectRefreshScriptResult
        }

        let initializationResult = runInitialProjectRefresh()
        guard initializationResult == .success else {
            return initializationResult
        }

        return .success
    }
}

private extension ProjectRefresher {

    func createProjectRefreshScript() -> Result {
        guard fileManager.createFile(
            atPath: workingPath.appending(refreshScriptName),
            contents: File.projectRefreshFile(projectName: projectName),
            attributes: [
                FileAttributeKey.posixPermissions: 0o777
            ]) else {
                return .failure(UBKitError.unableToCreateFile("Project Refresh Script"))
        }

        return .success
    }

    func runInitialProjectRefresh() -> Result {
        let semaphore = DispatchSemaphore(value: 0)
        var statusCode: Int32 = 999

        shell.perform(
            "./\(self.refreshScriptName)",
            self.unitySceneName,
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
                return .failure(UBKitError.shellCommand("Initialize Unity Project"))
            }
        case .timedOut:
            return .failure(UBKitError.waitTimedOut)
        }
    }
}
