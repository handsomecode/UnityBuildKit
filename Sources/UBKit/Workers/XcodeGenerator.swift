//
//  XcodeGenerator.swift
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
            let projectGenerator = ProjectGenerator(spec: spec)
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
