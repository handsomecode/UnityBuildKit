//
//  UBKitError.swift
//  UBKit
//
//  Created by Eric Miller on 10/14/17.
//

import Foundation

enum UBKitError: Error {
    case error(Error)
    case unableToCreateFile(String)
    case invalidFolder
    case invalidXcodeProject
    case missingGroup(String)
    case invalidUnityProject
    case unableToCreateXcodeProjectGroup
    case unableToSaveXcodeProject
    case waitTimedOut
    case shellCommand
    case invalidConfigFile
}
