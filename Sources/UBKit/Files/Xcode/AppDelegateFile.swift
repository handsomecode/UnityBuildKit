//
//  appDelegateFile.swift
//  UEKit
//
//  Created by Eric Miller on 10/11/17.
//

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
