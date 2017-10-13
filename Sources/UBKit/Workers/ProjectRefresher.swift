//
//  ProjectRefresher.swift
//  UEKit
//
//  Created by Eric Miller on 10/11/17.
//

import Foundation

class ProjectRefresher {

    private let workingPath: String
    private let projectName: String

    private let fileManager = FileManager()
    private lazy var shell = Shell()
    private let refreshScriptName: String
    private let unitySceneName: String

    init(projectName: String, workingPath: String) {
        self.projectName = projectName
        self.workingPath = workingPath

        self.refreshScriptName = "refreshProjects.swift"
        self.unitySceneName = "MainScene"
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
                return .failure(UBKitError.shellCommand)
            }
        case .timedOut:
            return .failure(UBKitError.waitTimedOut)
        }
    }
}
