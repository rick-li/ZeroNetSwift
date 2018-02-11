//
//  LogViewController.swift
//  ZeroNetExample
//
//  Created by Rick Li on 1/17/18.
//  Copyright © 2018 Rick Li. All rights reserved.
//

import Foundation
import UIKit
import ZeroNetSwiftFramework

class LogViewController : UIViewController {
    
    @IBOutlet var logView: UITextView!
    @IBOutlet var downloadBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func pressDownloadBtn() {
        self.newZeroNet()
        
    }
    
    func appendLog(log:String) {
        if (self.logView != nil) {
            self.logView.text = self.logView.text + "\n" + log
        }
        
    }
    
    func newZeroNet() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fm = FileManager.default
        let rootDir = documentsPath + "/ZeroNetTest"
        var isDir = ObjCBool(true)
        print("Root Dir is " + rootDir)
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
        
        var siteAddress = "1AUHC6wpgF676cEd8uZX6cU8BucGU4KAP7"
        
        if (CommandLine.arguments.count > 1) {
            siteAddress = CommandLine.arguments[1]
        }
        //let siteAddress = "1AUHC6wpgF676cEd8uZX6cU8BucGU4KAP7"
        let z = ZeroNet(rootPath: rootDir, trackers: trackers, sites: [siteAddress])
        
        class Logger : LoggerProtocol {
            var logView: UITextView
            init(_ logView: UITextView){
                self.logView = logView
            }
            func log(_ str: String, _ status: ZeroNetStatus? = .others) {
                print( String(describing: status) + ": " + str )
                DispatchQueue.main.async {
                    self.logView.text = self.logView.text + "\n" + str
                    let range = NSMakeRange(self.logView.text.lengthOfBytes(using: String.Encoding.utf8), 0);
                    self.logView.scrollRangeToVisible(range);
                }
            }
        }
        z.logger = Logger(logView)
        z.start()
        
        
    }
}
