//
//  appIconContentsFile.swift
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

extension File {

    class func appIconContentsFile() -> Data? {
        let file = """
        {
          "images" : [
            {
              "idiom" : "iphone",
              "size" : "20x20",
              "scale" : "2x"
            },
            {
              "idiom" : "iphone",
              "size" : "20x20",
              "scale" : "3x"
            },
            {
              "idiom" : "iphone",
              "size" : "29x29",
              "scale" : "2x"
            },
            {
              "idiom" : "iphone",
              "size" : "29x29",
              "scale" : "3x"
            },
            {
              "idiom" : "iphone",
              "size" : "40x40",
              "scale" : "2x"
            },
            {
              "idiom" : "iphone",
              "size" : "40x40",
              "scale" : "3x"
            },
            {
              "idiom" : "iphone",
              "size" : "60x60",
              "scale" : "2x"
            },
            {
              "idiom" : "iphone",
              "size" : "60x60",
              "scale" : "3x"
            },
            {
              "idiom" : "ipad",
              "size" : "20x20",
              "scale" : "1x"
            },
            {
              "idiom" : "ipad",
              "size" : "20x20",
              "scale" : "2x"
            },
            {
              "idiom" : "ipad",
              "size" : "29x29",
              "scale" : "1x"
            },
            {
              "idiom" : "ipad",
              "size" : "29x29",
              "scale" : "2x"
            },
            {
              "idiom" : "ipad",
              "size" : "40x40",
              "scale" : "1x"
            },
            {
              "idiom" : "ipad",
              "size" : "40x40",
              "scale" : "2x"
            },
            {
              "idiom" : "ipad",
              "size" : "76x76",
              "scale" : "1x"
            },
            {
              "idiom" : "ipad",
              "size" : "76x76",
              "scale" : "2x"
            },
            {
              "idiom" : "ipad",
              "size" : "83.5x83.5",
              "scale" : "2x"
            },
            {
              "idiom" : "ios-marketing",
              "size" : "1024x1024",
              "scale" : "1x"
            }
          ],
          "info" : {
            "version" : 1,
            "author" : "xcode"
          }
        }
        """.data(using: .utf8)
        return file
    }
}
