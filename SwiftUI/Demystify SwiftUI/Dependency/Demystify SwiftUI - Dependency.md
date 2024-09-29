SwiftUI가 UI를 업데이트하는 방법을 살펴보자.
목표는 SwiftUI 코드를 구성하는 방법에 대해 더 나은 mental model을 제공하는 것이다.

아래 코드를 살펴보자. 개에게 간식을 보상으로 주는 버튼이 표시된다. 여기서 dog 속성과 treat 속성이 있다. 이러한 속성들은 뷰의 Dependencies다. dependency는 단지 뷰에 대한 input일 뿐이다. 의존성이 변경되면 뷰는 새 body를 생성해야한다. body는 뷰의 계층 구조를 만드는 곳이다. 그리고 버튼이 있는데, 버튼의 액션은 뷰의 의존성에 대한 변경을 트리거하는 액션이다.

```
struct DogView: View {
    @Binding var dog: Dog
    var treat: Treat

    var body: some View {
       Button {
           dog.reward(treat)
       } label: {
           PawView()
       }
    }
}
```

아래는 DogView의 다이어그램이다. 버튼을 탭하면 개에게 보상을 주는 액션이 전달된다. 그러자 개는 간식을 순식간에 꿀꺽 삼켰고, 그 결과 개는 변화를 겪게된다. 어쩌면 개는 다른 변화를 원할 수도 있다. 의존성이 변경되었으므로 DogView는 새로운 Body를 생성한다. 

![[Demystify SwiftUI - Dependency.png]]

다음 그래프를 보자. 파란색은 의존성, 초록색은 뷰다. 각 뷰는 자체 의존성 세트를 가질 수 있고, 같은 상태나 다른 뷰의 데이터에 의존하는 여러 개의 뷰가 있을 수 있다. 예를 들어 자식 뷰들 중에서도 Dog 값에 의존할 수 있다. tree 구조에서 시작을 했지만, 이제 이 구조는 tree 구조와 비슷해 보일 뿐이다.

![[Demystify SwiftUI - Dependency1.png]]

실제로 선이 겹치지 않도록 재배열하면 아래와 같은 구조가 되며, 이는 tree가 아닌 그래프임을 알 수있다. 이 그래프를 dependency graph라고 한다. 

![[Demystify SwiftUI - Dependency2.png]]

이 구조는 SwiftUI가 새 body가 필요한 뷰만 효율적으로 업데이트할 수 있게 해주기 때문에 중요하다. 예를 들어 하단의 의존성을 보면 해당 속성을 의존하는 두개의 뷰가 있다. 의존성이 변경되면 해당 뷰만 invalidate 된다. SwiftUI는 각 뷰의 body를 호출하여 각 뷰에 대한 새로운 body 값을 생성한다. SwiftUI는 invalidate된 각 body 값을 인스턴스화한다. 이로 인해 더 많은 의존성이 변경될 수 있지만 항상 그런 것은 아니다. 뷰는 값 타입이기때문에 SwiftUI는 이를 효율적으로 비교하여 뷰의 올바른 하위집합(subset)만 업데이트할 수 있다. 뷰의 값은 수명이 짧다. struct 값은 비교에만 사용되지만 View 자체의 수명은 더 길다. 이것이 바로 중앙에 있는 뷰에 대한 새로운 body가 생성되는 것을 피할 수 있는 방법이다. identity는 의존성 그래프의 backbone이다. 모든 뷰는 명시적으로 또는 구조적으로 지정된 identity를 가지고 있다. 그 identity는 SwiftUI가 변경 사항을 올바른 뷰로 route하고 UI를 효율적으로 업데이트하는 방법이다.

의존성에는 여러 종류가 있다. 다양한 property wrapper를 사용하여 의존성을 형성할 수 있다.

## explicit identity

뷰의 lifetime은 identity의 지속 시간과 같으므로 identifier의 안정성이 중요하다. 안정적이지 않은 identifier는 뷰 수명을 단축시킬 수 있다. 그리고 안정적인 identifier를 갖는 것은 성능에도 도움이 된다. 왜냐하면 SwiftUI는 뷰에 대한 저장소를 지속적으로 생성하고 그래프 업데이트를 반복할 필요가 없기 때문이다. SwiftUI는 lifetime을 사용하여 persisted storage를 관리하므로 state 손실을 방지하려면 안정적인 identifier를 사용하는 것이 중요하다. 

identifier 안정성의 중요성을 설명하기 위해 아래 코드 예제를 살펴보자. 아래 앱에는 버그가 있다. 새로운 애완동물이 생길 때마다 화면의 모든 것이 깜박인다. 원인은 식별자가 안정적이지 않기때문이다. 데이터가 변경될 때마다 새로운 identifier를 얻게 되는 것이 문제다.

![[Demystify SwiftUI - Dependency3.png]]

대신 pets의 index를 사용하면 어떨까? 이 방법에도 비슷한 문제가 있다. index를 사용하면 이제 collection에서 해당 애완동물의 위치로 뷰가 식별된다. 여기서 0번째에 새로운 애완동물이 들어오면 모든 동물의 identity가 변경되게 된다. 그렇기때문에 index는 not stable하다.

![[Demystify SwiftUI - Dependency4.png]]

