//
//  ZeroNetSwift.swift
//  ZeroNetSwift
//
//  Created by Rick Li on 1/15/18.
//

import Foundation


let mainQueue = DispatchQueue(label: "zeronet", qos: .background, attributes: .concurrent)

public enum ZeroNetStatus : String {
    case fileCompleted, fileFailed, siteCompleted, failed, others
}

public protocol LoggerProtocol {
    func log(_ str: String, _ status: ZeroNetStatus?)
}

class DefaultLogger : LoggerProtocol {
    func log(_ str: String, _ status: ZeroNetStatus? = .others) {
        print( String(describing: status) + ": " + str )
    }
}

public class ZeroNet : NSObject{
    public let rootPath:String
    public let trackers:[String]
    public let sites:[String]
    public let peerId:String
    public var logger:LoggerProtocol = DefaultLogger()
    private var runningSites:[Site] = []
    
    public struct Constants {
        static let FILE_PORT: Int = 0 //Can't serve file in ios.
        static let PEER_NUM_WANT: Int = 50
        static let VERSION: String = "0.6.0"
    }
    
    public init(rootPath: String, trackers: [String], sites: [String]){
        self.rootPath = rootPath
        self.trackers = trackers
        self.sites = sites
        let id = String.random(length: 12).toBase64()
        self.peerId = "-ZN0\(Constants.VERSION.replacingOccurrences(of: ".", with: ""))-\(id)"
        
        super.init()
    }
    
    public func setLogger(logger: LoggerProtocol) {
        self.logger = logger
    }
    
    public func start(){
        for siteAddr in self.sites {
            let site = Site(context: self, siteAddr: siteAddr)
            site.start()
        }
    }
    public func shutdown(){
        for (index, site) in self.runningSites.enumerated() {
            site.stop()
            self.runningSites.remove(at: index)
        }
    }
}
