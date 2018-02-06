//
//  UnityCommandLine.swift
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

/**
 A helper class for interacting with the Unity command line.
 */
struct UnityCommandLine {
    static let buildAction = "iOSBuilder.Perform"
    static let refreshAction = "XcodeRefresher.Refresh"
    static let frameworksAction = "XcodeFrameworks.Perform"

    struct Arguments {
        static let projectPath = "-projectPath"
        static let createProject = "-createProject"
        static let outputLocation = "-outputLocation"
        static let buildPath = "-buildPath"
        static let sceneName = "-sceneName"
        static let executeMethod = "-executeMethod"
        static let batchmode = "-batchmode"
        static let quit = "-quit"
    }
}
