<p>
    <img src="https://img.shields.io/badge/version-0.7.0-blue.svg?style=flat-square" />
    <a href="https://github.com/handsomecode/UnityBuildKit/blob/master/LICENSE">
        <img src="https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square"/>
    </a>
</p>

# UnityBuildKit

UnityBuildKit is a command line tool that generates an iOS application with an embedded Unity scene.

## Installation
`UnityBuildKit` requires Xcode 9 and Swift 4

### Make
```
git clone https://github.com/handsomecode/UnityBuildKit
cd UnityBuildKit
make
```

### Swift Package Manager
#### Use as a dependency
```
.package(url: "https://github.com/handsomecode/UnityBuildKit", from: "1.0.0"),
```

## Usage
### To generate a new project
1. Create a top-level folder and navigate to it. This folder will contain all information about the Xcode and Unity projects.  (_Note: By default, the name of this folder will be the name of the Xcode and Unity projects._)
```
mkdir ExampleProject
cd ExampleProject
```

2. Create a configuration file named `ubconfig.json`

```
{
    "project_name": "", // Leaving this empty uses folder name by default
    "bundle_id": "is.handsome.UnityBuildKit",
    "unity_path": "<path_to_unity_app>", // "/Applications/Unity/Unity.app/Contents/MacOS/Unity"
    "unity_version": "2017.1.1f1",
    "unity_scene_name": "" // Leaving this empty uses folder name by default
}
```

3. Run 
```
$ UnityBuildKit generate
```

## Known Unity Version Compatibility
- 2107.1.f1

## Attributions
This tool is built using:
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [xcproj](https://github.com/xcodeswift/xcproj)

and the wonderful dependencies they bring with them.

Inspiration for building `UnityBuildKit` came after running into several problems while trying to [manually do this process](https://the-nerd.be/2015/11/13/integrate-unity-5-in-a-native-ios-app-with-xcode-7/) and reading over a [github issue](https://github.com/blitzagency/ios-unity5/issues/52) trying to resolve those problems.

## License

UnityBuildKit is licensed under the MIT license. See LICENSE for more info.