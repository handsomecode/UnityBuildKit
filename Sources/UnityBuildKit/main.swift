//
//  Main.swift
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
import UBKit

var kit: UBKit
do {
    kit = try UBKit()
} catch {
    print("\n----------")
    print("💥 An error was encountered while creating your projects")
    if let ubkitError = error as? UBKitError {
        print(ubkitError.description)
    } else {
        print(error.localizedDescription)
    }
    exit(1)
}


kit.run { (error) in
    guard error == nil else {
        print("\n----------")
        print("💥 An error was encountered while creating your projects")
        if let ubkitError = error! as? UBKitError {
            print(ubkitError.description)
        } else {
            print(error!.localizedDescription)
        }
        exit(1)
    }

    print("For more information, visit <https://github.com/handsomecode/UnityBuildKit>\n\n")
    exit(0)
}

dispatchMain()
