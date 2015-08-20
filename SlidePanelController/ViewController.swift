//
//  ViewController.swift
//  SlidePanelController
//
//  Created by cxl on 15/8/12.
//  Copyright (c) 2015年 c060604. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleLeft(sender: UIButton) {
        sliderController()?.toggleLeftPanel()
    }

    @IBAction func toggleRight(sender: UIButton) {
        sliderController()?.toggleRightPanel()
    }
}

