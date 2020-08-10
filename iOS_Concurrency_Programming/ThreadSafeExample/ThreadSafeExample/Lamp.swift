//
//  Lamp.swift
//  ThreadSafeExample
//
//  Created by ChanWook Park on 10/08/2020.
//  Copyright © 2020 ChanWookPark. All rights reserved.
//

import Foundation

final class Lamp {
    private enum LampState {
        case on
        case off
    }
    
    private var lampState: LampState = .off
    
    func switchOn() {
        lampState = .on
        print("switchOn", "lamp state: \(self.lampState)")
    }
    func switchOff() {
        lampState = .off
        print("switchOff", "lamp state: \(self.lampState)")
    }
}
