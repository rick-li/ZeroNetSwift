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

let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
//let site = "1BpsBJzmAJryFy3TmCgfcfzUF7nc1MLwJj"
let site = "1AUHC6wpgF676cEd8uZX6cU8BucGU4KAP7"
func onHandshake(conn: Connection, handshakeMessage: MessagePackValue) {
//    print("Handshake is ", handshakeMessage)
    do {
//        try conn.requestFile(site: "1AUHC6wpgF676cEd8uZX6cU8BucGU4KAP7", path: "img/TCMM603.mp3")
//        try conn.requestFile(site: "1BpsBJzmAJryFy3TmCgfcfzUF7nc1MLwJj", path: "data/test.mp3")
        try conn.requestFile(site: site, path: "content.json")
    } catch let error as NSError {
        print(error)
    }
    
}

var filelists: [String] = []
func onFileDownload(conn: Connection, req: Request) {
    let innerPath = req.message["params"]!["inner_path"]
    if innerPath == "content.json" {
        print("content.json found ")
        let destRootPath = "/Users/kl68884/testzeronet/"
        let contentJsonData = FileManager.default.contents(atPath: destRootPath + "content.json")
        let bodyJson = JSON(data: contentJsonData!)
        for (key, subJson):(String, JSON) in bodyJson["files"] {
            print(key)
            filelists.append(key)
//            print(subJson["size"])
//            do {
//                try conn.requestFile(site: "1BpsBJzmAJryFy3TmCgfcfzUF7nc1MLwJj", path: key)
//            }catch let error as NSError{
//                print(error)
//            }
            
        }
    }
    if(filelists.count > 0){
        if(innerPath != nil){
            filelists = filelists.filter({ item in
                    return item != innerPath?.stringValue
            })
            if(filelists.count == 0 ){
                return
            }
            do {
                try conn.requestFile(site: site, path: filelists[0])
            
            } catch let error as NSError {
                print(error)
            }
        }
            
    }
}

//queue.async { _ in
    do {
        try Connection(host: "127.0.0.1", port: 15441, onHandshakeReceived: onHandshake, onFileDownloaded: onFileDownload)
//        try Connection(host: "45.76.199.168", port: 15441, onHandshakeReceived: onHandshake)
        
    }catch let error as NSError {
        print(error)
    }
    
//}


