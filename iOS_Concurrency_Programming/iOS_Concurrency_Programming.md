# iOS 동시성 프로그래밍

## GCD (Grand Central Dispatch)

### GCD란?

- 멀티 코어 프로세스를 위한 멀티스레딩 기술이다.
- 코어 갯수 등 시스템 조건이 변함에 따라 해당 수를 동적으로 작성하고 조정하는 스레드 수를 결정해야하는 일을 대신 처리해준다.
- 스레드에 대한 복잡한 관리를 보다 쉽게 처리할 수 있게 해준다.

### DispatchQueue

- 사용자 지정 작업을 실행하기 위한 저수준 c기반 관리 방식이다.
- GCD 기술의 일부이다.
- DispatchQueue에 작업을 직렬, 동시, 동기, 비동기, 작업 우선순위 등을 정해서 추가하기만 하면 작업을 스레드로 적절하게 분산하여 실행한다.

## 동기와 비동기 작업

### 동기 (synchronous)

- 작업이 **완료 되면** 다음 작업을 실행
 - sync 처리를 하면 현재 스레드는 작업이 완료 될때까지 블럭 되었다가 작업이 완료 되면 다음 작업을 실행한다.

### 비동기 (asynchronous)

- 작업을 **시작하고 바로** 다음 작업을 시작한다.

## SerialQueue(직렬 큐)와 ConcurrentQueue (동시성 큐)
### SerialQueue

- 작업을 한개의 스레드에서 순서대로 처리하게 한다.

### ConcurrentQueue

- 작업을 두개 이상의 스레드로 분산하여 동시에 처리하게 한다.

## Queue의 종류

### Main
- SerialQueue
- 메인스레드(Thread1)로 보내 작업한다.
- UI 관련 작업은 메인 큐에서 실행해야한다.
- 디스패치 큐 작성을 하지 않은 코드는 main queue에서 sync하게 작동된다. 

-> 디스패치큐 작성을 하지 않은 상태에서 main.async {} 작성을 하게 되면 해당 작업은 메인스레드에서 메인큐로 갔다가 다시 메인스레드로 가게되는 데, 앞에 작업이 있었다면 앞 작업의 다음 순서로 실행되게 된다.

### Global
- ConcurrentQueue
- 작업이 여러 스레드에서 동시에 처리되기 때문에 작업의 완료 순서가 정해져 있지 않다.
- QOS를 설정 가능 하다.

### Custom

```
convenience init(label: String, 
                 qos: DispatchQoS = .unspecified, 
                 attributes: DispatchQueue.Attributes = [], 
                 autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency = .inherit, 
                 target: DispatchQueue? = nil)
```
- label 라벨 기능이 있어 이름을 작성할 수 있다.
- qos를 설정할 수 있다.
- attributes에 큐의 속성을 입력할 수 있다.
- autoreleaseFrequency는 대기열이 예약한 블럭에 의해 생성된 객체를 메모리에서 자동으로 해제하는 빈도이다.
- 기본 설정은 SerialQueue 이다.

## QOS (Quality Of Service)
### 작업에 적용 할 서비스 품질 또는 실행 우선 순위

우선순위가 높은 작업은 우선순위가 낮은 작업보다 더 빠르다 그렇지만 많은 자원이 사용되므로 일반적으로 우선순위가 낮은 작업보다 많은 에너지(배터리)가 필요하다. 작업에 따른 적합한 QOS 처리를 하면 앱의 반응이 빨라지고 에너지 효율도 증가한다.

#### QOS 종류

우선순위 순으로 나열되었으며 userInteractive의 우선 순위가 가장 높다

- userInteractive
 - 메인스레드에서 작업을 실행
 - 애니메이션, UI 업데이트와 같은 사용자와 상호 작용하는 작업을 실행할 때 사용
- userInitiated
 - 응답성(속도) 과 성능 (다른 작업을 방해하지 않음)이 중요한 작업을 실행할때 사용 (저장된 문서를 빠르게 불러와야 할 때)
 - 응답성과 성능에 중점을 두는 작업인 만큼 에너지 소모는 클 것이다.
 - 몇 초 또는 그 이하의 시간이 걸리는 작업을 처리할 때 사용
- default
 - 기본 설정 
- utility
 - 인디케이터가 실행되거나 진행률이 표시되는 완료 하는데 시간이 걸리는 지속적인 작업을 실행할때 사용
 - 응답성과 성능 에너지 효율성간의 균형을 제공
 - 몇 초에서 몇 분이 걸리는 작업을 실행할 때 사용
- background
 - 동기화 및 백업과 같은 사용자에게 보이지 않는 작업을 실행할 때 사용
 - 에너지 효율에 중점을 둔다.
 - 몇 분에서 시간이 걸리는 상당한 시간 지속되는 작업을 실행할 때 사용
 
## DispatchGroup

동일한 큐 또는 다른 큐의 비동기 처리를 **그룹화**하고 모든 작업이 **완료되면 그룹은 notify의 completion handler를 실행한다.** 그룹의 모든 작업이 완료 될 때까지 동기적으로 기다릴 수 있다. 
 
```
let dispatchGroup = DispatchGroup()

//작업들을 그룹화한다.
DispatchQueue.global().async(group: dispatchGroup) { networking1 }
DispatchQueue.global().async(group: dispatchGroup) { networking2 }
DispatchQueue.main.async(group: dispatchGroup) { task }

//dispatchGroup의 작업들이 모두 실행 완료되면 notify의 completion handler가 설정한 큐에서 실행된다.
dispatchGroup.notify(queue: DispatchQueue.main) { indicator off & ui update }
```

