//
//  launchScreenFile.swift
//  UEKit
//
//  Created by Eric Miller on 10/11/17.
//

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
