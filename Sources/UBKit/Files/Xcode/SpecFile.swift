//
//  specFile.swift
//  UEKit
//
//  Created by Eric Miller on 10/11/17.
//

import Foundation

extension File {

    /**
     Do not adjust the spacing of the file string.
     It is specifically indented and formatted in order
     to work once the data is written to the spec file.
     */
    class func specFile(projectName: String, bundleIdentifier: String, unityVersion: String) -> Data? {
        let file = """
            name: \(projectName)
            configs:
              Debug: debug
              Release: release
            targets:
              \(projectName):
                type: application
                platform: iOS
                sources:
                  - \(projectName)
                  - Vendor
                settings:
                  PRODUCT_BUNDLE_IDENTIFIER: \(bundleIdentifier)
                  IOS_DEPLOYMENT_TARGET: 11.0
                  IPHONEOS_DEPLOYMENT_TARGET: 11.0
                  UNITY_RUNTIME_VERSION: \(unityVersion)
                  UNITY_SCRIPTING_BACKEND: il2cpp
                  UNITY_IOS_EXPORT_PATH: ${SRCROOT}/../Unity/\(projectName)/ios_build
                  GCC_PREFIX_HEADER: $(UNITY_IOS_EXPORT_PATH)/Classes/Prefix.pch
                  OTHER_LDFLAGS: -weak-lSystem -weak_framework CoreMotion -weak_framework GameKit -weak_framework iAd -framework CoreGraphics -framework AVFoundation -framework CoreVideo -framework CoreMedia -framework SystemConfiguration -framework CoreLocation -framework MediaPlayer -framework CFNetwork -framework AudioToolbox -framework OpenAL -framework QuartzCore -framework OpenGLES -framework UIKit -framework Foundation -framework MediaToolbox -liconv.2 -liPhone-lib
                  HEADER_SEARCH_PATHS: $(UNITY_IOS_EXPORT_PATH)/Classes $(UNITY_IOS_EXPORT_PATH)/Classes/Native $(UNITY_IOS_EXPORT_PATH)/Libraries/libil2cpp/include
                  LIBRARY_SEARCH_PATHS: $(UNITY_IOS_EXPORT_PATH)/Libraries $(UNITY_IOS_EXPORT_PATH)/Libraries/libil2cpp/include
                  ENABLE_BITCODE: NO
                  OTHER_CFLAGS: $(inherited) -DINIT_SCRIPTING_BACKEND=1 -fno-strict-overflow -DRUNTIME_IL2CPP=1
                  CLANG_CXX_LANGUAGE_STANDARD: c++11
                  CLANG_CXX_LIBRARY: libc++
                  SWIFT_OBJC_BRIDGING_HEADER: UnityBridge.h
                  CLANG_ENABLE_MODULES: NO
                  CLANG_WARN_BOOL_CONVERSION: NO
                  CLANG_WARN_CONSTANT_CONVERSION: NO
                  CLANG_WARN_DIRECT_OBJC_ISA_USAGE: YES
                  CLANG_WARN_EMPTY_BODY: NO
                  CLANG_WARN_ENUM_CONVERSION: NO
                  CLANG_WARN_INT_CONVERSION: NO
                  CLANG_WARN_OBJC_ROOT_CLASS: YES
                  CLANG_WARN_UNREACHABLE_CODE: NO
                  CLANG_WARN__DUPLICATE_METHOD_MATCH: NO
                  GCC_C_LANGUAGE_STANDARD: c99
                  GCC_ENABLE_OBJC_EXCEPTIONS: NO
                  GCC_ENABLE_CPP_RTTI: NO
                  GCC_PRECOMPILE_PREFIX_HEADER: YES
                  GCC_THUMB_SUPPORT: NO
                  GCC_USE_INDIRECT_FUNCTION_CALLS: NO
                  GCC_WARN_64_TO_32_BIT_CONVERSION: NO
                  GCC_WARN_64_TO_32_BIT_CONVERSION[arch=*64]: YES
                  GCC_WARN_ABOUT_RETURN_TYPE: YES
                  GCC_WARN_UNDECLARED_SELECTOR: NO
                  GCC_WARN_UNINITIALIZED_AUTOS: NO
                  GCC_WARN_UNUSED_FUNCTION: NO
            """.data(using: .utf8)
        return file
    }
}
