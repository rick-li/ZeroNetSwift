//
//  main.swift
//  LearnSwiftPackageDescription
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
let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
//let site = "1BpsBJzmAJryFy3TmCgfcfzUF7nc1MLwJj"
let siteAddress = "1AUHC6wpgF676cEd8uZX6cU8BucGU4KAP7"

let site = Site(siteAddr: siteAddress)
do {
    try site.loadPeersFromTracker(trackerIdx: 0, onLoaded: { peers in
        print("Peers loaded - ", peers)
    })
//    let siteAddr = "1AUHC6wpgF676cEd8uZX6cU8BucGU4KAP7"
//    print(Digest.sha1(siteAddress.bytes).toHexString().count)
//    print(String(urlEncodingData: Data(bytes: Digest.sha1(siteAddress.bytes))))
//    print( String(bytes: Digest.sha1(siteAddress.bytes), encoding: .ascii))
//    let data = Digest.sha1(siteAddress.bytes)
//    if let str = NSString(bytes: data,length: data.count,encoding: String.Encoding.utf8.rawValue) as? String {
//        print("Byte array : (data) -> String : (str)")
//    } else {
//        print("Not a valid UTF-8 sequence")
//    }
//    try site.loadPeersFromTracker()
}catch {
    
}
//func onHandshake(conn: Connection, handshakeMessage: MessagePackValue) {
////    print("Handshake is ", handshakeMessage)
//    do {
////        try conn.requestFile(site: "1AUHC6wpgF676cEd8uZX6cU8BucGU4KAP7", path: "img/TCMM603.mp3")
////        try conn.requestFile(site: "1BpsBJzmAJryFy3TmCgfcfzUF7nc1MLwJj", path: "data/test.mp3")
//        try conn.requestFile(site: siteAddress, path: "content.json")
//    } catch let error as NSError {
//        print(error)
//    }
//
//}
//
//var filelists: [String] = []
//func onFileDownload(conn: Connection, req: Request) {
//    let innerPath = req.message["params"]!["inner_path"]
//    if innerPath == "content.json" {
//        print("content.json found ")
//        let destRootPath = "/Users/kl68884/testzeronet/"
//        let contentJsonData = FileManager.default.contents(atPath: destRootPath + "content.json")
//        let bodyJson = JSON(data: contentJsonData!)
//        for (key, subJson):(String, JSON) in bodyJson["files"] {
//            print(key)
//            filelists.append(key)
////            print(subJson["size"])
////            do {
////                try conn.requestFile(site: "1BpsBJzmAJryFy3TmCgfcfzUF7nc1MLwJj", path: key)
////            }catch let error as NSError{
////                print(error)
////            }
//
//        }
//    }
//    if(filelists.count > 0){
//        if(innerPath != nil){
//            filelists = filelists.filter({ item in
//                    return item != innerPath?.stringValue
//            })
//            if(filelists.count == 0 ){
//                return
//            }
//            do {
//                try conn.requestFile(site: site, path: filelists[0])
//
//            } catch let error as NSError {
//                print(error)
//            }
//        }
//
//    }
//}

//queue.async { _ in
//    do {
//        try Connection(host: "127.0.0.1", port: 15441, onHandshakeReceived: onHandshake, onFileDownloaded: onFileDownload)
//        try Connection(host: "45.76.199.168", port: 15441, onHandshakeReceived: onHandshake)
        
//    }catch let error as NSError {
//        print(error)
//    }
    
//}




//let ohelper = ObjcHelper()
//ohelper.hello()


//do{
//    let first = try unpack("!LH", Data(bytes: [77,55,233,114,60,81]))
//    print(first[0], first[1])
//    let packedAddrData = pack("!L", [2066563929])
//    print(packedAddrData)
////    print(ohelper.ntoa(Data(bytes: [77,55,233,114])))
//}catch  {
//
//}


//Alamofire.request(url).response(queue: queue) { response in // method defaults to `.get`
////    print("done")
//    do{
////        print(response.data)
//        let bencode = try Bencode(bytes: response.data!.bytes)
//        let peers = bencode!["peers"].bytes
////        print(peers)
//        let peerNum = (peers?.count)!/6
////        print((peers)?.prefix(6))
//
//        for var i in 0..<peerNum{
//            let ip1 = Int(peers![i * 6]);
//            let ip2 = Int(peers![i * 6 + 1]);
//            let ip3 = Int(peers![i * 6 + 2]);
//            let ip4 = Int(peers![i * 6 + 3]);
////            print("peer is \(ip1).\(ip2).\(ip3).\(ip4)")
////            let peerBytes = peers![i * 6...i*6 + 5]
////            let first = try unpack("!LH", Data(bytes: peerBytes))
//////            let ii = 12345
////
////            let addrByteArray = intToByteArray(first[0] as! Int)
////            let packedAddrData = pack("!L", addrByteArray)
////            print(ohelper.ntoa(packedAddrData), first[1])
//
//        }
//
//
////        var firstAddr = first[0]
////        let addrData = NSData(bytes: &firstAddr, length: MemoryLayout<Int>.size)
////        for i in addrData.bytes {
////            print(i)
////        }
////        let packedAddrData = pack("!L", addrData.);
////        print(packedAddrData, first[1])
////        if let string = Data(bytes: addr) {
////            print(ohelper.ntoa(packedAddrData))
////        } else {
////            print("not a valid UTF-8 sequence")
////        }
//
//
////        print(String(data: first, encoding: .utf8) )
////        print(String.init(data: response.data!, encoding: String.Encoding.ascii) ?? "")
////        let result = try Bencode.decode(data: response.data!)
////        print(result)
//
////        if let announce = result.dictionary?["announce"]?.string {
////            print(announce)
////        }
//    }catch  {
//
//    }

//}

sleep(1000)
