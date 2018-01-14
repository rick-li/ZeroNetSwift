//
//  Site.swift
//  LearnSwift
//
//  Created by Rick Li on 1/13/18.
//

import Foundation
import Alamofire
import CryptoSwift

class ZNFile: NSObject {
    
}
enum PeerError: Error {
    case noPeerFound
}
class Site : NSObject {
    private var siteAddr:String
    private var existFiles: [String: ZNFile] = [:]
    private var peerId:String = ""
    
    init(siteAddr: String){
        self.siteAddr = siteAddr
        super.init()
        //TODO load existing files
    }
    
    func loadPeersFromTracker(trackerIdx: Int = 0, onLoaded: @escaping ([TorrentPeer]) -> ()) {
        
        let trackers = [
            "http://tracker.opentrackr.org:1337/announce",
            "http://explodie.org:6969/announce",
            "http://tracker1.wasabii.com.tw:6969/announce"
        ]
        
        let httpTrackerParams = [
            "info_hash": String(urlEncodingData: Data(bytes: Digest.sha1(siteAddress.bytes))),
            "peer_id": "-ZN0060-obXBYFgyrTLX", "port": 15443,
            "uploaded": 0, "downloaded": 0, "left": 0, "compact": 1, "numwant": 30,
            "event": "started"
        ] as [String : Any]
        
        let tracker = trackers[trackerIdx]
        let url = tracker + "?uploaded=0&downloaded=0&numwant=30&compact=1&event=started&peer_id=-ZN0060-obXBYFgyrTLX&port=15441&left=0&info_hash=" + String(urlEncodingData: Data(bytes: Digest.sha1(siteAddress.bytes)))
        
        print("Loading peer from - ", url)
        Alamofire.request(url).response(queue: queue) { response in
            do {
                let bencode = try BEncoder.decodeStringKeyedDictionary(response.data!)
                var peers = TorrentPeer.peersInfoFromBinaryModel(bencode["peers"] as! Data)
                peers = peers.filter({ peer in
                    return peer.port != 0
                })
                onLoaded(peers)
                if peers.count == 0 {
                    throw PeerError.noPeerFound
                }
            } catch let error as NSError {
                print("Failed to load trakcers from " + tracker, " try next one.", error)
                self.loadPeersFromTracker(trackerIdx: trackerIdx + 1, onLoaded: onLoaded)
            }
        }
    }
}
