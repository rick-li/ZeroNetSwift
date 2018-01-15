//
//  Peer.swift
//  LearnSwift
//
//  Created by Rick Li on 1/13/18.
//

import Foundation
import MessagePack


class Peer : NSObject {
    private var isContentJsonFound = false
    private var host: String
    private var port: Int
    private var siteAddress: String
    private var conn: Connection? = nil
    private var onFileDownloaded: ((String, Data) -> ())
    
    init?(host:String, port: Int, siteAddress: String, onFileDownloaded: @escaping (String, Data) -> ()) {
        self.host = host
        self.port = port
        self.siteAddress = siteAddress
        self.onFileDownloaded = onFileDownloaded
        super.init()
    }
    
    func connect() throws {
        try self.conn = Connection(host: host, port: UInt32(port),
                onFileDownloaded: self.onFileDownloaded)
    }
    
    func requestFile(innerPath: String) throws {
        try self.conn?.send(site: self.siteAddress, path: innerPath)
    }
    
    func discard(){
        self.conn?.close()
    }
}
