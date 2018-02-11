//
//  ViewController.swift
//  ZeroNetExample
//
//  Created by Rick Li on 2/9/18.
//  Copyright © 2018 Rick Li. All rights reserved.
//

import Foundation


import UIKit

class ViewController: UIViewController {
//    @IBOutlet var logCtrl: LogViewController?
    
    let logCtrl:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "logCtrl")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Push
    @IBAction func push() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let siteAddress = "1AUHC6wpgF676cEd8uZX6cU8BucGU4KAP7"
        let rootDir = documentsPath + "/ZeroNetTest/" + siteAddress
        let indexPath = URL(fileURLWithPath: rootDir).appendingPathComponent("index.html").absoluteString
        
        let webVC = SwiftWebVC(urlString: indexPath)
//        webVC.delegate = self
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    // MARK: Modal
    @IBAction func presentLogger() {
        
    self.navigationController?.pushViewController(logCtrl, animated: true)
    }
    
    
}
