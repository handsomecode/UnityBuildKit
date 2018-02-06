//
//  UnityProjectScript.swift
//  UnityBuildKitPackageDescription
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

    class func unityFrameworksScriptFile(projectName: String, iOSProjectPath: String) -> Data? {
        let file = """
        using System.Collections;
        using System.IO;
        using UnityEngine;
        using UnityEditor;
        using UnityEditor.SceneManagement;
        using UnityEngine.SceneManagement;
        using UnityEditor.iOS.Xcode;

        public class XcodeFrameworks: MonoBehaviour {

            private const string iOSProjectRoot = \"\(iOSProjectPath)\";
            private const string iOSProjectName = \"\(projectName)\";
            private const string PbxFilePath = iOSProjectName + ".xcodeproj/project.pbxproj";

            public static void Perform () {
                var pbx = new PBXProject();
                var pbxPath = Path.Combine(iOSProjectRoot, PbxFilePath);
                pbx.ReadFromFile(pbxPath);

                var targetGuid = pbx.TargetGuidByName(iOSProjectName);
                pbx.AddFrameworkToProject(targetGuid, "GameKit.framework", true);
                pbx.AddFrameworkToProject(targetGuid, "CoreGraphics.framework", false);
                pbx.AddFrameworkToProject(targetGuid, "AVFoundation.framework", false);
                pbx.AddFrameworkToProject(targetGuid, "CoreVideo.framework", false);
                pbx.AddFrameworkToProject(targetGuid, "CoreMedia.framework", false);
                pbx.AddFrameworkToProject(targetGuid, "SystemConfiguration.framework", false);
                pbx.AddFrameworkToProject(targetGuid, "CoreLocation.framework", false);
                pbx.AddFrameworkToProject(targetGuid, "MediaPlayer.framework", false);
                pbx.AddFrameworkToProject(targetGuid, "CFNetwork.framework", false);
                pbx.AddFrameworkToProject(targetGuid, "AudioToolbox.framework", false);
                pbx.AddFrameworkToProject(targetGuid, "OpenAL.framework", false);
                pbx.AddFrameworkToProject(targetGuid, "QuartzCore.framework", false);
                pbx.AddFrameworkToProject(targetGuid, "Foundation.framework", false);
                pbx.AddFrameworkToProject(targetGuid, "MediaToolbox.framework", false);

                pbx.WriteToFile(pbxPath);
            }
        }
        """.data(using: .utf8)
        return file
    }
}