이 예에서는 데이터베이스에서 가져온 값이나 애완동물의 안정적인 속성에서 파생된 것과 같은 안정적인 식별자를 사용해야한다.

![[Demystify SwiftUI - Dependency5.png]]

좋은 식별자의 또 다른 속성은 unique함이다. 각 식별자는 단일 뷰에 매핑되어야한다. 이를 통해 애니메이션이 멋지게 보이고, 성능이 원활하며, 계층구조의 의존성이 가장 효율적인 형태로 반영된다.

또 다른 예제를 살펴보자. 이 예제에서는 애완동물의 좋아하는 간식을 모두 포함한 뷰에서 작업하고 있다. 각 간식에는 이름, 이모티콘, 만료 날짜가 있다. 각 간식 이름을 id로 사용하고 있다. 여기도 버그가 있다. 같은 종류의 간식을 두 개 이상 먹으면 문제가 생긴다. 간식의 이름은 고유한 식별자가 아니다.

![[Demystify SwiftUI - Dependency6.png]]

대신 간식별 일련번호나 기타 고유 ID를 사용할 수 있다. 그러면 모든 데이터가 올바르게 항아리에 표시된다. 또한 더 나은 애니메이션과 더 나은 성능을 보장한다.

![[Demystify SwiftUI - Dependency7.png]]

SwiftUI에서 identifier를 필요로 할 때, 우리가 적절한 identifer를 설정해줘야한다.
- 계산된 속성에서 무작위 identifier를 만들어 사용하는 것을 주의해야한다.
- 안정적인 identifier를 사용해라.
- 시간이 지나도 identifier는 변경되어서는 안된다. 새로운 identifier는 새로운 lifetime을 가진 새로운 item을 represent한다.
- identifier는 고유(unique)해야한다. 여러 뷰는 identifier를 공유할 수 없다.

## structural identity

이제 구조적 identity를 살펴보기 위해 새로운 예제를 보자. 유통기한이 지난 간식은 흐림처리를 하여 표시를 한다. 그리고 흐림 처리를 하기위해 ExpirationModifier를 만들었다.

![[Demystify SwiftUI - Dependency8.png]]

그런데 여기에도 문제가 있다. 만료기한이 오늘인 경우와 아닌 경우를 분기처리하여 새로운 content를 return하고있는데, 이렇게 되면 결국 새로운 identity를 가지게된다.
이는 수정된 단일 복사본 대신 콘텐츠의 두 개 복사본을 갖게 된다는 의미다. 

![[Demystify SwiftUI - Dependency9.png]]

이런 문제를 방지하기 위해서는 아래와 같이 opacity 함수 안에 조건문을 넣어 분기를 없애면된다.

![[Demystify SwiftUI - Dependency10.png]]

이제 조건이 변경되면 opacity만 변경되게 된다.

![[Demystify SwiftUI - Dependency11.png]]

이에 대한 비결은 조건이 참일 때, 불투명도가 1이라는 것이다. 불투명도가 1이면 아무런 효과가 없다. 이런 modifier를 "비활성 수정자(inert modifiers)"라고 부르는 이유는 이들이 렌더링된 결과에 영향을 미치지 않기 때문이다. SwiftUI Modifier는 비용이 적기 때문에 이 패턴에는 본질적인 비용이 거의 없다. 결과적으로 시각적 효과가 없기때문에 프레임워크는 modifier를 효율적으로 제거하여 비용을 더욱 절감할 수 있다. 

![[Demystify SwiftUI - Dependency12.png]]

branch는 훌륭하며 SwiftUI에 존재하는 이유가 있다. (branch: 구조적 identity을 위한 분기처리 시 생기는 버전 별 뷰) 그러나 불필요하게 사용하면 성능 저하, 예상치 못한 애니메이션이 발생할 수 있으며 state 손실까지 발생할 수 있다.

- 분기처리를 할 때, 잠시 멈추고 여러 뷰를 나타내는지 아니면 동일한 뷰를 두 가지 상태로 나타내는 지 고려해야한다.
- 단일 뷰를 식별하기 위해 분기 대신 비활성(inert) modifier를 사용하는 것이 더 나은 경우가 많다.
- 다음은 inert modifier의 예이며, 발표자는 특히 환경에 조건적으로 쓰기 위해 "transform environment"를 좋아한다고 한다.
	- opacity(1), padding(0), transformEnvironment(...) {}

## Wrap up

모든 것을 종합해 볼 때, 이 세션에서 identity가 놀라운 성능의 비결 비결 중 하나라는 것을 보여줬다.
- 명시적이고 구조적인 identity와 이를 활용하여 앱을 개선할 수 있는 방법에 대해 논의했고,
- ID에서 관련 저장소, transitions 등을 제어하는 뷰의 lifetime을 파생할 수 있다.
- SwiftUI가 ID와 lifetime을 사용하여 dependency를 형성하고 UI를 효율적으로 업데이트할 수 있는 그래프로 표현한다는 것도 설명했다.
- SwiftUI를 이해하는 것 외에도 버그를 방지하고 앱 성능을 향상할 수 있는 몇 가지 팁과 요령을 제공했다.

## 출처
https://developer.apple.com/videos/play/wwdc2021/10022