//
//let fm = FileManager.default
//let socket = try Socket.create()
//var streamFileData = Data()
//var isStreaming = false
//var mp3FileSize:Int64?
//var mp3ReadSize:Int64?
//func pollSocket(_socket: Socket){
//    queue.async { _ in
//            while(true){
//                do{
//                    var readData = Data(capacity: 64 * 1024)
//                    let bytesRead = try _socket.read(into: &readData)
//                    print("bytes read", bytesRead)
//                    if bytesRead > 0 {
//                        let mp3Target = "/Users/kl68884/testzeronet/test.mp3"
////                        if(isStreaming){
////                            streamFileData.append(readData)
////
////                            if streamFileData.count >= Int(truncatingBitPattern: mp3FileSize!) {
////                                if fm.fileExists(atPath: mp3Target) {
////                                    try fm.removeItem(atPath: mp3Target)
////                                }
////                                fm.createFile(atPath: mp3Target, contents: streamFileData)
////
////                            }else{
//////                                let streamFileMV = MessagePackValue(["cmd": "streamFile", "params": [
//////                                    "inner_path": "data/test.mp3", "site": "1BpsBJzmAJryFy3TmCgfcfzUF7nc1MLwJj", "location": MessagePackValue(streamFileData.count)
//////                                    ], "req_id": 3])
//////                                print(streamFileMV)
//////                                try socket.write(from: pack(streamFileMV))
////                            }
////                            continue
////
////                        }
//                        var unpackedVal:(value: MessagePackValue, remainder: Data)?
//                        do{
//                            unpackedVal = try unpack(readData)
//                        } catch let error as NSError{
//
//                        }
//    //                    print(unpackedVal)
//                        let reqId = unpackedVal?.value["to"] ?? 0
//                        var body = unpackedVal?.value["body"] ?? MessagePackValue(Data())
//                        if let size = unpackedVal?.value["size"] {
//                            mp3FileSize = size.integerValue
//                        }
//                        if reqId == 2 { //getFile
//                            let bodyData = body.dataValue
//
//                            let target = "/Users/kl68884/testzeronet/content.json"
//                            if fm.fileExists(atPath: target) {
//                                try fm.removeItem(at: URL(fileURLWithPath: target))
//                            }
//                            fm.createFile(atPath: target, contents: body.dataValue)
//                            let bodyJson = JSON(data: bodyData!)
//                            for (key, subJson):(String, JSON) in bodyJson["files"] {
//                                print(key)
//                                print(subJson["size"])
//                            }
//                            print(bodyJson["files"])
//
//                        }
//                        if reqId == 3 { //streamFile
//                            print(unpackedVal?.value)
//                            let mp3Target = "/Users/kl68884/testzeronet/test.mp3"
//
//                            let size = unpackedVal?.value["size"]
//                            let location  = unpackedVal?.value["location"]
////                            mp3ReadSize = location?.integerValue
//    //                        if(unpackedVal.value["body"] == nil){
//    //                            body = unpackedVal.value["stream_bytes"] ?? MessagePackValue(Data())
//    //                        }
//                            if let streamBytes = unpackedVal?.value["stream_bytes"] {
//                                if(Int(truncatingBitPattern: streamBytes.integerValue!) > 0){
//                                    isStreaming = true
//                                    streamFileData.append((unpackedVal?.remainder)!)
//                                }
//                            }
//                            if (body.dataValue?.count as! Int) > 0 {
//                                streamFileData.append((body.dataValue!))
//                            }
//
//                            if(location == size){
//                                if fm.fileExists(atPath: mp3Target) {
//                                    try fm.removeItem(atPath: mp3Target)
//                                }
//                                fm.createFile(atPath: mp3Target, contents: streamFileData)
//                            }else{
//
//                                let streamFileMV = MessagePackValue(["cmd": "streamFile", "params": [
//                                    "inner_path": "data/test.mp3", "site": "1BpsBJzmAJryFy3TmCgfcfzUF7nc1MLwJj", "location": MessagePackValue(Int(truncatingBitPattern: (location?.integerValue)!))
//                                    ], "req_id": 3])
//                                print(streamFileMV)
//                                try socket.write(from: pack(streamFileMV))
//                            }
//                        }
//                    }
//                }catch let error as NSError{
//                    print(error)
//                    continue
//                }
//            }
//
//
//    }
//}
//
//queue.async { _ in
//    do{
//    //    try conn.connect(to: "127.0.0.1", onPort: 8080)
//    //    sleep(3)
//    //    print(conn.connected)
//    //    conn.disconnect()
//
//
//        let handshakeMV = MessagePackValue(["cmd": "handshake", "params":[
//                "target_ip": "zero.booth.moe", "version": "0.6.0", "protocol": "v2", "crypt": "", "fileserver_port": 15441, "port_opened": false, "peer_id": "-ZN0060-1RxulSyEiMsj", "rev": 3126, "crypt_supported": []
//            ], "req_id": 1])
//        let getFileMV = MessagePackValue(["cmd": "getFile", "params": [
//            "inner_path": "content.json", "site": "1BpsBJzmAJryFy3TmCgfcfzUF7nc1MLwJj", "location": 0
//            ], "req_id": 2])
//
//        let streamFileMV = MessagePackValue(["cmd": "streamFile", "params": [
//            "inner_path": "data/test.mp3", "site": "1BpsBJzmAJryFy3TmCgfcfzUF7nc1MLwJj", "location": 0
//            ], "req_id": 3])
////        {"cmd": "handshake", "params": {"target_ip": "zero.booth.moe", "version": "0.6.0", "protocol": "v2", "crypt": "tls-rsa", "fileserver_port": 15441, "port_opened": True, "peer_id": "-ZN0060-1RxulSyEiMsj", "rev": 3126, "crypt_supported": []}, "req_id": 0}
////
////        {"cmd": "streamFile", "params": {"inner_path": u"data/users/19mi68FmXwLyDcmkgBB9XMQA2sBMuTB2FA/data.json", "read_bytes": 524288, "file_size": 249, "site": u"1BLogC9LN4oPDcruNz3qo1ysa133E9AGg8", "location": 0}, "req_id": 75}
//
//        try socket.connect(to: "127.0.0.1", port: 15441)
//        print("connected: ", socket.isConnected, socket.isSecure)
//        pollSocket(_socket: socket);
//        print(handshakeMV)
//        try socket.write(from: pack(handshakeMV))
////        try socket.write(from: pack(getFileMV))
//        print(streamFileMV)
//        try socket.write(from: pack(streamFileMV))
//
//
//    }catch let error as NSError{
//        print(error)
//    }
//}


let trackers = [
//    "http://tracker.opentrackr.org:1337/announce",
    "http://explodie.org:6969/announce",
//    "http://tracker1.wasabii.com.tw:6969/announce"
]

let address = "1TaLkFrMwvbNsooF4ioKAY9EuxTBTjipT"
let httpTrackerParams = [
    "info_hash": address.sha1(),
    "peer_id": "dummy_pper", "port": 15443,
    "uploaded": 0, "downloaded": 0, "left": 0, "compact": 1, "numwant": 30,
    "event": "started"
    ] as [String : Any]


let url = "http://tracker.opentrackr.org:1337/announce?uploaded=0&downloaded=0&numwant=30&compact=1&event=started&peer_id=-ZN0060-obXBYFgyrTLX&port=15441&info_hash=%9CG%C1%BF%E7%BF%0D%04P%D6%9A%F2%97%07%A3%DF%8A%81%2A%D8&left=0"
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
