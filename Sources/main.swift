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
let mainQueue = DispatchQueue(label: "zeronet", qos: .background, attributes: .concurrent)
//let siteAddress = "1BpsBJzmAJryFy3TmCgfcfzUF7nc1MLwJj"
let siteAddress = "1AUHC6wpgF676cEd8uZX6cU8BucGU4KAP7"
let site = Site(siteAddr: siteAddress)

site.start()
sleep(1000)
