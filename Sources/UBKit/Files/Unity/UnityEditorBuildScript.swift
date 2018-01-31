//
//  UnityEditorBuildScript.swift
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

    class func unityBuildScriptFile(iOSProjectFolderPath: String, iOSProjectName: String) -> Data? {
        let file = """
        using System.Collections;
        using System.IO;
        using UnityEngine;
        using UnityEditor;
        using UnityEditor.SceneManagement;
        using UnityEngine.SceneManagement;
        using UnityEditor.iOS.Xcode;

        public class iOSBuilder: MonoBehaviour {

            private const string iOSProjectRoot = \"\(iOSProjectFolderPath)\";
            private const string iOSProjectName = \"\(iOSProjectName)\";
            private const string DataProjectPath = "Vendor/UBK/Data";
            private const string PbxFilePath = iOSProjectName + ".xcodeproj/project.pbxproj";

            public static void Perform () {
                var outputLocation = GetArg ("-outputLocation");
                var sceneName = GetArg ("-sceneName");
                var scenePath = "Assets/Scenes/" + sceneName + ".unity";

                if (!File.Exists (scenePath)) {
                    Scene scene = EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects);
                    EditorSceneManager.SaveScene(scene, scenePath);
                }

                BuildPlayerOptions playerOptions = new BuildPlayerOptions ();
                playerOptions.scenes = new[] { scenePath };
                playerOptions.locationPathName = outputLocation;
                playerOptions.target = BuildTarget.iOS;
                playerOptions.options = BuildOptions.None;
                BuildPipeline.BuildPlayer (playerOptions);

                CopyDataFolderReference (outputLocation);
            }

            private static void CopyDataFolderReference (string folderRootPath) {
                var pbx = new PBXProject();
                var pbxPath = Path.Combine(iOSProjectRoot, PbxFilePath);
                pbx.ReadFromFile(pbxPath);

                var folderGuid = pbx.AddFolderReference(Path.Combine(folderRootPath, "Data"), Path.Combine(iOSProjectRoot, DataProjectPath), PBXSourceTree.Absolute);
                var targetGiud = pbx.TargetGuidByName(iOSProjectName);
                var resourceGiud = pbx.GetResourcesBuildPhaseByTarget(targetGiud);
                pbx.AddFileToBuildSection(targetGiud, resourceGiud, folderGuid);

                pbx.WriteToFile(pbxPath);
            }

            private static string GetArg (string name) {
                var args = System.Environment.GetCommandLineArgs ();
                for (int i = 0; i < args.Length; i++) {
                    if (args [i] == name && args.Length > i + 1) {
                        return args [i + 1];
                    }
                }
                return null;
            }
        }
        """.data(using: .utf8)
        return file
    }
}
