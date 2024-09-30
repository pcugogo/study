## SwiftUI가 우리 코드를 볼 때 보는 것들

- identitiy, lifetime, dependencies
    - identity: SwiftUI가 앱의 여러 업데이트에서 elements를 동일하게 또는 구별되게 인식하는 방법
    - lifetime: SwiftUI가 시간이 지남에 따라 뷰와 데이터의 존재를 추적하는 방법
    - dependencies: SwiftUI가 인터페이스를 업데이트해야 하는 시기와 이유를 이해하는 방법
    - 이 세가지 개념은 SwiftUI가 변경해야할 사항, 방법, 시기를 결정하여 화면에 표시되는 동적 사용자 인터페이스를 만드는 방법을 알려준다.
## Identity

먼저 SwiftUI의 identity를 이야기하기 전에 근본적으로 identity의 의미에 대해 알아보자.  
이해하기 위해 똑같이 생긴 두 강아지의 사진이 있다고 가정해보자. 두 사진만 보고는 같은 개인지 아닌지 정보가 부족하여 알 수가 없다. **_사물이 같은지 다른지에 대한 이 질문은 우리가 Identity라고 부르는 것의 핵심_**이다. 이 Identity는 SwiftUI가 앱을 이해하는 방법의 중요한 측면이기도 하다.

다음으로 화면의 아무 곳이나 탭하면 좋은 상태와 나쁜 상태를 전환할 수 있는 앱이 있다고 가정해보자.

![[Identity_1.png]]

발바닥 아이콘들을 보면서 이 두 가지가 서로 완전히 다른 뷰인지, 아니면 같은 뷰지만 다른 위치와 색상으로 표현된 것인지에 대한 구분은 실제로 매우 중요하다. 왜냐하면 **_인터페이스가 한 상태에서 다른 상태로 전환되는 방식에 영향_**을 주기 때문이다.

해당 아이콘들이 서로 **다른 뷰**라면 아이콘이 **fade in 및 fade out**과 같이 **독립적**으로 전환되어야 함을 의미한다. (각자 다른 위치에서 페이드 인, 아웃으로 노출되고 숨겨짐)

만약 두 아이콘이 **같은 뷰**라면 아이콘이 **위 아래로 슬라이딩**하며 애니메이션 되어야 한다는 것을 의미한다.

따라서 서로 다른 상태 간의 뷰를 연결하는 것은 중요하다. 이는 SwiftUI가 이들 간의 전환 방법을 이해하는 방식이기 때문이다. 이것이 view identity의 핵심 개념이다.

같은 identity을 공유하는 뷰는 동일한 UI 요소의 서로 다른 상태를 나타낸다.

![[Identity_2.png]]

대조적으로 별개의 UI 요소를 나타내는 뷰는 항상 다른 ID를 갖는다.
![[Identity_3.png]]

코드에서 identity가 어떻게 표현되는지 살펴보자. SwiftUI에서 사용되는 두 가지 타입의 identity가 있다. 명시적 identity와 구조적 identity다.

### 명시적 identity

- 명시적인 Identity (Explicit identity): **사용자 정의 또는 데이터 기반 ID**를 사용한다.
    - 명시적인 Identity의 한 형태는 UIKit 및 AppKit 전체에서 사용되는 포인터 identity다. UIView나 NSView는 class이므로 각각 메모리에 할당에 대한 고유 포인터를 갖는다. 포인터를 사용하여 개별 뷰를 참조할 수 있으며, 두 뷰가 동일한 포인터를 공유하는 경우 실제로 동일한 뷰임을 보장한다.
    - 그러나 SwiftUI 뷰는 일반적으로 class 대신 struct로 표현되는 값 타입이기때문에 SwiftUI는 포인터를 사용하지 않는다.
    - SwiftUI가 View에 클래스 대신 값 타입을 사용하는 이유에 대해 논의하는 내용은 2019년 SwiftUI essentials 에서 확인할 수 있다.
    - 현재 알아야할 중요한 점은 값 타입에는 SwiftUI가 해당 뷰에 대한 지속적인 ID로 사용할 수 있는 정식 참조가 없다는 것이다. 대신 SwiftUI는 다른 형태의 명시적 Identity에 의존한다.
    - 명시적 identity 사용하면 뷰의 ID를 데이터에 연결하거나 특정 뷰를 참조하는 사용자 정의 identifier를 제공할 수 있다.
        - AnyView(Text("")) // print - AnyView
        - AnyView(Text("")).id("123") // print - IDView<AnyView, String>

![[Identity_4.png]]

위 예제와 같이 dogTagID를 명시적으로 지정해주면 SwiftUI는 해당 ID를 사용하여 정확히 무엇이 변경되었는지 확인하고 올바른 list 업데이트 애니메이션을 생성할 수 있다.

명시적으로 ID를 지정해주지 않으면 뷰의 identity 따로 없을까? 그렇지 않다. SwiftUI는 뷰들의 위치에 따라서도 서로를 구분한다. 이를 **structural identity**라고 한다.
## 구조적 identity

- 구조적 identity
    - 뷰 계층 구조에서의 타입과 위치에 따라 뷰를 구별한다.
    - 뷰가 현재 위치에 유지되고 위치를 바꾸지 않음을 정적으로 보장할 수 있는 경우에만 작동한다.

아래 예제에서 AdoptionDirectory 뷰는 조건이 true일 때만 보여지고, DogList는 false 일 때만 보여진다. 즉, 유사하게 보이더라도 어느 뷰가 어느 뷰인지 항상 알 수 있다. 그러나 이는 SwiftUI가 이러한 **뷰가 현재 위치에 유지되고 위치를 바꾸지 않음을 정적으로 보장**할 수 있는 경우에만 작동한다.

