//
//  ViewController.swift
//  CATransform3DExample
//
//  Created by ChanWook Park on 23/07/2020.
//  Copyright © 2020 ChanWookPark. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var greenLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func ResetActionButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.greenLabel.layer.transform = CATransform3DIdentity
        }
    }
    @IBAction func translateChangeActionButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.greenLabel.layer.transform = CATransform3DMakeTranslation(50.0, 50.0, 1.0)
        }
    }
    @IBAction func scaleChangeActionButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.greenLabel.layer.transform = CATransform3DMakeScale(3.0, 2.0, 1.0)
        }
    }
    @IBAction func rotateChageActionButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.greenLabel.layer.transform = CATransform3DMakeRotation(70.0, 0.0, 1.0, 0.0)
        }
    }
    @IBAction func perspectiveChangeActionButton(_ sender: UIButton) {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 300.0
        UIView.animate(withDuration: 0.3) {
            self.greenLabel.layer.transform = CATransform3DRotate(transform, 70.0, 0.0, 1.0, 0.0)
        }
    }

}

