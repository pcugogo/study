## (H, V, Grid) Stack
뷰를 수직, 수평 또는 Grid 형태로 정렬한다. UIKit의 StackView와 유사하다.

## (H, V, Grid) LazyStack
Stack과 마찬가지로 뷰를 정렬하고, Stack과 다른 점은 화면에 보여질 때 생성이 된다는 점이다.

ScrollView안에서 ForEach를 통해 많은 뷰를 그려야할 때 Stack을 사용한다면 많은 뷰가 한 번에 생성되게 되고 이로 인해 한 번에 너무 많은 양의 메모리를 차지하게되고 런타임 성능 저하가 발생한다. 때문에 많은 뷰를 포함하는 ScrollView를 그려야할 때는 LazyStack을 사용하는게 좋겠다. 그렇다면 항상 Lazy Stack을 이용하는게 좋은게 아닌가 싶을 수 있는데, [공식문서](https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks)내용에 의하면 각각의 강점이 있으니 필요한 상황에 맞는 뷰를 선택하는 것이 좋다고 한다. 뷰가 적은 경우에는 Stack을 사용하여 뷰를 한 번에 로드하면 레이아웃을 보다 빠르고 안정적으로 할 수 있다고한다.