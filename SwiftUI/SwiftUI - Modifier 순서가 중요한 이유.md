[애플 공식 문서](https://developer.apple.com/documentation/swiftui/view/modifier(_:)) 에서는 modifier를 `view에 modifier를 적용하고 새 뷰를 반환한다.`라고 정의하고 있다. 

거의 매 번 SwiftUI 뷰에 modifier를 적용할 때, 기존 뷰를 수정하는 것이 아니고, 해당 변경 사항이 적용된 새로운 뷰를 생성한다고 한다. 

```swift
Button("Hello, world!") {
    // do nothing
}    
.background(.red)
.frame(width: 200, height: 200)
```

위 코드를 실행해보면 200x200 사이즈의 빨간 버튼이 보이지 않고, 텍스트 사이즈만큼만 빨갛게 보일 것이다.

여기서 일어나는 일을 이해하려면 modifier가 어떻게 작동하는지 생각해보면 된다. 각각의 modifier는 속성을 설정하는 대신, 해당 modifier가 적용된 새로운 구조체를 생성한다.

SwiftUI의 내부를 엿보려면 아래와 같이 뷰의 body 타입을 요청해 볼 수 있다.

```swift
Button("Hello, world!") {
    print(type(of: self.body))
}    
.background(.red)
.frame(width: 200, height: 200)
```

Swift의 ***type(of:)*** 함수는 특정 값의 타입을 출력한다. 그리고 출력 결과는 아래와 같다.

```
ModifiedContent<ModifiedContent<Button<Text>, _BackgroundStyleModifier<Color>>, _FrameLayout>
```

- 뷰를 수정할 때마다 SwiftUI는 제네릭을 사용하여 modifier를 적용한다.
	- `ModifiedContent<뷰 타입, Modifier>`

-  여러 modifier를 적용하면 그것들이 쌓인다.
	- `ModifiedContent<ModifiedContent<…`
	- 아래 코드를 보면 제일 바깥 쪽 부터 padding, backgroundStyle, frame 순서로 감싸져있다. 여기서 padding을 background 위로 이동시키면 background가 제일 바깥에 위치하게 된다.

```
Button("Hello, world!") {
    print(type(of: self.body))
}
.frame(width: 200, height: 200)
.background(.red)
.padding(.init(top: 1, leading: 1, bottom: 1, trailing: 1))

// print 결과
ModifiedContent<
    ModifiedContent<
        ModifiedContent<
            Button<Text>, 
            _FrameLayout
        >, 
        _BackgroundStyleModifier<Color>
    >, 
    _PaddingLayout
>
```

각 ModifiedContent는 변환할 뷰와 실제로 적용할 변경 사항을 포함하며, 뷰를 직접 수정하는 것이 아니다.

이것이 의미하는 바는 modifier의 순서가 중요하다는 것이다. 만약 backgroundColor를 frame 적용 후에 적용하도록 코드를 수정하면 frame 전체에 color가 적용될 것이다. frame을 적용한 후에 여기다가 color를 지정하기 때문이다.
## 출처

- [애플 공식 문서](https://developer.apple.com/documentation/swiftui/view/modifier(_:))
- [hackingwithswift](https://www.hackingwithswift.com/books/ios-swiftui/why-modifier-order-matters)
