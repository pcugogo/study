## @State
> A property wrapper type that can read and write a value managed by SwiftUI.
> 
> SwiftUI에서 관리하는 값을 읽고 쓸 수 있는 property wrapper type입니다.

isPlaying 값이 변경되면 PlayButton의 타이틀이 업데이트된다. (View가 invalidate 되지는 않는다.)

```
struct PlayButton: View {
    @State private var isPlaying: Bool = false // Create the state.

    var body: some View {
        Button(isPlaying ? "Pause" : "Play") { // Read the state.
            isPlaying.toggle() // Write the state.
        }
    }
}
```

state로 정의할 변수는 private으로 선언한다. 이유는 간단하다. 외부에서 값을 변경하지 못하게 하기위해서다.
## @Binding

state 변수를 하위 뷰에 전달하면 SwiftUI는 containerView(PlayerView)에서 값이 변경될 때마다 하위 뷰를 업데이트하지만, 하위 뷰는 값을 수정할 수 없다. **하위 뷰가 상태의 저장된 값을 수정할 수 있도록 하려면 Binding 키워드를 붙이면 된다.**  간단하게 상위뷰와 하위뷰가 값을 공유한다고 생각하면 될 것 같다.

```
struct PlayButton: View {
    @Binding var isPlaying: Bool 

    var body: some View {
        Button(isPlaying ? "Pause" : "Play") {
            isPlaying.toggle()
        }
    }
}

struct PlayerView: View {
    @State private var isPlaying: Bool = false // Create the state here now.

    var body: some View {
        VStack {
            PlayButton(isPlaying: $isPlaying) // Pass a binding.
        }
    }
}
```
## ObservableObject

> A type of object with a publisher that emits before the object has changed.
>
> 객체가 변경되기 전에 emit하는 publisher가 있는 객체 타입이다.


```
protocol ObservableObject : AnyObject
```

ObservableObject를 채택한 클래스는 objectWillChange라는 속성을 사용할 수 있다. 이 속성을 이용하여 class 내부 값이 변경되었을 때, willSet 안에서 objectWillChange.send() 호출을 통해 변경된 사항이 있다고 알려준다.

```
final class Contact: ObservableObject {
    var name: String {
	   willSet { self.objectWillChange.send() }
    }
    var age: Int {
	   willSet { self.objectWillChange.send() }
    }
    
    init(name: String, age: Int) {
        self.name = name self.age = age
    }

    func haveBirthday() -> Int {
        age += 1 
        return age
    }
}
```
## @Published

위 동작을 한다.
@Published가 붙은 변수의 값이 변경되면 자동으로 objectWillChange.send()를 호출해 준다.

```
final class Contact: ObservableObject {
    @Published var name: String
    @Published var age: Int
    
    init(name: String, age: Int) {
        self.name = name 
        self.age = age
    }

    func haveBirthday() {
        age += 1 
    }
}
```

## @ObservedObject

 > A property wrapper type that subscribes to an observable object and invalidates a view whenever the observable object changes.
>
> ObservableObject를 subscribe하고 observable object가 변경될 때마다 **뷰를 무효화**하는 property wrapper다.

```
struct ContactView: View {
    @ObservedObject var contact = Contact(name: "?", age: 1)

    var body: some View {
        VStack {
            Text("age: \(contact.age)")
            Button(
                action: { contact.haveBirthday() },
                label: { Text("Counter Add") }
            )
        }
    }
}
```

## @StateObject

요상한 예제로 StateObject가 왜 필요한 지 살펴보자.

```

struct ContentView: View {
    @State private var rootAge: Int = 0

    var body: some View {
        ContactView(rootAge: rootAge)
        Button(
            action: { rootAge += 1 },
            label: { Text("Root Add") }
        )
    }
}

struct ContactView: View {
    @ObservedObject var contact = Contact(name: "?", age: 1)
    let rootAge: Int

    var body: some View {
        VStack {
            Text("Root: \(rootAge)")
            Text("age: \(contact.age)")
            
            Button(
                action: { contact.haveBirthday() },
                label: { Text("Counter Add") }
            )
        }
    }
}

final class Contact: ObservableObject {
    @Published var name: String
    @Published var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age

    }

    func haveBirthday() {
        age += 1
    }
}
```

아까 위에서 ObservableObject 는 observable object가 변경될 때마다 **뷰를 무효화**하는 property wrapper라고 했다. 
ContentView의 rootAge가 변경되면 ContactView가 초기화된다. 그리고 viewModel도 함께 초기화된다. 
그리고 또 age는 viewModel이 가지고 있기때문에 마찬가지로 초기화된다.

이 이슈를 어떻게 해결할 수 있을까? viewModel 변수의 ObservedObject를 StateObject로 변경하면 해결이된다. 왜 해결이 될까? 

[Monitoring data changes in your app](https://developer.apple.com/documentation/swiftui/monitoring-model-data-changes-in-your-app) 내용에 의하면, state object는 observed object 처럼 동작하지만, **뷰를 재생성하는 횟수에 관계없이 주어진 뷰 인스턴스에 대해 단일 객체 인스턴스를 생성하고 관리** 한다고한다. 즉, View의 라이프 사이클과는 상관 없이 View와 별개의 메모리 공간을 사용해 데이터를 보관한다고 한다.

> A state object behaves like an observed object, except that SwiftUI creates and manages a single object instance for a given view instance, regardless of how many times it recreates the view.
> 
> state object는 observed object 처럼 동작합니다. 단, **뷰를 재생성하는 횟수에 관계없이 주어진 뷰 인스턴스에 대해 단일 객체 인스턴스를 생성하고 관리**합니다.

애플은 처음 초기화할 때는 StateObject를, 객체를 넘겨 받을 때는 ObservedObject의 사용을 추천하고 있다. 
선언 시 StateObejct로 선언을 하면 전달한 후에도 별도의 메모리로 관리가 되나보다.

## EnvironmentObject

 A property wrapper type for an observable object that a parent or ancestor view supplies.
> 
> 상위 또는 조상 뷰가 제공하는 Observable Object에 대한 property wrapper type입니다.

상위뷰가 가지고 있는 값을 하위 뷰로 전달할 때 사용한다. 그리고 전달한 값은 공유된다. (ContactDetailView에서 contact를 변경하면 ContactView에서도 반영된다.)

```
struct ContactView: View {
    @StateObject private var contact = Contact(name: "?", age: 1)
    let rootAge: Int

    var body: some View {
        VStack {
            Text("Root: \(rootAge)")
            Text("age: \(contact.age)")
            Button(
                action: { contact.haveBirthday() },
                label: { Text("Counter Add") }
            )
            ContactDetailView().environmentObject(contact)
        }
    }
}

struct ContactDetailView: View {
    @EnvironmentObject private var contact: Contact
    
    var body: some View {
        VStack {
            Text("age: \(contact.age)")
            Button(
                action: { contact.haveBirthday() },
                label: { Text("Counter Add") }
            )
        }
    }
}
```

기존에는 보통 init을 통해 전달했는데, environmentObject를 사용하면 init을 사용하지 않고 쉽게 값을 전달할 수 있다.

하위뷰의 변수에 @EnvironmentObject만 추가하고, 데이터를 주입하지 않거나 상위 뷰에 값이 없는 경우에 
하위 뷰에서 해당 값 접근 시 crash가 발생하기때문에 주의해야한다. 