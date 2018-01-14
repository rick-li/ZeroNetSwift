//
//  main.swift
//  ZeroNetSwift
//
//  Created by Rick Li on 1/1/18.
//

import Foundation
import Alamofire
import CryptoSwift
import BinUtils
import Socket
import MessagePack
import SwiftyJSON
import CryptoSwift

let ROOT_PATH = "/Users/kl68884/testzeronet/"
let queue = DispatchQueue(label: "zeronet", qos: .background, attributes: .concurrent)
//let site = "1BpsBJzmAJryFy3TmCgfcfzUF7nc1MLwJj"
let siteAddress = "1AUHC6wpgF676cEd8uZX6cU8BucGU4KAP7"
let site = Site(siteAddr: siteAddress)

site.loadPeersFromTracker(trackerIdx: 0, onLoaded: { peers in
    print("Peers loaded - ", peers)
})

//func onHandshake(conn: Connection, handshakeMessage: MessagePackValue) {
////    print("Handshake is ", handshakeMessage)
//    do {
//        try conn.requestFile(site: siteAddress, path: "content.json")
//    } catch let error as NSError {
//        print(error)
//    }
//
//}

sleep(1000)
