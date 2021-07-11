//
//  ViewController.swift
//  ShadowExample
//
//  Created by ChanWook Park on 2021/07/11.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        
        innerView.clipsToBounds = true
    }
    
    @IBAction func shadowOffsetChangeSliderValue(_ sender: UISlider) {
        containerView.layer.shadowOffset = CGSize(width: Int(sender.value), height: Int(sender.value))
    }
    @IBAction func containerRadiusChageSliderValue(_ sender: UISlider) {
        innerView.layer.cornerRadius = CGFloat(sender.value)
        print(containerView.layer.shadowRadius)
    }
}

