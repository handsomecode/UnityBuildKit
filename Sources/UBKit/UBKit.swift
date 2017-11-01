//
//  UBKit.swift
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

public final class UBKit {

    private let arguments: [String]
    private var kitManager: UBKitManager!

    private let fileManager = FileManager.default

    public init(arguments: [String] = CommandLine.arguments) throws {
        guard arguments.count == 2 else {
            throw UBKitError.invalidNumberOfArguments
        }

        self.arguments = arguments
    }

    public func run(_ completion: @escaping ((Error?) -> Void)) {
        guard let arg = getArgument(for: arguments[1]) else {
            completion(UBKitError.invalidArguments(arguments[1]))
            return
        }
        
        let workingPath = fileManager.currentDirectoryPath.appending("/")
        if arg != .initialize {
            guard let fileData = fileManager.contents(atPath: workingPath.appending("ubconfig.json")) else {
                completion(UBKitError.invalidFolder(workingPath.appending("ubconfig.json")))
                return
            }

            do {
                let config = try JSONDecoder().decode(Config.self, from: fileData)
                kitManager = UBKitManager(config: config)
            } catch {
                completion(UBKitError.invalidConfigFile(error))
                return
            }
        }

        switch arg {
        case .initialize:
            initialize(workingPath: workingPath, completion)
        case .generate:
            generate(manager: kitManager, completion)
        }
    }

    class func validatePath(_ path: String, isDirectory: Bool) -> Bool {
        if isDirectory {
            var directory = ObjCBool(false)
            let folderExists = FileManager.default.fileExists(atPath: path, isDirectory: &directory)
            return folderExists && directory.boolValue
        } else {
            return FileManager.default.fileExists(atPath: path)
        }
    }
}

private extension UBKit {

    enum Argument: String {
        case initialize = "init"
        case generate
    }

    func initialize(workingPath: String, _ completion: @escaping ((Error?) -> Void)) {
        guard fileManager.createFile(
            atPath: workingPath.appending("ubconfig.json"),
            contents: File.configFile(),
            attributes: nil) else {
                completion(UBKitError.unableToCreateFile("Configuration file"))
                return
        }

        print("\n----------")
        print("Initialization complete")
        print("You can configure your project using the new `ubconfig.json` file")
        completion(nil)
    }

    func generate(manager: UBKitManager, _ completion: @escaping ((Error?) -> Void)) {
        let taskResult = manager.performGenerateTasks()
        guard taskResult == .success else {
            completion(taskResult.error)
            return
        }

        print("\n----------")
        print("👍 Successfully created your iOS and Unity projects")
        completion(nil)
    }

    func getArgument(for arg: String) -> Argument? {
        return Argument(rawValue: arg)
    }
}
