## Swift 메모리 관리

## ARC (Automatic Reference Counting)

- 앱의 메모리 사용을 관리하기 위해 사용되며, 참조 카운트를 자동으로 관리해주고 더이상 사용 되지않는 객체를 메모리에서 해제한다.
- 컴파일 시 코드를 분석하여 retain(카운트 증가), release(카운트 감소) 코드를 생성하여 참조를 관리해준다.

## Reference Counting
### 카운트의 증가
- 객체를 생성하거나 참조하면 참조 카운트가 1 증가한다. (힙 영역에 저장된 인스턴스의 주소 값이 스택 영역(변수)에 할당 된다.)
- 기본적으로 인스턴스를 생성하거나 참조하는 코드들은 강한 참조를 하고 참조 카운트가 증가한다.
- weak(약한 참조), unowned(미소유 참조) 키워드를 붙여주면 참조 카운트가 증가하지 않는다.

### 카운트의 감소
- 참조 변수에 nil이 할당되거나, 클래스의 멤버 변수일 경우 해당 클래스가 메모리에서 해제될 때, 지역 변수일 경우 해당 함수의 스코프가 종료 될 때 등 해당 변수가 메모리에서 해제(스택 영역에 저장된 주소 값이 해제 됨) 되면 참조 카운트가 감소한다.
- 참조 카운트가 0이 되면 객체의 메모리가 즉시 해제된다.

# 강한 순환 참조
두 객체간 강한 참조로 인해 참조카운트가 여러개 증가 되었을 때 nil을 할당하여 메모리를 해제하려해도 참조카운트가 남고, 이에 대한 참조가 없으므로 해제 할 방법이 없어 메모리가 해제되지 않는 상태

```swift
class AClass {
    var referenceB: BClass?
    deinit {
        print("A is deinit")
    }
}

class BClass {
    var referenceA: AClass?
    deinit {
        print("B is deinit")
    }
}
 
// 1.
var objectA: AClass? = AClass()
var objectB: BClass? = BClass() 

// 2.
objectA?.referenceB = objectB 
objectB?.referenceA = objectA 

// 3. 
objectA = nil 
objectB = nil
```

1. 객체화하면서 AClass인스턴스, BClass인스턴스에 대한 참조카운트가 각각 1이 된다.
2. 참조카운트가 1씩 추가로 증가하여 각각 참조카운트가 2가 된다.
3. objectA, B에 nil을 입력하였을 때 참조 카운트가 각각 1씩 감소하지만 referenceA, B의 참조 카운트가 1씩 남게 되므로 메모리 해제가 되지 않는다. objectA, B의 참조는 이미 해제(스택에 할당된 인스턴스 주소값 해제)되었으므로 더이상 referentceA, B에 접근하여 메모리를 해제시킬 방법이 없다.

이런 상황을 메모리 누수(Memory Leak)라고 표현한다.

# 강한 순환 참조 해결방안

## weak (약한 참조)

- 하나의 참조 속성 앞에 weak를 붙여주면 약한참조를 하게되며, **참조카운트가 증가하지 않는다.**
- 옵셔널 타입으로만 생성된다. 참조하던 객체가 메모리에서 해제되면 nil이 된다.

```swift
class AClass {
    var referenceB: BClass?
    deinit {
        print("A is deinit")
    }
}

class BClass {
    weak var referenceA: AClass? //약한 참조
    deinit {
        print("B is deinit")
    }
}
 
var objectA: AClass? = AClass() // 참조 카운트 1 증가
var objectB: BClass? = BClass() // 참조 카운트 1 증가

// 1.
objectA?.referenceB = objectB // AClass(): 1, BClass(): 2 BClass 인스턴스 참조카운트 1 증가

// 2.
objectB?.referenceA = objectA // AClass(): 1, BClass(): 2 weak referenceA로 인해 AClass 인스턴스 참조 카운트 증가 하지않음

// 3. 
objectA = nil // AClass(): 0, BClass(): 1 AClass 인스턴스 참조카운트 1 감소, BClass 인스턴스 참조카운트 1 감소

// 4.
objectB = nil // AClass(): 0, BClass(): 0 BClass 인스턴스 참조카운트 1 감소
```
1. referenceB의 참조로 인해 BClass 인스턴스에 대한 참조카운트가 1 증가 한다.
2. referenceA의 weak 키워드로 인해 AClass 인스턴스에 대한 참조카운트가 증가하지 않는다.
3. 
 - objectA에 nil이 할당 되어 AClass 인스턴스에 대한 참조카운트가 1 감소하여 카운트가 0이 되고 AClass 인스턴스가 메모리에서 해제된다. 
 - objectA의 프로퍼티 referenceB의 참조도 해제되어 BClass 인스턴스에 대한 참조카운트가 1 감소하게 된다.
4. objectB에 nil이 할당되고 BClass 인스턴스 참조카운트는 0이 되어 BClass 인스턴스도 메모리에서 해제된다.


## unowned(미소유 참조)
- unowned 라는 키워드를 속성 선언 앞에 붙여서 선언할 수 있는데 weak와 마찬가지로 참조카운트가 증가하지 않으며 반드시 값이 있다고 보장할 때 사용할 수 있다. (메모리 해제 시에도 메모리 주소 값을 가지고 있다.) 
- 객체간의 의존성이 있을 때 사용하면 적절한데, 예를 들어 신용카드와 사용자라고 하는 객체를 만든다고 가정할때 사용자의 정보가 없으면 신용카드를 만들 수 없기때문에 신용카드 객체는 반드시 사용자 객체의 데이터가 있어야한다. 이런 경우를 신용카드 객체는 사용자 객체에 의존한다고 하며 반드시 있어야하는 사용자 객체에 unowned를 붙여줄 수 있다.

## 클로저의 강한 참조

클로저도 참조 형식이기때문에 강한 참조가 일어나고 메모리 누수 상태에 빠질 수 있다.
클래스 객체의 self(자신)를 캡쳐한 클로저가 끝나지않는 상황이 되었을 때 
해당 객체는 메모리가 해제되지 않아 메모리누수 상태가 된다.
이를 해결하기 위해 클로저의 캡쳐 리스트를 사용할 수 있다.
클로저 블록 { } 안의 대괄호 [ ] 사이에 weak 혹은 unowned 키워드를 써주고 캡쳐대상들을 쉼표로 분리해서 나열해주면 캡쳐 대상을 약한 참조 또는 미소유 참조 상태로 사용할 수 있게 된다.

ex) [weak self, unowned value]
