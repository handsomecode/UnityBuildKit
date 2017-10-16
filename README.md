<p>
    <img src="https://img.shields.io/badge/version-0.7.0-blue.svg?style=flat-square" />
    <a href="https://github.com/handsomecode/UnityBuildKit/blob/master/LICENSE">
        <img src="https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square"/>
    </a>
</p>

# UnityBuildKit

A description of this package.

## Installation
`UnityBuildKit` requires Xcode 9 and Swift 4

### Make
```
git clone https://github.com/handsomecode/UnityBuildKit
cd UnityBuildKit
make
```

## Usage
1. Create a top-level folder that will contain all information about the Xcode and Unity projects and navigate to that folder.  (_Note: By default, the name of this folder will be the name of the Xcode and Unity projects._)
```
mkdir ExampleProject
cd ExampleProject
```

2. Create a configuration file named `ubconfig.json`

```json
{
    "project_name": "", // Leaving this empty uses folder name by default
    "bundle_id": "is.handsome.UnityBuildKit",
    "unity_path": "<path_to_unity_app>", // "/Applications/Unity/Unity.app/Contents/MacOS/Unity"
    "unity_version": "2017.1.1f1",
    "unity_scene_name": "" // Leaving this empty uses folder name by default
}
```

3. Run `UnityBuildKit` in Terminal

## Attributions
This tool is built using:
- [XcodeGen]("https://github.com/yonaskolb/XcodeGen")
- [xcproj]("https://github.com/xcodeswift/xcproj")

and the wonderful dependencies they bring with them.

## License

UnityBuildKit is licensed under the MIT license. See LICENSE for more info.