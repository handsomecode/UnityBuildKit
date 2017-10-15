//
//  UBKitError.swift
//  UBKit
//
//  Created by Eric Miller on 10/14/17.
//

import Foundation

enum UBKitError: Error, CustomStringConvertible {
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

    var description: String {
        switch self {
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
