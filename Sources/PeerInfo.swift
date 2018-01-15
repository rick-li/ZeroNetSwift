//
//  TorrentPeerInfo.swift
//  BitTorrent
//
//  Created by Ben Davis on 28/06/2017.
//  Copyright © 2017 Ben Davis. All rights reserved.
//

import Foundation

struct PeerInfo {
    let ip: String
    let port: UInt16
    let peerId: Data?
    
    init(ip: String, port: UInt16, peerId: Data?) {
        self.ip = ip
        self.port = port
        self.peerId = peerId
    }
    
    init?(dictionary: [String: Any]) {
        
        guard let ipData = dictionary["ip"] as? Data,
            let ip = String(asciiData: ipData),
            let port = dictionary["port"] as? Int else {
                return nil
        }
        
        self.ip = ip
        self.port = UInt16(port)
        self.peerId = dictionary["peer id"] as? Data
    }
    
    static func peersInfoFromBinaryModel(_ data: Data) -> [PeerInfo] {
        let numberOfPeers = data.count / 6
        var result: [PeerInfo] = []
        for i in 0..<numberOfPeers {
            let ip1 = Int(data.correctingIndicies[i*6])
            let ip2 = Int(data.correctingIndicies[i*6 + 1])
            let ip3 = Int(data.correctingIndicies[i*6 + 2])
            let ip4 = Int(data.correctingIndicies[i*6 + 3])
            let portBytes = [data.correctingIndicies[i*6 + 5], data.correctingIndicies[i*6 + 4]]
            
            let port = UnsafePointer(portBytes).withMemoryRebound(to: UInt16.self, capacity: 1) {
                $0.pointee
            }
            
            let peer = PeerInfo(ip: "\(ip1).\(ip2).\(ip3).\(ip4)", port: port, peerId: nil)
            result.append(peer)
        }
        return result
    }
}

extension PeerInfo: Equatable {
    static func ==(_ lhs: PeerInfo, _ rhs: PeerInfo) -> Bool {
        let peerIdsMatch = (lhs.peerId == nil || rhs.peerId == nil || lhs.peerId == rhs.peerId)
        return (lhs.ip == rhs.ip && lhs.port == rhs.port && peerIdsMatch)
    }
}
