이 글은 [hackingSwift](https://www.hackingwithswift.com/books/ios-swiftui/understanding-frames-and-coordinates-inside-geometryreader) 의 내용을 번역한 것이며, 잘못 번역된 내용이 있을 수 있습니다.

SwiftUI의 GeometryReader를 사용하면 크기와 좌표를 사용하여 자식뷰의 레이아웃을 결정할 수 있다.

GeometryReader를 사용할 때는 항상 SwiftUI의 3단계 레이아웃 시스템을 염두해둬야한다. 부모가 자식에게 크기를 제안하면, 자식은 이를 사용하여 자신의 크기를 결정하고, 부모는 이를 사용하여 자식을 적절하게 배치한다.

GeometryReader의 가장 기본적인 사용법은 부모가 제안한 크기를 읽은 다음 이를 사용하여 뷰를 조작하는 것이다. 예를 들어, GeometryReader를 사용하여 텍스트 뷰의 내용과 상관없이 가용 너비의 90%를 차지하도록 만들 수 있다.

```swift
struct ContentView: View {
    var body: some View {
        GeometryReader { proxy in
            Text("Hello, World!")
                .frame(width: proxy.size.width * 0.9)
                .background(.red)
        }
    }
}
```

proxy 매개변수는 GeometryProxy다. proxy는 제안된 크기, any safe area insets, 그리고 곧 살펴볼 frame 값을 읽는 메서드를 포함하고 있다.

GeometryReader는 처음에는 당황할 수 있는 흥미로운 부작용이 있다: 반환되는 뷰는 flexible preferred size를 가지며, 필요에 따라 더 많은 공간을 차지하도록 확장된다. 이것을 확인하려면 GeometryReader를 VStack에 넣고 그 아래에 텍스트를 추가해보면 된다. 예를 들어, 다음과 같이 할 수 있다:

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            GeometryReader { proxy in
                Text("Hello, World!")
                    .frame(width: proxy.size.width * 0.9, height: 40)
                    .background(.red)
            }

            Text("More text")
                .background(.blue)
        }
    }
}
```

“More text”가 화면의 맨 아래로 밀려나는 것을 볼 수 있다. 이는 GeometryReader가 남은 모든 공간을 차지하기 때문이다. 이를 확인하려면 GeometryReader에 background(.green)을 수정자로 추가해보면 된다.

뷰의 프레임을 읽는 데 있어, GeometryProxy는 간단한 속성 대신 frame(in:) 메서드를 제공한다. 뷰의 절대 X와 Y 좌표가 필요한지, 아니면 부모와의 상대적인 X와 Y 좌표가 필요한지 구분해야 한다.

SwiftUI는 이러한 옵션을 coordinate spaces이라고 부르며, 글로벌 공간(뷰의 프레임을 전체 화면에 대해 측정)과 로컬 공간(뷰의 프레임을 부모에 대해 측정)이 있다. 또한, coordinateSpace() 수정자를 뷰에 추가하여 커스텀 좌표 공간을 만들 수 있으며, 이 뷰의 자식들은 그 좌표 공간에 대한 프레임을 읽을 수 있다.

좌표 공간이 어떻게 작동하는지 시연하기 위해, 다양한 스택에 몇 가지 예제 뷰를 만들고, 가장 바깥쪽 뷰에 사용자 정의 좌표 공간을 추가한 다음, 그 내부의 뷰 중 하나에 onTapGesture를 추가하여 global, local, custom 좌표 공간을 사용하여 프레임을 출력해보자.

```swift
struct OuterView: View {
    var body: some View {
        VStack {
            Text("Top")
            InnerView()
                .background(.green)
            Text("Bottom")
        }
    }
}

struct InnerView: View {
    var body: some View {
        HStack {
            Text("Left")
            GeometryReader { proxy in
                Text("Center")
                    .background(.blue)
                    .onTapGesture {
                        print("Global center: \(proxy.frame(in: .global).midX) x \(proxy.frame(in: .global).midY)")
                        print("Custom center: \(proxy.frame(in: .named("Custom")).midX) x \(proxy.frame(in: .named("Custom")).midY)")
                        print("Local center: \(proxy.frame(in: .local).midX) x \(proxy.frame(in: .local).midY)")
                    }
            }
            .background(.orange)
            Text("Right")
        }
    }
}

struct ContentView: View {
    var body: some View {
        OuterView()
            .background(.red)
            .coordinateSpace(name: "Custom")
    }
}
```

![[GeometryFrameCoordinates_screen.png]]

코드가 실행될 때 출력되는 결과는 사용하는 기기에 따라 다를 수 있지만, 여기서 사용한 기기의 경우 다음과 같다:

- 글로벌 중심: 191.33 x 440.60
- 사용자 정의 중심: 191.33 x 381.60
- 로컬 중심: 153.66 x 350.63

frame이 어떻게 작동하는지 보자:

- global midX가 191이라는 것은 GeometryReader의 중심이 화면의 왼쪽 가장자리로부터 191 포인트 떨어져 있다는 의미다.
- global midY가 440이라는 것은 GeometryReader의 중심이 화면의 위쪽 가장자리로부터 440 포인트 떨어져 있다는 의미다. 이는 화면의 정확한 중앙이 아니며, 상단에는 하단보다 더 많은 safe area가 있기 때문이다. 
- custom midX가 191이라는 것은 GeometryReader의 중심이 “Custom” 좌표 공간을 소유하는 뷰(OuterView)의 왼쪽 가장자리로부터 191 포인트 떨어져 있다는 의미다. 위 코드에서 ContentView에서 이OuterView를 가지고 있다. 이 숫자(191)은 global 위치와 일치하는데, OuterView가 수평으로 가장자리에서 가장자리까지 확장되기 때문이다.
- custom midY가 381이라는 것은 GeometryReader의 중심이 OuterView의 위 쪽 가장자리로부터 381 포인트 떨어져 있다는 의미다. 이 값이 global midY보다 작은 이유는 OuterView가 safe area로 확장되지 않기 때문이다.
- local midX가 153이라는 것은 GeometryReader의 중심이 직접 컨테이너의 왼쪽 가장자리로부터 153 포인트 떨어져 있다는 의미다.
- local midY가 350이라는 것은 GeometryReader의 중심이 직접 컨테이너의 위쪽 가장자리로부터 350 포인트 떨어져 있다는 의미다.

어떤 좌표 공간을 사용할지는 답변하고자 하는 질문에 따라 다르다:

- 이 뷰가 화면에서 어디에 있는지 알고 싶다면? global space
- 이 뷰가 부모에 대해 어디에 있는지 알고 싶다면? local space
- 이 뷰가 다른 뷰에 대해 어디에 있는지 알고 싶다면? custom space
## 내용 출처
- https://www.hackingwithswift.com/books/ios-swiftui/understanding-frames-and-coordinates-inside-geometryreader