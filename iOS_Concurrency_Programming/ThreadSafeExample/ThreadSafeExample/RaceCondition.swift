//
//  RaceCondition.swift
//  ThreadSafeExample
//
//  Created by ChanWook Park on 10/08/2020.
//  Copyright © 2020 ChanWookPark. All rights reserved.
//

import Foundation

enum Solution {
    case barrier
    case semaphore
}

struct RaceCondition {
    private let lamp = Lamp()
}

//MARK: - RaceCondition 발생
extension RaceCondition {
    public func raceConditionOccurs() {
        DispatchQueue.global().async {
            self.lamp.switchOn()
        }
        DispatchQueue.global().async {
            self.lamp.switchOff()
        }
    }
}

//MARK: - 동기(sync)화 솔루션
extension RaceCondition {
    public func synchronization(solution: Solution) {
        switch solution {
        case .barrier:
            barrierSolution()
        case .semaphore:
            semaphoreSolution()
        }
    }
    private func barrierSolution() {
        let concurrentQueue = DispatchQueue(label: "concurrent",
                                        attributes: .concurrent)
        concurrentQueue.async(flags: .barrier) {
            self.lamp.switchOn()
        }
        concurrentQueue.async(flags: .barrier) {
            self.lamp.switchOff()
        }
    }
    private func semaphoreSolution() {
        let semaphore = DispatchSemaphore(value: 1)
        DispatchQueue.global().async {
            semaphore.wait()
            self.lamp.switchOn()
            semaphore.signal()
        }
        DispatchQueue.global().async {
            semaphore.wait()
            self.lamp.switchOff()
            semaphore.signal()
        }
    }
}
