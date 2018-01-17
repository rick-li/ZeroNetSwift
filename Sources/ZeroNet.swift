//
//  ZeroNetSwift.swift
//  ZeroNetSwift
//
//  Created by Rick Li on 1/15/18.
//

import Foundation


let mainQueue = DispatchQueue(label: "zeronet", qos: .background, attributes: .concurrent)
class ZeroNet : NSObject{
    
    public let rootPath:String
    public let trackers:[String]
    public let sites:[String]
    public let peerId:String
    
    
    public struct Constants {
        static let FILE_PORT: Int = 0 //Can't serve file in ios.
        static let PEER_NUM_WANT: Int = 50
        static let VERSION: String = "0.6.0"
    }
    
    init(rootPath: String, trackers: [String], sites: [String]){
        self.rootPath = rootPath
        self.trackers = trackers
        self.sites = sites
        let id = String.random(length: 12).toBase64()
        self.peerId = "-ZN0\(Constants.VERSION.replacingOccurrences(of: ".", with: ""))-\(id)"
        
        super.init()
    }
    
    func start(){
        for siteAddr in self.sites {
            let site = Site(context: self, siteAddr: siteAddr)
            site.start()
        }
    }
}
