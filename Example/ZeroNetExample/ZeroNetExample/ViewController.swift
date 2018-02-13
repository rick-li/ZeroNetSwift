//
//  ViewController.swift
//  ZeroNetExample
//
//  Created by Rick Li on 2/9/18.
//  Copyright © 2018 Rick Li. All rights reserved.
//

import Foundation
import UIKit
import ZeroNetSwiftFramework

class ViewController: UIViewController {
    
    @IBOutlet var logView: UITextView!
    @IBOutlet var downloadBtn: UIButton!
    @IBOutlet var enterBtn: UIButton!
    let siteAddress = "1AUHC6wpgF676cEd8uZX6cU8BucGU4KAP7"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let indexPath = getIndexHtmlPath()
        let url = URL(string: indexPath)
        if FileManager.default.fileExists(atPath: url!.path) {
            enterBtn.isEnabled = true
        } else {
            enterBtn.isEnabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getRootDirPath() -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let rootDir = documentsPath + "/ZeroNetTest/"
        print("Root Dir is " + rootDir)
        return rootDir
    }
    
    func getIndexHtmlPath() -> String {
        let siteDir = getRootDirPath() + siteAddress
        let indexPath = URL(fileURLWithPath: siteDir).appendingPathComponent("index.html").absoluteString
        return indexPath
    }
    
    @IBAction func enterBrowser() {
        let indexPath = self.getIndexHtmlPath()
        
        let webVC = SwiftWebVC(urlString: indexPath)
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    @IBAction func pressDownloadBtn() {
        self.newZeroNet()
        self.downloadBtn.isEnabled = false
    }
    
    func newZeroNet() {
        let fm = FileManager.default
        let rootDir = getRootDirPath()
        var isDir = ObjCBool(true)
        if fm.fileExists(atPath: rootDir, isDirectory: &isDir) {
            do {
                try fm.removeItem(atPath: rootDir)
            } catch {
                print("Failed to delete root dir " + rootDir)
            }
        }
        
        do {
            try fm.createDirectory(atPath: rootDir, withIntermediateDirectories: true)
        } catch {
            print("Failed to create root dir " + rootDir)
        }
        
        let trackers = [
            "http://tracker.opentrackr.org:1337/announce",
            "http://explodie.org:6969/announce",
            "http://tracker1.wasabii.com.tw:6969/announce"
        ]
        
        let z = ZeroNet(rootPath: rootDir, trackers: trackers, sites: [siteAddress])
        
        class Logger : LoggerProtocol {
            var viewCtrl:ViewController
            init(_ viewCtrl:ViewController){
                self.viewCtrl = viewCtrl
            }
            func log(_ str: String, _ status: ZeroNetStatus? = .others) {
                print( String(describing: status) + ": " + str )
                let logView = self.viewCtrl.logView
                let downloadBtn = self.viewCtrl.downloadBtn
                let enterBtn = self.viewCtrl.enterBtn
                DispatchQueue.main.async {
                    
                    if !str.starts(with: "Unpack error") {
                        logView?.text = (logView?.text)! + "\n" + str
                    }
                    
                    let range = NSMakeRange((logView?.text.lengthOfBytes(using: String.Encoding.utf8))!, 0);
                    logView?.scrollRangeToVisible(range);
                }
                let myStatus = status!
                if myStatus == ZeroNetStatus.failed {
                    DispatchQueue.main.async {
                        downloadBtn?.isEnabled = true
                    }
                }
                if myStatus == ZeroNetStatus.siteCompleted {
                    DispatchQueue.main.async {
                        enterBtn?.isEnabled = true
                        downloadBtn?.isEnabled = true
                    }
                }
            }
        }
        z.logger = Logger(self)
        z.start()

    }
    
}
