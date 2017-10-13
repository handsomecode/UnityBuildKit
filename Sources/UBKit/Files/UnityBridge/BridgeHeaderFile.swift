//
//  BridgeHeaderFile.swift
//  unity.embedPackageDescription
//
//  Created by Eric Miller on 10/11/17.
//

import Foundation

extension File {

    class func unityBridgeFile() -> Data? {
        let file = """
        //
        //  UnityBridge.h
        //
        //  Created by Adam Venturella on 10/28/15.
        //

        #ifndef UnityBridge_h
        #define UnityBridge_h

        #import <UIKit/UIKit.h>
        #import "UnityUtils.h"
        #import "UnityAppController.h"
        #import "UnityInterface.h"

        #import "UnityMessageBridge.h"

        #endif /* UnityBridge_h */
        """.data(using: .utf8)
        return file
    }
}
