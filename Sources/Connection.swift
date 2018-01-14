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
    private var currReqId: UInt16 = 0
    //reqId => Stream
    private var waitingStreams:[UInt16: Stream] = [:]
    private var waitingRequests:[UInt16: Request] = [:]
    private let socket: Socket
    private let host: String
    private let port: UInt32
    private let closed: Bool = false
    private var waiting: Bool = false
    
    //Callbacks
    private let onHandshakeReceived: (Connection, MessagePackValue) -> Void
    private let onFileDownloaded: (Connection, Request) -> Void
    
    var connected: Bool {
        return socket.isConnected
    }
    
    init(host: String, port: UInt32, onHandshakeReceived: @escaping (Connection, MessagePackValue) -> Void, onFileDownloaded: @escaping (Connection, Request) -> Void) throws {
        try self.socket =  Socket.create()
        
        self.host = host
        self.port = port
        self.onHandshakeReceived = onHandshakeReceived
        self.onFileDownloaded = onFileDownloaded
        
        try self.socket.connect(to: self.host, port: Int32(self.port))
        self.socket.readBufferSize = 4 * 1024
        try self.socket.setBlocking(mode: true)
        super.init()
        try self.handshake()
        self.messageLoop()
    }
    func requestFile(site: String, path: String, reqId: UInt16 = 0, location: UInt64 = 0) throws {
        
        self.currReqId = self.currReqId + 1
        
        let _reqId = reqId == 0 ? self.currReqId : reqId
        
        let fileMV = MessagePackValue(["cmd": "getFile", "params": [
            "inner_path": MessagePackValue(path), "site": MessagePackValue(site), "location": MessagePackValue(location)
            ], "req_id": MessagePackValue(_reqId)])
        if self.waitingRequests[reqId] == nil {
            self.waitingRequests = [self.currReqId : Request(reqId: self.currReqId, message: fileMV)]
        }
        
        try self.send(message: fileMV)
        
        
    }
    func send(message: MessagePackValue) throws {
        try self.socket.write(from: pack(message))
    }
    
    func handshake() throws {
        //TODO generate peerId
        let handshakeMV = MessagePackValue(["cmd": "handshake", "params":[
            "target_ip": "zero.booth.moe", "version": "0.6.0", "protocol": "v2", "crypt": "", "fileserver_port": 15441, "port_opened": false, "peer_id": "-ZN0060-1RxulSyEiMsj", "rev": 3126, "crypt_supported": []
            ], "req_id": 0])
        try self.socket.write(from: pack(handshakeMV))
    }
    
    func messageLoop() {
        do{
            var savedBytes = Data()
            while !self.closed {
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
                    print("Unpack error - waiting for next bytes and try again...")
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
                    self.onHandshakeReceived(self, message)
                    
                }else {
                    if streamBytes != nil {
                        self.handleStream(message: message)
                    } else {
                      try self.handleMessage(message: message)
                    }
                }
            }
        } catch let error as NSError {
            print("Error", error, " Closing the connection")
        }
        self.close()
    }
    
    func handleMessage(message: MessagePackValue) throws {
        let to = UInt16(truncatingIfNeeded: (message["to"]?.unsignedIntegerValue)!)
        let req = self.waitingRequests[to]
        let size = Int(truncatingIfNeeded: (message["size"]?.integerValue)!)
        
        
        if message["body"] != nil {
            req?.data.append((message["body"]?.dataValue)!)
        }
        
        if (req?.data.count)! >= size {
            
            let fileInnerPath = req?.message["params"]!["inner_path"]?.stringValue
            
            let filePath = ROOT_PATH + fileInnerPath!
            
            let fm = FileManager.default
            let fileUrl = URL(fileURLWithPath: filePath)
            let fileDir = fileUrl.deletingLastPathComponent()
            var isDirectory: ObjCBool = ObjCBool(true)
            if !fm.fileExists(atPath: fileDir.path, isDirectory: &isDirectory) {
                try fm.createDirectory(at: fileDir, withIntermediateDirectories: true)
            }
            fm.createFile(atPath: filePath, contents: req?.data)
            self.onFileDownloaded(self, req!)
            
            print("Download completed - ", filePath)
        }else{
            let newLocation = message["location"]!.unsignedIntegerValue ?? 0
            print("request more contents from new location: ", newLocation)
            try self.requestFile(site: (req?.message["params"]!["site"]!.stringValue)!, path: (req?.message["params"]!["inner_path"]!.stringValue)!, reqId: (req?.reqId)!, location: newLocation)
        }
    }
    
    func handleStream(message: MessagePackValue) {
//        let streamBytes = message["stream_bytes"]?.integerValue
        
    }
    
    func close() {
        socket.close()
    }
    
}

