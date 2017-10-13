//
//  XcodeGenerator.swift
//  unity.embed
//
//  Created by Eric Miller on 10/10/17.
//  Copyright © 2017 Handsome, LLC. All rights reserved.
//

import Foundation
import XcodeGenKit
import xcproj
import ProjectSpec
import JSONUtilities
import PathKit

class XcodeGenerator {

    private let workingPath: String
    private let fileName: String

    init(path: String, fileName: String) {
        self.workingPath = path
        self.fileName = fileName
    }

    func generateProject() -> Result {
        return generate(spec: workingPath.appending(fileName), project: workingPath)
    }
}

// MARK: - Private
private extension XcodeGenerator {

    func generate(spec: String, project: String) -> Result {

        let specPath = Path(spec).normalize()
        let projectPath = Path(project).normalize()

        let spec: ProjectSpec
        do {
            spec = try SpecLoader.loadSpec(path: specPath)
            print("\n📋  Loaded spec:\n  \(spec.debugDescription.replacingOccurrences(of: "\n", with: "\n  "))")

        } catch let error as JSONUtilities.DecodingError {
            return .failure(error)
        } catch {
            return .failure(error)
        }

        do {
            let projectGenerator = ProjectGenerator(spec: spec, path: specPath.parent())
            let project = try projectGenerator.generateProject()
            print("⚙️  Generated project")

            let projectFile = projectPath + "\(spec.name).xcodeproj"
            try project.write(path: projectFile, override: true)
            print("💾  Saved project to \(projectFile.string)")

        } catch let error as SpecValidationError {
            return .failure(error)
        } catch {
            return .failure(error)
        }

        return .success
    }
}
