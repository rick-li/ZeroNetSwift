// swift-tools-version:4.0

//
//  Package.swift
//  ZeroNetSwift
//
//  Created by Rick Li on 1/1/18.
//  Copyright © 2018 Rick Li. All rights reserved.
//


import PackageDescription

let package = Package(
    name: "ZeroNetSwift",
    dependencies: [
        .package(url: "https://github.com/a2/MessagePack.swift.git", from: "3.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "0.8.0"),
        .package(url: "https://github.com/nst/BinUtils.git", from: "0.1.0"),
        .package(url: "https://github.com/IBM-Swift/BlueSocket.git", from: "0.12.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "3.0.0"),
        ]
)
