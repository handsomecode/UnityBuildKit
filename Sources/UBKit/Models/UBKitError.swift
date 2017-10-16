//
//  UBKitError.swift
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

public enum UBKitError: Error, CustomStringConvertible {
    case invalidNumberOfArguments
    case invalidArguments(String)
    case error(Error)
    case unableToCreateFile(String)
    case invalidFolder(String)
    case invalidXcodeProject
    case missingGroup(String)
    case invalidUnityProject
    case unableToCreateXcodeProjectGroup(String)
    case unableToSaveXcodeProject
    case waitTimedOut
    case shellCommand(String)
    case invalidConfigFile

    public var description: String {
        switch self {
        case .invalidNumberOfArguments:
            return "Invalid number of command line arguments"
        case .invalidArguments(let str):
            return "Invalid argument: \(str)"
        case .error(let err):
            return err.localizedDescription
        case .unableToCreateFile(let str):
            return "Unable to create \(str)"
        case .invalidFolder(let str):
            return "Invalid Folder: \(str)"
        case .invalidXcodeProject:
            return "Invalid Xcode Project"
        case .missingGroup(let str):
            return "Could not find \(str)"
        case .invalidUnityProject:
            return "Invalid Unity Project"
        case .unableToCreateXcodeProjectGroup(let str):
            return "Could not create Xcode Group: \(str)"
        case .unableToSaveXcodeProject:
            return "Unable To Save Xcode Project"
        case .waitTimedOut:
            return "Wait Timed Out"
        case .shellCommand(let str):
            return "Failed to execute shell command: \(str)"
        case .invalidConfigFile:
            return "Invalid config file"
        }
    }
}
