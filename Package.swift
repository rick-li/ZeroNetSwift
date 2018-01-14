// swift-tools-version:4.0

//
//  Package.swift
//  LearnSwift
//
//  Created by Rick Li on 1/1/18.
//  Copyright © 2018 Rick Li. All rights reserved.
//


import PackageDescription

let package = Package(
    name: "LearnSwift",
    dependencies: [
    .package(url: "https://github.com/a2/MessagePack.swift.git", from: "3.0.0"),
//        .Package(url: "https://github.com/danieltmbr/Bencode.git", majorVersion: 1, minor: 4),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "0.8.0"),
        .package(url: "https://github.com/nst/BinUtils.git", from: "0.1.0"),
        .package(url: "https://github.com/IBM-Swift/BlueSocket.git", from: "0.12.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "3.0.0"),
        ]
)
