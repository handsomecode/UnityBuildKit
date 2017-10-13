//
//  Shell.swift
//  unity.embed
//
//  Created by Eric Miller on 10/10/17.
//  Copyright © 2017 Handsome, LLC. All rights reserved.
//

import Foundation

/**
 A helper class for running shell commands.
 */
public class Shell {
    @discardableResult
    func perform(_ args: String..., terminationHandler: @escaping ((Process) -> Void)) -> Int32 {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = args
        process.terminationHandler = terminationHandler
        process.launch()
        process.waitUntilExit()

        return process.terminationStatus
    }
}
