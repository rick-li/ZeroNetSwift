//
//  BrowserViewController.swift
//  ZeroNetExample
//
//  Created by Rick Li on 1/17/18.
//  Copyright © 2018 Rick Li. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class BrowserViewController : UIViewController {
    @IBOutlet var webView: WKWebView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let siteAddress = "1AUHC6wpgF676cEd8uZX6cU8BucGU4KAP7"
        let rootDir = documentsPath + "/ZeroNetTest/" + siteAddress
        var indexPath = URL(fileURLWithPath: rootDir).appendingPathComponent("index.html").absoluteString
        var targetURL = URL(fileURLWithPath: indexPath)
        webView.load(URLRequest( url: URL(string: indexPath)!))

    }
}
