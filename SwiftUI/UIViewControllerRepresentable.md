- UIViewController를 랩핑하여 SwiftUI 뷰로 사용할 수 있도록 해주는 wrapper다. UIView를 랩핑하는 UIViewRepresentable도 있다.
- protocol 이다.
	- required methods: makeUIViewController, updateUIViewController
### makeUIViewController
- 이 함수에서 뷰컨트롤러를 생성한다.
- 한 번만 호출된다.
- context를 통해 coordinator에 있는 값을 가져올 수 있다.

```
@MainActor func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType

func makeUIViewController(context: Context) -> UIPageViewController {
    let pageViewController = UIPageViewController(
       transitionStyle: .scroll,
       navigationOrientation: .horizontal
    )
    pageViewController.dataSource = context.coordinator
    pageViewController.delegate = context.coordinator
    return pageViewController
}
```

## updateUIViewController
- updateUIViewController는 뷰컨트롤러의 업데이트가 필요할 때 실행된다. 
- context를 통해 coordinator에 있는 값을 가져올 수 있다.
- makeUIViewController 실행 후에 호출된다.

```swift
@MainActor func updateUIViewController(_ uiViewController: Self.UIViewControllerType, context: Self.Context)

func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
    let viewControllers = context.coordinator.viewControllers
}
```

## makeCoordinator
-  makeUIViewController(context:) 메서드가 호출되기 전에 한 번 호출된다.
	- 뷰 사용 중에 한 번만 생성하여 관리/사용하고 싶은 값을 Coordinator에 선언하면 된다.
- Coordinator 사용이 필요할 때만 작성하면 된다.

```swift
@MainActor func makeCoordinator() -> Self.Coordinator

func makeCoordinator() -> Coordinator {
    Coordinator(self)
}
```

## Coordinator
- Coordinator를  통해 delegate, dataSource, target-action 등등 일반적인 cocoa 패턴들을 구현할 수 있다.
	- @objc 함수를 Coordinator에 두고 사용할 수 있다.
- 사용이 필요할 때 정의하면 된다.


```swift
class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageView
        var viewControllers: [UIViewController] = []
        
        init(_ pageViewController: PageView) {
            parent = pageViewController
            viewControllers = parent.pages.map { UIHostingController(rootView: $0) }
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard
                completed,
                let viewController = pageViewController.viewControllers?.first,
                let index = viewControllers.firstIndex(of: viewController)
            else { return }

            parent.currentPage = index
        }
}
```