//
//  Site.swift
//  ZeroNetSwift
//
//  Created by Rick Li on 1/13/18.
//

import Foundation
import Alamofire
import CryptoSwift
import SwiftyJSON

//class ZNFile: NSObject {
//    
//}
enum ZeroNetError: Error {
    case noPeerFound
    case peerReturnsError
}
class Site : NSObject {
    private let context: ZeroNet
    private var siteAddr: String
    private let sitePath: String
//    private var existFiles: [String: ZNFile] = [:]
    private var peerId:String = ""
    private var peerInfos: [PeerInfo] = []
    private var activePeer: Peer? = nil
    private var pendingFileList: [String] = []
    
    init(context: ZeroNet, siteAddr: String){
        self.context = context
        self.siteAddr = siteAddr
        self.sitePath = context.rootPath + "/" + siteAddr
        if !fm.fileExists(atPath: self.sitePath) {
            do {
                try fm.createDirectory(atPath: self.sitePath, withIntermediateDirectories: true)
            } catch {
                context.logger.log("Failed to create site dir " + self.sitePath, .others)
            }
        }
        super.init()
        //TODO load existing files
    }
    
    func start() {
        self.loadPeersFromTracker(trackerIdx: 0, onLoaded: { peerInfos in
            print("Peers loaded - ", peerInfos)
            if peerInfos.count == 0 {
                self.context.logger.log("Can't load any peers... ", .failed)
                return
            }
            self.peerInfos = peerInfos
            func createPeer(index: Int) {
                do {
                    guard let peer = self.createPeerFromPeerInfo() else {
                        self.context.logger.log("None of the peer is accesible - abort. ", .failed)
                        return
                    }
                    self.activePeer = peer
                    try self.activePeer?.requestFile(innerPath: "content.json")
                } catch {
                    self.context.logger.log("Failed to download content.json, discard peer. ", .others)
                    self.activePeer?.discard()
                    createPeer(index: index + 1)
                }
            }
            createPeer(index: 0)
        })
    }
    
    func onFileDownloaded(innerPath: String, data: Data){
        if innerPath == "content.json" {
            let bodyJson = JSON(data: data)
            for (file, _) : (String, JSON) in bodyJson["files"] {
                print(file)
                self.pendingFileList.append(file)
            }
        }
        
        if self.pendingFileList.contains("index.html"){
            self.pendingFileList.insert("index.html", at: 0)
        }
        
        if self.pendingFileList.count != 0 {
            let fileToRequest = self.pendingFileList[0]
            do {
                try self.activePeer?.requestFile(innerPath: fileToRequest)
            }catch{
                self.context.logger.log("Failed to download file - " + fileToRequest, .fileFailed)
            }
            self.pendingFileList = self.pendingFileList.filter({ item in item != innerPath })
        } else {
            self.context.logger.log("!!!=Congratulations=!!! Site \(self.siteAddr) is downloaded.", .siteCompleted)
        }
        
        let filePath = self.sitePath + "/" + innerPath
        let fm = FileManager.default
        let fileUrl = URL(fileURLWithPath: filePath)
        let fileDir = fileUrl.deletingLastPathComponent()
        var isDirectory: ObjCBool = ObjCBool(true)
        if !fm.fileExists(atPath: fileDir.path, isDirectory: &isDirectory) {
            do {
                try fm.createDirectory(at: fileDir, withIntermediateDirectories: true)
            }catch {
                self.context.logger.log("Failed to create file - " + fileUrl.absoluteString, .others)
            }
        }
        fm.createFile(atPath: filePath, contents: data)
    }
    
    func createPeerFromPeerInfo(peerInfoIdx:Int = 0) -> Peer? {
        if(peerInfoIdx >= self.peerInfos.count){
            return nil
        }
        let ip = self.peerInfos[peerInfoIdx].ip
        let port = self.peerInfos[peerInfoIdx].port
        let peer = Peer(context: context, host: ip, port: Int(port), siteAddress: self.siteAddr, onFileDownloaded: self.onFileDownloaded)
        do {
            self.context.logger.log("Creating peer from \(ip):\(port).", .others)
            try peer?.connect()
            return peer
        } catch {
            return createPeerFromPeerInfo(peerInfoIdx: peerInfoIdx + 1)
        }
    }
    
    func loadPeersFromTracker(trackerIdx: Int = 0, onLoaded: @escaping ([PeerInfo]) -> ()) {
        let trackers = context.trackers
        
        //Running out of trakcers
        if trackerIdx >= trackers.count {
            onLoaded([])
            return
        }
        
        let tracker = trackers[trackerIdx]
        
        let url = tracker + "?uploaded=0&downloaded=0&numwant=\(ZeroNet.Constants.PEER_NUM_WANT)&compact=1&event=started&peer_id=-ZN0060-1RxulSyEiMsj&port=\(ZeroNet.Constants.FILE_PORT)&left=0&info_hash=" + String(urlEncodingData: Data(bytes: Digest.sha1(self.siteAddr.bytes)))
        self.context.logger.log("Loading peer from - " + url, .others)
        Alamofire.request(url).response(queue: mainQueue) { response in
            do {
                let bencode = try BEncoder.decodeStringKeyedDictionary(response.data!)
                var peers = PeerInfo.peersInfoFromBinaryModel(bencode["peers"] as! Data)
                peers = peers.filter({ peer in
                    return peer.port != 0
                })
                
                if peers.count == 0 {
                    throw ZeroNetError.noPeerFound
                }
                
                onLoaded(peers)
            } catch let error as NSError {
                print("Failed to load trakcers from " + tracker, " try next one.", error)
                self.loadPeersFromTracker(trackerIdx: trackerIdx + 1, onLoaded: onLoaded)
            }
        }
    }
}