### DispatchGroup Methods

### 완료 처리
- func notify()
 - 현재 그룹의 모든 작업 실행이 완료되면 지정된 큐에 완료 작업을 큐에 제출하도록 예약한다.

### 작업이 완료 되기를 대기
- func wait()
 - 제출 된 작업이 완료 될 때까지 **동기적으로** 대기합니다.
 - 작업이 완료 되지않으면 리턴하지 않는 다.
- func wait(timeout: DispatchTime) -> DispatchTimeoutResult
 - 제출된 작업이 완료 될 때까지 **동기적으로** 대기하고 지정된 제한 시간이 경과하기 전에 작업이 완료되지 않은 경우 리턴합니다.


### 그룹 상태를 수동으로 업데이트
- func enter()
 - 작업이 그룹에 진입했음을 명시적으로 나타낸다.
- func leave()
 - 그룹의 작업이 실행 완료 했음을 명시적으로 나타낸다. 

```
// enter와 leave의 갯수가 같으면 완료 (notify completion handler 실행)
dispatchGroup.enter()
let okButton = UIAlertAction(title: "OK", style: .cancel) { _ in
    dispatchGroup.leave()
}
```

## DispatchSemaphore
제한된 갯수의 작업만 실행할 수 있도록 할 수 있다. 남은 **자원의 수가 0보다 낮으면** signal이 실행되어 자원 수가 증가할때까지 **스레드가 블럭**된다.

```
let semaphore = DispatchSemaphore(value: 2) // 사용 가능한 자원 수를 제한

semaphore.wait() // 사용 가능한 자원 수 1 감소
DispatchQueue.global().async {
    semaphore.signal() // 사용 가능한 자원 수 1 증가
}
```

## Dispatch Barrier
- 동시성 디스패치큐에 배리어를 추가하면 큐는 이전에 제출 된 모든 작업이 실행을 마칠 때까지 배리어 블럭(및 배리어 추가 이후에 제출 된 모든 작업)의 실행을 지연(스레드를 블럭)시킨다. 
- 이전 작업이 실행을 마치면 큐는 배리어 블럭의 작업을 실행한다. 배리어 블럭이 완료되면 큐가 다시 동작한다.

```
DispatchQueue.global().async(flags: .barrier) { task }
```

## 스레드가 안전하지 못한 상황들

### 교착 상태 (DeadLock)
- 스레드가 작업이 완료 되길 기다리고 작업은 스레드의 블럭이 풀리길 서로 기다리는 상태
 - -> 해당 스레드는 아무 작업도 진행하지 못한다.
- 현재 큐와 같은 큐로 작업을 보낼 때 동기 처리를 하면 안된다.
- 예를 들어 globalQueue 작업중에 globalQueue.sync 작업을 실행하게 되면 먼저 현재 스레드가 sync작업을 기다리기 위해 블럭 되고 sync 작업은 큐로 갔다가 스레드로 가게 되는 데 이때 블럭이 되어 있는 기존 스레드로 돌아가게 되면 서로 기다리게 되는 상황이 발생한다.

### 경쟁 상태 (Race Condition)
- 여러 스레드에서 동일한 리소스에 동시에 값을 읽기, 쓰기하는 상황일 경우 한 스레드가 다른 스레드의 변경 사항을 덮어 쓰게 되어 예상하지 못한 결과를 얻게 될 수 있다. 이런 상황을 경쟁 상태라고 한다.

#### 경쟁 상태 해결 방법
- Tsan (Thread Sanitizer) 툴을 이용하면 경쟁상태를 체크할 수 있다.

1. 경쟁 상태가 발생하지 않도록 코드와 데이터 구조를 설계를 한다. 
  - 예를 들어 공유 속성을 Read Only(불변)로 생성한다던가 순수 함수 사용 등등의 여러 방법이 있다.
  
2. DispatchBarrier와 같은 동기화 도구들을 사용해 리소스에 동기적으로 접근하도록 한다.
 - 여러 유용한 동기화 도구가 있지만, 성능에 영향을 끼친다. 특정 리소스에 높은 경쟁이 발생하면 스레드가 오래 대기할 수 있다. 그렇기 때문에 **동기화가 필요하지 않도록 설계를 하는 것이 최상의 해결방법이라고 한다.**

### 우선 순위 역전 (Priority Inversion)
- 우선순위가 높은 작업이 우선순위가 낮은 작업에 종속 되거나 우선순위가 낮은 작업의 결과가 되면 우선순위역전이 발생한다. 결과적으로 blocking, spinning 그리고 polling이 발생 할 수 있다. 
 
## 참고 자료
### [Apple Doc - Concurrency Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/ConcurrencyandApplicationDesign/ConcurrencyandApplicationDesign.html#//apple_ref/doc/uid/TP40008091-CH100-SW1)

### [Apple Doc - Energy Efficiency Guide](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/PrioritizeWorkWithQoS.html)

### [Apple Doc - Threading Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/ThreadSafety/ThreadSafety.html)

### [medium - iOS Concurrency](https://medium.com/@chetan15aga/ios-concurrency-underlying-truth-1021a0bb2a98)

