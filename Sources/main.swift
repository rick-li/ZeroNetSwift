//
//  main.swift
//  ZeroNetSwift
//
//  Created by Rick Li on 1/1/18.
//

import Foundation

let fm = FileManager.default
let currDir = FileManager.default.currentDirectoryPath
let rootDir = currDir + "/ZeroNetTest"
var isDir = ObjCBool(true)
print("Root Dir is " + rootDir)
if fm.fileExists(atPath: rootDir, isDirectory: &isDir) {
    do {
        try fm.removeItem(atPath: rootDir)
    } catch {
        print("Failed to delete root dir " + rootDir)
    }
}

do {
    try fm.createDirectory(atPath: rootDir, withIntermediateDirectories: true)
} catch {
    print("Failed to create root dir " + rootDir)
}

let trackers = [
    "http://tracker.opentrackr.org:1337/announce",
    "http://explodie.org:6969/announce",
    "http://tracker1.wasabii.com.tw:6969/announce"
]
    
var siteAddress = "1BpsBJzmAJryFy3TmCgfcfzUF7nc1MLwJj"

if (CommandLine.arguments.count > 1) {
    siteAddress = CommandLine.arguments[1]
}
//let siteAddress = "1AUHC6wpgF676cEd8uZX6cU8BucGU4KAP7"
let z = ZeroNet(rootPath: rootDir, trackers: trackers, sites: [siteAddress])
z.start()

sleep(1000)
