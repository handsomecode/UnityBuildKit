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

    class func unityProjectScriptFile(iOSProjectName: String, iOSProjectPath: String) -> Data? {
        let file = """
        using System.Linq;
        using System.Collections.Generic;
        using System.IO;
        using System.Text;
        using UnityEngine;
        using UnityEditor;
        using UnityEditor.Callbacks;
        using UnityEditor.iOS.Xcode;

        public class XcodeRefresher {

            private const string iOSProjectRoot = \"\(iOSProjectPath)\";
            private const string iOSProjectName = \"\(iOSProjectName)\";
            private const string ClassesProjectPath = "Vendor/UBK/Classes";
            private const string LibrariesProjectPath = "Vendor/UBK/Libraries";
            private const string PbxFilePath = iOSProjectName + ".xcodeproj/project.pbxproj";

            public static void Refresh() {
                var pathToBuiltProject = GetArg ("-buildPath");
                UpdateUnityProjectFiles (pathToBuiltProject);
            }

            #if UNITY_IOS
                [PostProcessBuild]
                public static void OnPostBuild(BuildTarget target, string pathToBuiltProject) {
                    UpdateUnityProjectFiles(pathToBuiltProject);
                }
            #endif

            private static void UpdateUnityProjectFiles(string pathToBuiltProject) {
                var pbx = new PBXProject();
                var pbxPath = Path.Combine(iOSProjectRoot, PbxFilePath);
                pbx.ReadFromFile(pbxPath);

                ProcessUnityDirectory(
                    pbx,
                    Path.Combine(pathToBuiltProject, "Classes"),
                    Path.Combine(iOSProjectRoot, ClassesProjectPath),
                    ClassesProjectPath);

                ProcessUnityDirectory(
                    pbx,
                    Path.Combine(pathToBuiltProject, "Libraries"),
                    Path.Combine(iOSProjectRoot, LibrariesProjectPath),
                    LibrariesProjectPath);

                pbx.WriteToFile(pbxPath);
            }

            /// <summary>
            /// Update pbx project file by adding src files and removing extra files that
            /// exists in dest but not in src any more.
            ///
            /// This method only updates the pbx project file. It does not copy or delete
            /// files in Swift Xcode project. The Swift Xcode project will do copy and delete
            /// during build, and it should copy files if contents are different, regardless
            /// of the file time.
            /// </summary>
            /// <param name="pbx">The pbx project.</param>
            /// <param name="src">The directory where Unity project is built.</param>
            /// <param name="dest">The directory of the Swift Xcode project where the
            /// Unity project is embedded into.</param>
            /// <param name="projectPathPrefix">The prefix of project path in Swift Xcode
            /// project for Unity code files. E.g. "DempApp/Unity/Classes" for all files
            /// under Classes folder from Unity iOS build output.</param>
            private static void ProcessUnityDirectory(PBXProject pbx, string src, string dest, string projectPathPrefix) {
                var targetGuid = pbx.TargetGuidByName(iOSProjectName);

                string[] newFiles, extraFiles;
                CompareDirectories(src, dest, out newFiles, out extraFiles);

                foreach (var f in newFiles) {
                    var projPath = Path.Combine(projectPathPrefix, f);
                    if (!pbx.ContainsFileByProjectPath(projPath)) {
                        var guid = pbx.AddFile(Path.Combine(src, f), projPath, PBXSourceTree.Absolute);
                        pbx.AddFileToBuild(targetGuid, guid);

                        Debug.LogFormat("Added file to pbx: '{0}'", projPath);
                    }
                }

                foreach (var f in extraFiles) {
                    var projPath = Path.Combine(projectPathPrefix, f);
                    if (pbx.ContainsFileByProjectPath(projPath)) {
                        var guid = pbx.FindFileGuidByProjectPath(projPath);
                        pbx.RemoveFile(guid);

                        Debug.LogFormat("Removed file from pbx: '{0}'", projPath);
                    }
                }
            }

            /// <summary>
            /// Compares the directories. Returns files that exists in src and
            /// extra files that exists in dest but not in src any more.
            /// </summary>
            private static void CompareDirectories(string src, string dest, out string[] srcFiles, out string[] extraFiles) {
                srcFiles = GetFilesRelativePath(src);

                var destFiles = GetFilesRelativePath(dest);
                var extraFilesSet = new HashSet<string>(destFiles);

                extraFilesSet.ExceptWith(srcFiles);
                extraFiles = extraFilesSet.ToArray();
            }

            private static string[] GetFilesRelativePath(string directory) {
                var results = new List<string>();

                if (Directory.Exists(directory)) {
                    foreach (var path in Directory.GetFiles(directory, "*", SearchOption.AllDirectories)) {
                        var relative = path.Substring(directory.Length).TrimStart('/');
                        results.Add(relative);
                    }
                }

                return results.ToArray();
            }

            private static string GetArg(string name) {
                var args = System.Environment.GetCommandLineArgs();
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
