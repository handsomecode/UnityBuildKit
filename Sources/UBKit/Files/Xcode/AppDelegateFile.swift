//
//  appDelegateFile.swift
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

    class func appDelegateFile() -> Data? {
        let file = """
        import UIKit

        @UIApplicationMain
        class AppDelegate: UIResponder, UIApplicationDelegate {

            var window: UIWindow?
            @objc var currentUnityController: UnityAppController!
            private var application: UIApplication?
            private var isUnityRunning = false

            func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
                self.application = application

                unity_init(CommandLine.argc, CommandLine.unsafeArgv)
                currentUnityController = UnityAppController()
                currentUnityController!.application(application, didFinishLaunchingWithOptions: launchOptions)

                // first call to startUnity will do some init stuff, so just call it here and directly stop it again
                startUnity()
                stopUnity()

                return true
            }

            func applicationWillResignActive(_ application: UIApplication) {
                if isUnityRunning {
                    currentUnityController?.applicationWillResignActive(application)
                }
            }

            func applicationDidEnterBackground(_ application: UIApplication) {
                if isUnityRunning {
                    currentUnityController?.applicationDidEnterBackground(application)
                }
            }

            func applicationWillEnterForeground(_ application: UIApplication) {
                if isUnityRunning {
                    currentUnityController?.applicationWillEnterForeground(application)
                }
            }

            func applicationDidBecomeActive(_ application: UIApplication) {
                if isUnityRunning {
                    currentUnityController?.applicationDidBecomeActive(application)
                }
            }

            func applicationWillTerminate(_ application: UIApplication) {
                if isUnityRunning {
                    currentUnityController?.applicationWillTerminate(application)
                }
            }

            func startUnity() {
                if !isUnityRunning, let app = application, let unityController = currentUnityController {
                    isUnityRunning = true
                    unityController.applicationDidBecomeActive(app)
                }
            }

            func stopUnity() {
                if isUnityRunning, let app = application, let unityController = currentUnityController {
                    unityController.applicationWillResignActive(app)
                    isUnityRunning = false
                }
            }
        }
        """.data(using: .utf8)
        return file
    }
}
