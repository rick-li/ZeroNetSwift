//
//  Peer.swift
//  LearnSwift
//
//  Created by Rick Li on 1/13/18.
//

import Foundation

class Peer : NSObject {
    private var isContentJsonFound = false
    private var host: String
    private var port: Int
    
    init(host:String, port: Int) {
        self.host = host
        self.port = port
        super.init()
    }
    
    
    
}
