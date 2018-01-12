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
        .Package(url: "https://github.com/a2/MessagePack.swift.git", majorVersion: 3),
//        .Package(url: "https://github.com/danieltmbr/Bencode.git", majorVersion: 1, minor: 4),
        .Package(url: "https://github.com/Alamofire/Alamofire.git", majorVersion: 4),
        .Package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", majorVersion: 0, minor: 8),
        .Package(url: "https://github.com/nst/BinUtils.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/IBM-Swift/BlueSocket.git", majorVersion: 0, minor: 12),
        .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", versions: Version(1, 0, 0)..<Version(3, .max, .max)),


    ]
)
