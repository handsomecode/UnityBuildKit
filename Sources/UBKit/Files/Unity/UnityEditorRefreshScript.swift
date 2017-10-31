//
//  UnityEditorRefreshScript.swift
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

    class func unityRefreshScriptFile() -> Data? {
        let file = """
        using System;
        using System.Collections;
        using System.Collections.Generic;
        using System.IO;
        using UnityEngine;
        using UnityEditor;
        using UnityEditor.SceneManagement;
        using UnityEngine.SceneManagement;

        public class iOSRefresher : MonoBehaviour {

            public static void Perform () {
                var outputLocation = GetArg ("-outputLocation");
                var sceneNameArray = GetArg ("-sceneName");
                String[] sceneNames = sceneNameArray.Split (',');

                List<String> scenePaths = new List<String> ();

                for (int i = 0; i < sceneNames.Length; i++) {
                    var sceneName = sceneNames[i];
                    var scenePath = "Assets/Scenes/" + sceneName + ".unity";

                    if (File.Exists (scenePath)) {
                        scenePaths.Add (scenePath);
                    } else {
                        EditorApplication.Exit (1);
                    }
                }

                if (scenePaths.Count > 0) {
                    BuildPlayerOptions playerOptions = new BuildPlayerOptions ();
                    playerOptions.scenes = scenePaths.ToArray ();
                    playerOptions.locationPathName = outputLocation;
                    playerOptions.target = BuildTarget.iOS;
                    playerOptions.options = BuildOptions.None;
                    BuildPipeline.BuildPlayer (playerOptions);
                }
            }

            private static String GetArg (String name) {
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

