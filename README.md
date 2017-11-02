<p align="center"> 
    <img src="Assets/ubk_logo.png">
</p>
<p align="center">
    <img src="https://img.shields.io/badge/version-1.0.1-blue.svg?style=flat-square" />
    <a href="https://github.com/handsomecode/UnityBuildKit/blob/master/LICENSE">
        <img src="https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square"/>
    </a>
</p>

# UnityBuildKit

UnityBuildKit is a command line tool that embeds a Unity project into an iOS application.  Both the Xcode and Unity project are automatically created, configured, and linked for immediate use after successful generation.

## Installation
`UnityBuildKit` requires Xcode 9, Swift 4, and Unity

### Homebrew
```
brew tap handsomecode/UnityBuiltKit https://github.com/handsomecode/UnityBuildKit.git
brew install UnityBuildKit
```

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
### To generate new iOS and Unity projects
_Currently, Unity needs to be closed for this process to begin._

1. Create a top-level folder and navigate to it. This folder will contain all information about the Xcode and Unity projects.  (_Note: By default, the name of this folder will be the name of the Xcode and Unity projects._)
```
mkdir ExampleProject
cd ExampleProject
```

2. Run the following to generate the `ubconfig.json` file where you can specify project information
```
UnityBuildKit config
```

3. After filling out the config file information, run 
```
$ UnityBuildKit generate
```

#### Notes
- The generation script sets up the Unity project to build for the Device SDK.  These means that, if building for a simulator, there is a high probability that you will encounter build and linker errors in Xcode.  Change the run destination to a physical device and the errors should go away.  You can change this in Unity using the Build Settings once generation is completed.

### Refreshing the projects
The built Unity files are under `ios_build/`.  When building your Unity project, make sure that you append the new build to this `ios_build/` folder so that refresh script knows where the Unity files are located.

The iOS project is automatically updated and refreshed every time the Unity project is built.  You shouldn't need to do anything! 😀

## Known Unity Version Compatibility
- 2107.1.f1

## Attributions
This tool is built using:
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [xcproj](https://github.com/xcodeswift/xcproj)

and the wonderful dependencies they bring with them.

Inspiration for building `UnityBuildKit` came after running into several problems while trying to [manually do this process](https://the-nerd.be/2015/11/13/integrate-unity-5-in-a-native-ios-app-with-xcode-7/) and reading over a [github issue](https://github.com/blitzagency/ios-unity5/issues/52) trying to resolve those problems (big thanks to [jiulongw](https://github.com/jiulongw/swift-unity)).

## License

UnityBuildKit is licensed under the MIT license. See LICENSE for more info.
