//
//  launchScreenFile.swift
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

    class func launchScreenFile() -> Data? {
        let file = """
        <?xml version="1.0" encoding="UTF-8"?>
        <document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="13196" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES" initialViewController="jKb-jh-a7I">
            <device id="retina4_7" orientation="portrait">
                <adaptation id="fullscreen"/>
            </device>
            <dependencies>
                <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="13173"/>
                <capability name="Safe area layout guides" minToolsVersion="9.0"/>
                <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
            </dependencies>
            <scenes>
                <!--View Controller-->
                <scene sceneID="iUq-g6-GIh">
                    <objects>
                        <viewController id="jKb-jh-a7I" sceneMemberID="viewController">
                            <view key="view" contentMode="scaleToFill" id="PnT-GR-qI8">
                                <rect key="frame" x="0.0" y="0.0" width="375" height="667"/>
                                <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                                <color key="backgroundColor" white="1" alpha="1" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
                                <viewLayoutGuide key="safeArea" id="beJ-Yl-IjH"/>
                            </view>
                        </viewController>
                        <placeholder placeholderIdentifier="IBFirstResponder" id="1aB-gU-pny" userLabel="First Responder" sceneMemberID="firstResponder"/>
                    </objects>
                    <point key="canvasLocation" x="-434" y="99"/>
                </scene>
            </scenes>
        </document>
        """.data(using: .utf8)
        return file
    }
}
