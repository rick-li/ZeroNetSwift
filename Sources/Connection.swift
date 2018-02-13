//
//  TCPConnection.swift
//  LearnSwiftPackageDescription
//
//  Created by Rick Li on 1/7/18.
//

import Foundation
import Socket
import MessagePack

class Stream: NSObject {
    let reqId: UInt16
    let filePath: String
    
    init(reqId: UInt16, filePath:String){
        self.reqId = reqId
        self.filePath = filePath
        super.init()
    }
}

class Request: NSObject {
    let reqId: UInt16
    var message: MessagePackValue
    var data: Data = Data()
    init(reqId: UInt16, message: MessagePackValue){
        self.reqId = reqId
        self.message = message
        super.init()
    }
}

class Connection: NSObject {
    private var context: ZeroNet
    private var currReqId: UInt16 = 0
    //reqId => Stream
    private var waitingStreams:[UInt16: Stream] = [:]
    private var waitingRequests:[UInt16: Request] = [:]
    private let socket: Socket
    private let host: String
    private let port: UInt32
    private let closed: Bool = false
    private var waiting: Bool = false
    private var handshakeReceived: Bool = false
    //Callbacks
    private let onFileDownloaded: (String, Data) -> ()
    
    var connected: Bool {
        return socket.isConnected
    }
    
    init(context: ZeroNet, host: String, port: UInt32, onFileDownloaded: @escaping (String, Data) -> ()) throws {
        self.context = context
        try self.socket =  Socket.create()
        
        self.host = host
        self.port = port
        self.onFileDownloaded = onFileDownloaded
        try self.socket.connect(to: self.host, port: Int32(self.port), timeout: 5 * 1000)
        self.socket.readBufferSize = 4 * 1024
        super.init()
        try self.handshake()
        self.messageLoop(forHanshake: true) //block for handshake response
        self.messageLoop()
    }
    
    func send(site: String, path: String, reqId: UInt16 = 0, location: UInt64 = 0) throws {
        
        self.currReqId = self.currReqId + 1
        
        let _reqId = reqId == 0 ? self.currReqId : reqId
        
        let mv = MessagePackValue(["cmd": "getFile", "params": [
            "inner_path": MessagePackValue(path), "site": MessagePackValue(site), "location": MessagePackValue(location)
            ], "req_id": MessagePackValue(_reqId)])
        if self.waitingRequests[self.currReqId] == nil {
            self.waitingRequests[self.currReqId] = Request(reqId: self.currReqId, message: mv)
        }
        let packedMV = pack(mv)
        try self.socket.write(from: packedMV)
    }
    
    
    func handshake() throws {
        //TODO generate peerId
        let handshakeMV = MessagePackValue(["cmd": "handshake", "params":[
            "target_ip": "zero.booth.moe", "version": "0.6.0", "protocol": "v2", "crypt": "", "fileserver_port": 15441, "port_opened": false, "peer_id": "-ZN0060-1RxulSyEiMsj", "rev": 3126, "crypt_supported": []
            ], "req_id": 0])
        try self.socket.write(from: pack(handshakeMV))
    }
    
    func messageLoop(forHanshake: Bool = false) {
        func shouldStopLoop() -> Bool{
            if forHanshake && handshakeReceived {
                return handshakeReceived || closed
            }
            return closed
        }
        func doMessageLoop() {
            do{
                var savedBytes = Data()
                while !shouldStopLoop() {
                    var buff = Data(capacity: 64 * 1024)
                    let receivedSize = try self.socket.read(into: &buff)
                    if receivedSize < 1 {
                        continue
                    }
                    if(savedBytes.count > 0){
                        savedBytes.append(buff)
                        buff = savedBytes
                    }
                    print("ReceivedSize ", receivedSize)
                    var (message, remainder) : (MessagePackValue, Data)
                    do {
                        try (message, remainder) = unpack(buff)
                        if !message.description.contains("map"){
                            print("Data should always be map, try again with next bytes..")
                            savedBytes.append(buff)
                            continue
                        }else{
                            savedBytes = Data(remainder)
                        }
                    } catch {
                        self.context.logger.log( "Unpack error - waiting for next bytes and try again...", .others)
                        savedBytes = buff
                        continue
                    }
                    savedBytes = Data()
                    print(message)
                    let to = message["to"]?.integerValue
                    let cmd = message["cmd"]?.stringValue
                    let streamBytes = message["stream_bytes"]?.integerValue
                    
                    if cmd != "response" {
                        //in which case we need to handle non "response" message?
                        continue
                    }
                    if to  == Int64(0) {
                        self.handshakeReceived = true
                    }else {
                        if streamBytes != nil {
                            self.handleStream(message: message)
                        } else {
                            try self.handleMessage(message: message)
                        }
                    }
                }
            } catch let error as NSError {
                self.context.logger.log( "Error closing connection.", .failed)
                print("Error", error, " Closing the connection")
            }
        }
        
        if forHanshake { //block handshake
           doMessageLoop()
        } else {
            mainQueue.async {
                doMessageLoop()
            }
        }
    }
    
    func handleMessage(message: MessagePackValue) throws {
        let to = UInt16(truncatingIfNeeded: (message["to"]?.unsignedIntegerValue)!)
        let req = self.waitingRequests[to]
        if message["error"] != nil {
            self.context.logger.log( "Peer returns - " + (message["error"]?.stringValue)!, .others)
            throw ZeroNetError.peerReturnsError
        }
        
        let size = Int(truncatingIfNeeded: (message["size"]?.integerValue)!)
        
        if message["body"] != nil {
            req?.data.append((message["body"]?.dataValue)!)
        }
        
        if (req?.data.count)! >= size {
            let fileInnerPath = req?.message["params"]!["inner_path"]?.stringValue
            self.context.logger.log( "Download completed - " + fileInnerPath!, .fileCompleted)
            self.onFileDownloaded(fileInnerPath!, (req?.data)!)
        }else{
            let newLocation = message["location"]!.unsignedIntegerValue ?? 0
            self.context.logger.log( "request more contents from new location: " + String(newLocation), .others)
            try self.send(site: (req?.message["params"]!["site"]!.stringValue)!, path: (req?.message["params"]!["inner_path"]!.stringValue)!, reqId: (req?.reqId)!, location: newLocation)
        }
    }
    
    func handleStream(message: MessagePackValue) {
//        let streamBytes = message["stream_bytes"]?.integerValue
        
    }
    
    func close() {
        socket.close()
    }
    
}

