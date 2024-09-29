ID가 뷰 및 데이터의 수명과 어떻게 연결될까?

테세우스라는 고양이가 있다고 가정해보자. 고양이는 졸고 있을 수도 있고, 졸지 않고 있을 수도 있고, 짜증을 낼 수도 있다. 이렇게 상태가 바뀌어도 이 고양이는 언제나 태세우스다. 이것이 identity와 lifetime을 연결하는 본질이다. 

identity를 사용하면 시간이 지나도 다양한 값에 대해 안정적인 요소(element)를 정의할 수 있다. 즉 시간이 지나도 따라, 연속성을 도입할 수 있다. 

코드로 살펴보자.

```
struct PurrDecidelView: View {
    var itensity: Double

    var body: some View {
        // ...
    }
}
```

처음에는 25 강도로 뷰를 생성한다.

```
var body: some View {
    PurrDecidelView(itensity: 25)
}
```

그리고 더 높은 50 강도로 뷰 값이 생성한다.

```
var body: some View {
    PurrDecidelView(itensity: 50)
}
```

- SwiftUI는 값을 비교하고 뷰가 변경되었는지 알기 위해 값의 복사본을 유지한다.
비교 후에는 기존 값(itensity = 25)이 소멸된다.
- 뷰의 값과 뷰의 identity는 다르다.
- 뷰가 처음 생성되고 나타날 때(onAppear) identity를 할당한다.
- 값을 변경해도 SwiftUI의 관점에서는 동일한 뷰다. (값이 변해도 identity는 유지된다.)
- 뷰의 identity가 변경되거나 뷰가 제거되면 lifetime이 끝난다.
- value != identity, identity == lifetime
- 뷰의 값은 일시적이므로 뷰의 lifetime이 값에 의존해서는 안된다.
- 그러나 identity는 일시적이지 않으므로 시간이 지나도 연속성을 제공한다.
- identity로 활용할 데이터는 Identifiable 프로토콜을 활용하여 안정적인 identifier를 만들자.

## 출처
https://developer.apple.com/videos/play/wwdc2021/10022