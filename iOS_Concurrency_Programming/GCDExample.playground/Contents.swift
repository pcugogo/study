import UIKit

//print("==============================\n동기, 비동기\n==============================")
////동기 비동기 테스트
//// async를 사용 했기 때문에 task 1을 실행 시키고 바로 다음 작업 (task2)를 수행한다
//DispatchQueue.global().async {
//    //task 1
//    for i in 10...15 {
//        print("동기, 비동기 task 1, \(i)")
//    }
//}
//// sync를 사용하였기때문에 task2가 완료 될때까지 메인스레드의 다음 작업(task 3)을 실행하지 않는다.
//DispatchQueue.global().sync {
//    //task 2
//    for i in 200...205 {
//        print("동기, 비동기 task 2, \(i)")
//    }
//}
//// task 2가 완료 되어 리턴할때까지 메인스레드에서 대기한다. (task 2가 리턴해야 현재 줄로 내려온다.)
//print("task 2 끝났다!")
//DispatchQueue.global().sync {
//    //task 3
//    for i in 3000...3100 {
//        print("동기, 비동기 task 3, \(i)")
//    }
//}
//print("==============================\n직렬 작업\n==============================")
//let serialQueue = DispatchQueue(label: "Serial") //스레드 하나에서 직렬로 처리한다. 작업을 순서대로 실행한다.
//serialQueue.async {
//    //task 1
//    for i in 10...15 {
//        print("Serial task 1, \(i)")
//    }
//}
//serialQueue.async {
//    //task 2
//    for i in 200...205 {
//        print("Serial task 2, \(i)")
//    }
//}
//serialQueue.sync {
//    //task 3
//    for i in 3000...3005 {
//        print("Serial task 3, \(i)")
//    }
//}
//print("==============================\n동시 작업\n==============================")
//let concurrentQueue = DispatchQueue.global() //여러개의 스레드에서 동시에 작업을 처리 한다.
//concurrentQueue.async {
//    //task 1
//    for i in 10...15 {
//        print("Concurrent task 1, \(i)")
//    }
//    print(Thread.current)
//}
//concurrentQueue.async {
//    //task 2
//    for i in 200...205 {
//        print("Concurrent task 2, \(i)")
//    }
//    print(Thread.current)
//}
//concurrentQueue.async {
//    //task 3
//    for i in 3000...3005 {
//        print("Concurrent task 3, \(i)")
//    }
//    print(Thread.current)
//}

print("==============================\n순서 테스트\n==============================")

let testSerialQueue = DispatchQueue(label: "TestSerial")

testSerialQueue.async {
    //task 1
    sleep(2)
    for i in 10...15 {
        print("순서 테스트 task 1, \(i)")
    }
}
DispatchQueue.global().sync {
    //task 2
    for i in 20...25 {
        print("순서 테스트 task 2, \(i)")
    }
}
DispatchQueue.global().async {
    //task 3
    for i in 30...35 {
        print("순서 테스트 task 3, \(i)")
    }
}
testSerialQueue.async {
    //task 4
    for i in 40...45 {
        print("순서 테스트 task 4, \(i)")
    }
}
DispatchQueue.global().async {
    //task 5
    for i in 50...55 {
        print("순서 테스트 task 5, \(i)")
    }
}

//task2가 가장 먼저 작업을 완료한다.
//task2는 sync 작업이기 때문에 task3, 5는 task2의 작업이 완료된 후에 실행된다.
//task3 과 task5 둘 중 어느 작업이 먼저 완료 될지 알 수 없다.
//task1은 2초간 슬립하기 때문에 task3 or task5 다음으로 완료된다.
//task4는 testSerialQueue가 직렬 큐이기 때문에 대기열에 먼저 들어간 task1이 완료된 후에 실행된다.
