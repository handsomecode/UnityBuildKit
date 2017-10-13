//
//  MessageBridge.swift
//  UEKit
//
//  Created by Eric Miller on 10/11/17.
//

import Foundation

extension File {

    class func unityMessageBridgeFile() -> Data? {
        let file = """
        //
        //  UnityMessageBridge.h
        //
        //  Copyright © 2017 Handsome. All rights reserved.
        //

        #import <Foundation/Foundation.h>

        void sendUnityMessage(const char* obj, const char* method, const char* msg) {
            UnitySendMessage(obj, method, msg);
        }
        """.data(using: .utf8)
        return file
    }
}
