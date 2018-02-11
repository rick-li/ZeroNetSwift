//
//  ViewController.swift
//  ZeroNetExample
//
//  Created by Rick Li on 1/17/18.
//  Copyright © 2018 Rick Li. All rights reserved.
//

import UIKit

import Socket

class TabViewController: UITabBarController {
    
    var logsCtrl: LogViewController!
    var webviewCtrl: SwiftWebVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logsCtrl = self.viewControllers?.filter({ (ctrl)  in
            return ctrl.title == "Logs"
        })[0] as! LogViewController
        
        self.logsCtrl = logsCtrl
        
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