![[identity_5.png]]

SwiftUI는 뷰 계층 구조의 Type 구조를 살펴봄으로써 이를 달성한다. (오른쪽 코드)

![[identity_6.png]]

> 타입을 보고싶으면 아래와 같이 타입을 print하면 된다. 
   `print(type(of: body))`

some View로 인해 SwiftUI는 true 뷰가 항상 adoptionDirectory가 되고 false 뷰가 항상 doglist가 되도록 보장하여, 이들이 암묵적으로 안정적인 identity를 부여받을 수 있도록 한다.

SwiftUI는 if 문의 각 분기가 고유한 ID를 가진 다른 뷰를 나타낸다는 것으로 이해한다. 즉 아까의 예제에서 fade in/out이 일어난다.

![[identity_7.png]]

또는 레이아웃과 색상을 변경하는 단일 PawView를 가질 수도 있다. 이렇게 하면 아까의 예제에서 하나의 뷰가 슬라이딩되어 내려가는 애니메이션이 동작한다. 이는 일관된 ID로 하나의 뷰를 수정하기때문이다.

![[identity_8.png]]

이 두 방식은 모두 작동하지만, 아래 이유로 SwiftUI는 일반적으로 두번째 방식을 권장한다. **_WWDC 영상에서는 기본적으로 identity를 유지하고 보다 유연한 전환을 제공하도록 노력_**하라고 한다. 또한 이는 뷰의 **_수명과 상태를 보존하는 데에도 도움_**이 된다고 한다.

## AnyView

앞서 rescueDogs가 있는지 여부에 따라 어떤 뷰를 보여줄 지 분기 처리를 했다. 이렇게 하면 ConditionalContent라는 wrapper가 생겼었다.

![[identity_6.png]]

다음은 AnyView를 사용한 예제이다. 여기서 SwiftUI는 내 코드의 조건부 구조를 볼 수 없게된다. 대신 AnyView로 간주한다. AnyView는 erasing wrapper type 이라고 불린다. generic 시그니쳐에서 래핑하는 뷰 타입을 숨긴다. 즉, 랩퍼 코드나 뷰 구조를 알 수 없다. (type을 print해보면 AnyView로 찍힌다.) 그리고 AnyView를 아래와 같이 사용하면 코드를 읽는 것이 불편하다.

![[identity_9.png]]

이 코드는 아래와 같이 ViewBuilder를 사용하여 개선할 수 있다.

![[identity_10.png]]

그리고 type 시그니처를 보면 이제 ConditionalContent와 함께 뷰 구조가 보여진다.

아래 이유들로 가능하면 AnyView를 피하는 것이 좋다. 대신 generic을 잘 사용하여 static type 정보를 보존하는게 좋다.

- 코드를 읽고 이해하기 어려워지는 경우가 많다.
- AnyView는 컴파일러에서 static type 정보를 숨기기때문에 유용한 진단 오류 및 경고가 코드에 표시되지않는 경우가 있다.
- 필요하지 않을 때 AnyView를 사용하면 성능이 저하될 수 있다.
- ConditionalContent와 같은 랩퍼 코드나 뷰 구조를 알 수 없다.

## 요약

##### Identity

- **_사물이 같은지 다른지에 대한 이 질문은 우리가 identity라고 부르는 것의 핵심_**이다. 이 Identity는 SwiftUI가 앱을 이해하는 방법의 중요한 측면이기도 하다.
- 뷰들을 보면서, 여러 뷰들이 서로 완전히 다른 뷰처럼 보이는지, 아니면 같은 뷰일 수 있지만 다른 위치와 색상으로 표현된 것인지에 대한 구분은 실제로 매우 중요하다. 왜냐하면 **_인터페이스가 한 상태에서 다른 상태로 전환되는 방식에 영향_**을 주기 때문이다.  
    - 해당 뷰들이 서로 다른 뷰면? -> 페이드 인 및 페이드 아웃과 같이 독립적으로 전환되어야 함을 의미한다. (각자 다른 위치에서 페이드 인, 아웃으로 노출되고 숨겨짐)  
    - 만약 뷰들이 모두 같은 뷰라면? 전환 시 아이콘이 위 아래로 슬라이딩하며 애니메이션 되어야 한다는 것을 의미한다.

##### 명시적 identity

사용하면 뷰의 ID를 데이터에 연결하거나 특정 뷰를 참조하는 사용자 정의 식별자를 제공할 수 있다.  
- AnyView(Text("")) // print - AnyView  
- AnyView(Text("")).id("123") // print - IDView<AnyView, String>

##### 구조적 identity

- 뷰 계층 구조에서의 타입과 위치에 따라 뷰를 구별한다.
- 뷰가 현재 위치에 유지되고 위치를 바꾸지 않음을 정적으로 보장할 수 있는 경우에만 작동한다.

##### AnyView

- 아래 이유들로 가능하면 AnyView를 피하는 것이 좋다. 대신 generic을 잘 사용하여 static type 정보를 보존하는게 좋다.  
    - 코드를 읽고 이해하기 어려워지는 경우가 많다.  
    - AnyView는 컴파일러에서 static type 정보를 숨기기때문에 유용한 진단 오류 및 경고가 코드에 표시되지않는 경우가 있다.  
    - 필요하지 않을 때 AnyView를 사용하면 성능이 저하될 수 있다.  
    - AnyView를 사용하면 erasing type 으로 type이 AnyView로 나오게 되기때문에 ConditionalContent와 같은 랩퍼 코드나 뷰 구조를 알 수 없다.
## 출처

[WWDC2021 - Demystify SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10022)