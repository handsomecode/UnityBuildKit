//
//  UnityUtilsFile.swift
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

    class func unityUtilsHeaderFile() -> Data? {
        let file = """
        //
        //  UnityUtils.h
        //
        //  Created by Adam Venturella on 10/28/15.
        //

        #ifndef UnityUtils_h
        #define UnityUtils_h


        void unity_init(int argc, char* argv[]);

        #endif /* UnityUtils_h */
        """.data(using: .utf8)
        return file
    }

    class func unityUtilsFile() -> Data? {
        let file = """
        //
        //  UnityUtils.m
        //
        //  Created by Adam Venturella on 10/28/15.
        //
        // this is taken directly from the unity generated main.mm file.
        // if they change that initialization, this will need to be updated
        // as well.
        //
        //  Updated by Martin Straub on 03/15/17.
        //
        // updated to Unity 5.5.0f3 => working on Xcode 8.2.1 with Swift 3.0.2


        #include "RegisterMonoModules.h"
        #include "RegisterFeatures.h"
        #include <csignal>


        // Hack to work around iOS SDK 4.3 linker problem
        // we need at least one __TEXT, __const section entry in main application .o files
        // to get this section emitted at right time and so avoid LC_ENCRYPTION_INFO size miscalculation
        static const int constsection = 0;

        void UnityInitTrampoline();

        extern "C" void unity_init(int argc, char* argv[])
        {
            @autoreleasepool
            {
                UnityInitTrampoline();
                UnityInitRuntime(argc, argv);

                RegisterMonoModules();
                NSLog(@"-> registered mono modules %p", &constsection);
                RegisterFeatures();

                // iOS terminates open sockets when an application enters background mode.
                // The next write to any of such socket causes SIGPIPE signal being raised,
                // even if the request has been done from scripting side. This disables the
                // signal and allows Mono to throw a proper C# exception.
                std::signal(SIGPIPE, SIG_IGN);
            }
        }
        """.data(using: .utf8)
        return file
    }
}
