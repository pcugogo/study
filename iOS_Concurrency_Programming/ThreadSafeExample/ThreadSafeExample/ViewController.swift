//
//  ViewController.swift
//  ThreadSafeExample
//
//  Created by ChanWook Park on 10/08/2020.
//  Copyright © 2020 ChanWookPark. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    let raceCondition = RaceCondition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        raceCondition.synchronization(solution: .barrier)
    }
}

