https://github.com/uber/RIBs/wiki/iOS-Tutorial-2

## Goal

이전 튜토리얼에서는 LoggedOut RIB이 제공하는 로그인 폼을 포함한 앱을 구축했습니다. 이 연습에서는 거기서부터 진행하여 사용자가 로그인한 후 게임 필드를 표시하도록 애플리케이션을 확장할 것입니다. 이 튜토리얼의 마지막에는 RIBs를 unit test하는 방법에 대해 간략히 설명합니다.

이 연습의 주요 목표는 다음 개념을 이해하는 것입니다.
- 자식 RIB이 부모 RIB과 통신하는 방법
- 부모 인터랙터가 자식 RIB을 attach/detach하는 방법
- 뷰가 없는 RIB 생성하기
  - 뷰가 없는 RIB이 detach될 때 뷰 수정을 정리하는 방법
- 부모 RIB이 처음로드될 때 자식 RIB attach하기
  - RIB의 라이프사이클 이해하기
- RIB 단위 테스트하기

## 프로젝트 구조

이전 튜토리얼을 완료하면 Root와 LoggedOut 이라는 두 개의 RIB으로 구성된 애플리케이션이 생성됩니다. 이 연습에서는 LoggedIn, OffGame 및 TicTacToe라는 세 개의 추가 RIB를 구현할 것입니다. 이 튜토리얼의 끝에는 애플리케이션에 다음과 같은 RIB 계층 구조가 구축될 것입니다.

![[스크린샷 2023-05-17 오후 3.05.04.png]]

여기에서 LoggedIn RIB은 View를 갖지 않습니다. LoggedIn RIB은 TicTacToe과 OffGame RIB 사이를 전환하는 역할을 담당합니다. 다른 모든 RIB은 뷰 컨트롤러를 포함하며 화면에 View를 표시할 수 있습니다.

OffGame RIB은 플레이어가 새 게임을 시작할 수 있도록 하며 "게임 시작" 버튼이 있는 인터페이스를 포함할 것입니다. TicTacToe RIB은 게임 필드를 표시하고 플레이어가 움직일 수 있도록 할 것입니다.

### 상위 RIB과의 통신

사용자가 플레이어 이름을 입력하고 "login" 버튼을 탭한 후에는 "Start Game" View로 전환되어야 합니다. 이 동작을 지원하기 위해 LoggedOut RIB은 로그인 동작에 대해 Root RIB에 알려야 합니다. 그 후에 Root Router는 LoggedOut RIB에서 LoggedIn RIB 으로 제어를 전환할 것입니다. 다음으로 뷰가 없는 LoggedIn RIB은 OffGame RIB을 로드하고 해당 뷰 컨트롤러를 화면에 표시할 것입니다.

Root RIB이 LoggedOut RIB의 상위 RIB이므로 해당 Router는 LoggedOut의 Interactor의 listener로 구성되어야 합니다. 로그인 이벤트를 LoggedOut RIB에서 Root RIB으로 이 listener 인터페이스를 통해 전달해야 합니다.

먼저, LoggedOutListener를 업데이트하여 LoggedOut RIB이 플레이어가 로그인했음을 Root RIB에 알릴 수 있는 메서드를 추가하세요.

이로 인해 LoggedOut RIB의 상위 RIB 중 어떤 것이든 didLogin 함수를 구현하도록 강제하며, 컴파일러가 상위 RIB과 하위 RIB 간의 계약을 강제하는 것을 보장합니다.

LoggedOutInteractor 내의 login 함수 구현을 변경하여 새로 선언된 리스너 호출을 추가하세요.

이러한 변경 사항으로 인해 LoggedOut RIB의 리스너는 사용자가 RIB의 뷰 컨트롤러에서 "로그인" 버튼을 탭한 후에 알림을 받게 됩니다.

### Root RIB으로 라우팅하기

위의 다이어그램에서 볼 수 있듯이 사용자가 로그인한 후에는 Root RIB이 LoggedOut RIB에서 LoggedIn RIB으로 전환해야 합니다. 이를 지원하기 위해 라우팅 코드를 작성해 봅시다.

RootRouting 프로토콜을 업데이트하여 LoggedIn RIB로 라우팅하는 메서드를 추가하세요.

```
protocol RootRouting: ViewableRouting {
    func routeToLoggedIn(withPlayer1Name player1Name: String, player2Name: String)
}
```

이로써 RootInteractor와 해당 라우터인 RootRouter 간의 계약이 확립됩니다.

RootInteractor에서 RootRouting을 호출하여 LoggedIn RIB으로 라우팅하기 위해 LoggedOutListener 프로토콜을 구현하세요. LoggedOut RIB의 상위 RIB인 Root RIB는 해당 리스너 인터페이스를 구현해야 합니다.

```
// MARK: - LoggedOutListener

func didLogin(withPlayer1Name player1Name: String, player2Name: String) { router?.routeToLoggedIn(withPlayer1Name: player1Name, player2Name: player2Name) 
}
```

사용자가 로그인할 때마다 Root RIB이 LoggedIn RIB으로 라우팅하도록 설정됩니다. 그러나 우리는 아직 LoggedIn RIB이 구현되지 않았으며 Root RIB에서 이로 전환할 수 없습니다. 누락된 RIB을 추가해 봅시다.

LoggedIn 그룹에서 DELETE_ME.swift 파일을 삭제하세요.

다음으로, Xcode 템플릿을 사용하여 뷰 없는 RIB으로 LoggedIn RIB을 생성하세요. "Owns corresponding view" 상자를 선택 해제하고 LoggedIn 그룹에 RIB을 생성하세요. 새로 생성된 파일이 TicTacToe 타겟에 추가되었는지 확인하세요.

사용자가 로그인할 때 새로 생성된 RIB을 attach하기 위해, root router는 해당 RIB을 빌드할 수 있어야 합니다. 이를 위해 LoggedInBuildable 프로토콜을 RootRouter에 생성자 주입을 통해 전달하여 가능하게 만듭니다. RootRouter의 생성자를 다음과 같이 수정하세요.

```
init(interactor: RootInteractable,
     viewController: RootViewControllable,
     loggedOutBuilder: LoggedOutBuildable,
     loggedInBuilder: LoggedInBuildable) {
    self.loggedOutBuilder = loggedOutBuilder
    self.loggedInBuilder = loggedInBuilder
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
}
```

또한 RootRouter에는 private loggedInBuilder 상수를 추가해야 합니다.

```
// MARK: - Private
    private let loggedInBuilder: LoggedInBuildable

    ...
```

그런 다음 RootBuilder를 업데이트하여 LoggedInBuilder 클래스를 인스턴스화하고 이를 RootRouter에 주입하도록 하세요. RootBuilder의 build 함수를 다음과 같이 수정하세요.

```
func build() -> LaunchRouting {
    let viewController = RootViewController()
    let component = RootComponent(dependency: dependency,
                                  rootViewController: viewController)
    let interactor = RootInteractor(presenter: viewController)

    let loggedOutBuilder = LoggedOutBuilder(dependency: component)
    let loggedInBuilder = LoggedInBuilder(dependency: component)
    return RootRouter(interactor: interactor,
                      viewController: viewController,
                      loggedOutBuilder: loggedOutBuilder,
                      loggedInBuilder: loggedInBuilder)
}
```

우리가 방금 수정한 코드를 살펴보면, LoggedInBuilder에 RootComponent를 의존성으로 주입했습니다. 지금은 왜 이렇게 하는지 걱정하지 마세요. 튜토리얼 3에서 다룰 예정입니다.

RootRouter는 LoggedInBuilder 클래스 대신 LoggedInBuildable 프로토콜에 의존합니다. 이렇게 함으로써 단위 테스트 시 LoggedInBuildable에 대한 테스트 mock 객체를 전달할 수 있습니다. 이는 Swift의 제약 사항으로, 스위즐링 기반의 mock 객체화는 불가능합니다. 동시에, 이는 프로토콜 기반 프로그래밍 원칙을 따르며 RootRouter와 LoggedInBuilder가 느슨하게 결합되도록 합니다.

우리는 LoggedIn RIB에 대한 모든 뼈대 코드를 작성하고 Root RIB에서 인스턴스화할 수 있도록 만들었습니다. 이제 RootRouter에서 routeToLoggedIn 메서드를 구현할 수 있습니다.

적절한 위치는 // MARK: - Private 섹션 바로 앞입니다.

```
// MARK: - RootRouting
func routeToLoggedIn(withPlayer1Name player1Name: String, player2Name: String) {
    // Detach LoggedOut RIB.
    if let loggedOut = self.loggedOut {
        detachChild(loggedOut)
        viewController.dismiss(viewController: loggedOut.viewControllable)
        self.loggedOut = nil
    }

    let loggedIn = loggedInBuilder.build(withListener: interactor)
    attachChild(loggedIn)
}
```

위의 코드 조각에서 볼 수 있듯이, ***상위 RIB은 기존의 하위 RIB을 detach하고 새로운 하위 RIB을 생성한 다음 detach된 하위 RIB 대신에 이를 attach해야 합니다. RIB 아키텍처에서는 상위 라우터가 항상 자식의 라우터를 attach***합니다.

또한, RIB과 View 계층 구조 간의 일관성을 유지하는 것은 상위 RIB의 책임입니다. 자식 RIB에 뷰 컨트롤러가 있는 경우, ***상위 RIB은 하위 RIB이 detach되거나 attach될 때, 하위 뷰 컨트롤러를 dismiss 하거나 present 해야 합니다.*** routeToLoggedOut 메서드의 구현을 확인하여 뷰 컨트롤러를 소유하는 RIB을 attach하는 방법을 이해하세요.

새로 생성된 LoggedIn RIB에서 이벤트를 받을 수 있도록 하기 위해 Root RIB은 Interactor를 LoggedIn RIB의 리스너로 구성합니다. 이는 위의 코드에서 Root RIB이 자식 RIB을 빌드할 때 발생합니다. 그러나 현재 시점에서는 Root RIB이 아직 LoggedIn RIB의 요청에 응답할 수 있는 프로토콜을 구현하지 않았습니다.

RIB은 리스너 인터페이스를 채택해야 하는 점에서 엄격합니다. 이는 프로토콜 기반으로 진행되기 때문입니다. 우리는 컴파일러가 모든 상위 RIB이 자식의 모든 이벤트를 소비하지 않을 때 런타임에서 조용히 실패하는 것이 아니라 오류를 반환하도록 하기 위해 다른 암묵적인 관찰 방법 대신 프로토콜을 사용합니다. 이제 RootInteractable을 LoggedInBuilder build 메서드의 listener로 전달했으므로, RootInteractable은 LoggedInListener 프로토콜을 채택해야 합니다. RootInteractable에 이 프로토콜을 채택해 봅시다.

```
protocol RootInteractable: Interactable, LoggedOutListener, LoggedInListener {
    weak var router: RootRouting? { get set }
    weak var listener: RootListener? { get set }
}
```

LoggedOut RIB을 detach하고 해당 뷰를 dismiss하기 위해서는 RootViewControllable 프로토콜에 새로운 dismiss 메서드를 추가해야 합니다.

프로토콜을 다음과 같이 수정하세요.

```
protocol RootViewControllable: ViewControllable {
    func present(viewController: ViewControllable)
    func dismiss(viewController: ViewControllable)
}
```

dismiss 메서드를 프로토콜에 추가한 후에는 RootViewController에서 이를 구현해야 합니다. present 메서드 아래에 해당 메서드를 추가하세요.

```
func dismiss(viewController: ViewControllable) {
    if presentedViewController === viewController.uiviewController {
        dismiss(animated: true, completion: nil)
    }
}
```
  
이제 RootRouter는 routeToLoggedIn 메서드를 사용하여 LoggedIn RIB으로 라우팅할 때 LoggedOut RIB을 올바르게 detach하고 해당 뷰 컨트롤러를 dismiss할 수 있습니다.

### LoggedInViewControllable를 생성하는 대신에 전달하세요

LoggedIn RIB은 자체적인 뷰가 없지만 하위 RIB의 뷰를 표시할 수 있어야 합니다. 이를 위해 LoggedIn RIB은 조상의 뷰에 액세스해야 합니다. 우리의 경우, 이 뷰는 LoggedIn RIB의 부모인 Root RIB에 의해 제공되어야 합니다.

RootViewController를 LoggedInViewControllable을 채택하도록 업데이트하려면 파일 끝에 다음과 같은 확장을 추가하세요:

```
// MARK: LoggedInViewControllable
extension RootViewController: LoggedInViewControllable {
}
```

LoggedIn RIB에 LoggedInViewControllable 인스턴스를 주입해야 합니다. 지금은 자세한 내용을 안내하지 않겠습니다. 이 부분은 튜토리얼 3에서 다루게 될 것입니다. 일단은 LoggedInBuilder.swift 파일의 내용을 다음 코드로 덮어씌우세요.

이제 LoggedIn RIB은 Root RIB에 의해 구현된 LoggedInViewControllable의 메서드를 호출하여 하위 RIB의 뷰를 표시하고 숨길 수 있습니다

LoggedIn RIB이 로드될 때 OffGame RIB을 attach합니다. 이전에 언급했듯이, LoggedIn RIB은 뷰가 없으며 자식 RIB들 간에만 전환할 수 있습니다. "Start Game" 버튼을 표시하고 해당 버튼을 처리할 OffGame이라는 RIB을 생성해봅시다.

이전 튜토리얼과 동일한 지침을 따라 뷰가 있는 RIB를 생성하세요. "OffGame"이라는 새로운 그룹을 만드는 것을 권장합니다.

RIB를 생성한 후에는 OffGameViewController 클래스에서 UI를 구현하세요. 시간을 절약하기 위해 제공된 구현을 사용할 수 있습니다.

이제 새로 생성된 OffGame RIB을 부모인 LoggedIn과 attach해봅시다. LoggedIn RIB은 OffGame RIB을 빌드하고 자식으로서 추가할 수 있어야 합니다.

LoggedInRouter의 생성자를 수정하여 OffGameBuildable 인스턴스에 대한 종속성을 선언하도록 변경하세요. 아래에서 제안된 대로 생성자를 수정하세요.

```
init(interactor: LoggedInInteractable,
     viewController: LoggedInViewControllable,
     offGameBuilder: OffGameBuildable) {
    self.viewController = viewController
    self.offGameBuilder = offGameBuilder
    super.init(interactor: interactor)
    interactor.router = self
}
```

또한, offGameBuilder에 대한 참조를 저장할 새로운 private 상수를 선언해야 합니다.

```
// MARK: - Private

...

private let offGameBuilder: OffGameBuildable
```

private let offGameBuilder: OffGameBuildable 이제 LoggedInBuilder를 업데이트하여 OffGameBuilder 구체적인 클래스를 인스턴스화하고 LoggedInRouter 인스턴스에 주입하도록 수정하세요. build 함수를 다음과 같이 변경하세요.

```
func build(withListener listener: LoggedInListener) -> LoggedInRouting {
    let component = LoggedInComponent(dependency: dependency)
    let interactor = LoggedInInteractor()
    interactor.listener = listener

    let offGameBuilder = OffGameBuilder(dependency: component)
    return LoggedInRouter(interactor: interactor,
                          viewController: component.loggedInViewController,
                          offGameBuilder: offGameBuilder)
}
```

OffGameBuilder의 의존성 계약을 이행하기 위해 LoggedInComponent 클래스가 OffGameComponent을 채택하도록 합니다.

```
final class LoggedInComponent: Component<LoggedInDependency>, OffGameDependency {
    
    fileprivate var loggedInViewController: LoggedInViewControllable {
        return dependency.loggedInViewController
    }
}
```

로그인한 후에 OffGame RIB을 사용하여 시작 화면을 표시하려고 합니다. 이는 LoggedIn RIB이 로드되자마자 OffGame RIB을 attach해야 함을 의미합니다. LoggedInRouter의 didLoad 메서드를 오버라이드하여 OffGame RIB을 로드하도록 합시다.

```
override func didLoad() {
    super.didLoad()
    attachOffGame()
}
```

attachOffGame는 LoggedInRouter 클래스의 private method로, OffGame RIB을 빌드하고 attach하며 해당 뷰 컨트롤러를 표시하는 데 사용됩니다. 이 메서드의 구현을 LoggedInRouter 클래스의 끝에 추가하세요.

```
// MARK: - Private

private var currentChild: ViewableRouting?

private func attachOffGame() {
    let offGame = offGameBuilder.build(withListener: interactor)
    self.currentChild = offGame
    attachChild(offGame)
    viewController.present(viewController: offGame.viewControllable)
}
```

attachOffGame 메서드 내에서 OffGameBuilder를 인스턴스화하려면 LoggedInInteractable 인스턴스를 주입해야 합니다. 이 인터랙터는 OffGame의 리스너 인터페이스로 작동하여 부모가 자식 RIB에서 발생하는 이벤트를 받고 해석할 수 있게 합니다.

OffGame RIB 이벤트를 수신하려면 LoggedInInteractable은 OffGameListener 프로토콜을 준수해야 합니다. 이를 위해 프로토콜 준수를 추가해봅시다.

```
protocol LoggedInInteractable: Interactable, OffGameListener {
    weak var router: LoggedInRouting? { get set }
    weak var listener: LoggedInListener? { get set }
}
```

이제 LoggedIn RIB은 로드 후 OffGame RIB을 attach하고, 이 RIB에서 발생하는 이벤트를 수신할 수 있게 됩니다.

### LoggedIn RIB이 detach될 때 attach된 뷰들을 정리하는 작업을 해보겠습니다.

LoggedIn RIB은 뷰가 없으며 대신 부모의 뷰 계층을 수정합니다. 따라서 Root RIB에는 LoggedIn RIB이 수행한 뷰 수정을 자동으로 제거할 수 있는 방법이 없습니다. 다행히도 템플릿은 LoggedIn RIB이 detach 될 때 뷰 수정을 정리할 수 있는 hook(cleanupViews)을 제공합니다.

LoggedInViewControllable 프로토콜에 present와 dismiss 메서드를 선언합니다:

```
protocol LoggedInViewControllable: ViewControllable {
    func present(viewController: ViewControllable)
    func dismiss(viewController: ViewControllable)
}
```

다른 프로토콜 선언과 마찬가지로, 이는 LoggedIn RIB이 ViewControllable을 dismiss하는 기능이 필요함을 선언합니다.

그런 다음, LoggedInRouter의 cleanupViews 메서드를 업데이트하여 현재 자식 RIB의 뷰 컨트롤러를 dismiss합니다:

```
func cleanupViews() {
    if let currentChild = currentChild {
        viewController.dismiss(viewController: currentChild.viewControllable)
    }
}
```

cleanupViews 메서드는 부모 RIB이 LoggedIn RIB을 detach하기로 결정했을 때 LoggedInInteractor에 의해 호출됩니다. cleanupViews에서 표시된 뷰 컨트롤러를 dismiss함으로써, LoggedIn RIB이 detach된 후 부모 RIB의 뷰 계층에 뷰를 남기지 않도록 보장합니다.

### "Start Game" 버튼을 탭하여 TicTacToe RIB으로 전환하기

이번 튜토리얼에서 이전에 논의한 대로, LoggedIn RIB은 사용자가 OffGame RIB과 TicTacToe RIB 사이를 전환할 수 있도록 해야 합니다. 전자 RIB은 "Start Game" 화면을 표시하고, 후자 RIB은 게임 필드를 그리고 플레이어의 움직임을 처리하는 역할을 맡습니다. 지금까지는 OffGame RIB만 구현하고, 사용자가 로그인한 후 LoggedIn RIB이 제어를 넘겨받도록 했습니다. 이제 TicTacToe RIB을 구현하고, 사용자가 OffGame RIB의 "Start Game" 버튼을 탭한 후에 해당 RIB으로 전환해야 합니다.

이 단계는 "Login" 버튼을 탭할 때 LoggedIn RIB을 attach하고 LoggedOut RIB을 detach하는 작업과 매우 유사합니다. 시간을 절약하기 위해 TicTacToe RIB은 이미 구현되어 프로젝트에 포함되어 있습니다.

TicTacToe로 라우팅하기 위해 LoggedInRouter 클래스에 routeToTicTacToe 메서드를 구현하고, OffGameViewController에서 버튼 탭 이벤트를 OffGameInteractor로 attach하고, 마지막으로 LoggedInInteractor로 attach해야 합니다.

이 작업을 완료하려면 우리의 도움 없이도 할 수 있을 것입니다, 맞죠? 코드를 구현한 후 앱을 실행하여 로그인하고 "Start Game" 버튼을 탭하여 TicTacToe RIB이 로드되고 게임 필드가 표시되는지 확인하세요.

이 연습을 진행할 때, 새로운 OffGameListener의 메서드를 startTicTacToe로 이름을 지정하는 것을 권장합니다. 이 메서드는 이미 유닛 테스트를 위해 스터빙되어 있기 때문에, 나중에 유닛 테스트 타겟을 빌드할 때 컴파일 오류가 발생할 수 있습니다.

### 승자가 결정되었을 때 OffGame RIB을 attach하고 TicTacToe RIB을 detach하기

게임이 끝나면 TicTacToe RIB에서 OffGame RIB으로 전환하고 싶습니다. 이를 위해 이미 연습한 리스너 기반 라우팅 패턴을 사용할 것입니다. 제공된 TicTacToe RIB에는 이미 리스너가 설정되어 있습니다. 이제 LoggedInInteractor에서 이를 구현하여 LoggedIn RIB이 TicTacToe 이벤트에 응답할 수 있도록 해야 합니다.

LoggedInRouting 프로토콜에 routeToOffGame 메서드를 선언하세요.

```
protocol LoggedInRouting: Routing {
    func routeToTicTacToe()
    func routeToOffGame()
    func cleanupViews()
}
```

LoggedInInteractor 클래스에 gameDidEnd 메서드를 구현하세요.

```
// MARK: - TicTacToeListener

func gameDidEnd() {
    router?.routeToOffGame()
}
```

그런 다음 LoggedInRouter 클래스에 routeToOffGame을 구현하세요.

```
func routeToOffGame() {
    detachCurrentChild()
    attachOffGame()
}
```

다음과 같이 private 도움 메서드를 private 섹션 어딘가에 추가하세요.

```
private func detachCurrentChild() {
    if let currentChild = currentChild {
        detachChild(currentChild)
        viewController.dismiss(viewController: currentChild.viewControllable)
    }
}
```

이제 앱은 어느 한 플레이어가 게임에서 승리했을 때 게임 화면에서 시작 화면으로 전환됩니다.

### Unit testing

마지막으로 앱에 대한 단위 테스트를 작성하는 방법을 살펴보겠습니다. RootRouter 클래스를 테스트해 보겠습니다. RIB의 다른 부분에 대해서도 동일한 원리를 적용할 수 있으며, RIB에 대한 모든 단위 테스트를 자동으로 생성해주는 템플릿도 있습니다.

TicTacToeTests/Root 그룹에 새로운 Swift 파일을 생성하고 RootRouterTests라고 이름을 지정하세요. TicTacToeTest 타겟에 추가하세요.

routeToLoggedIn 메서드의 동작을 검증하는 테스트를 작성해 보겠습니다. 이 메서드가 호출되면 RootRouter는 LoggedInBuildable 프로토콜의 build 메서드를 호출하고 반환된 라우터를 attach해야 합니다. 우리는 이미 이 테스트의 구현을 준비했으며, 여기에서 제공하는 코드를 RootRouterTests로 복사하고 테스트가 컴파일되고 통과되는지 확인하세요.

방금 추가한 테스트의 구조를 살펴보겠습니다.

RootRouter를 테스트하기 위해 인스턴스화해야 합니다. Router는 프로토콜 기반의 dependency들을 가지고 있으며, 이 테스트에서 필요한 모든 mock들은 이미 TicTacToeMocks.swift 파일에 제공되어 있습니다. 다른 RIB에 대한 단위 테스트를 작성할 때는 해당 RIB에 대한 mock을 직접 생성해야 합니다.

routeToLoggedIn을 호출할 때 우리의 RootRouter의 구현은 LoggedIn RIB의 build 메서드를 호출하여 해당 Router를 인스턴스화해야 합니다. mock에 빌더 로직을 복사하는 것은 원하지 않으므로, 대신 예상되는 LoggedInRouting 인터페이스를 구현한 라우터 mock을 반환하는 클로저를 전달합니다. 이 클로저는 테스트를 실행하기 전에 구성됩니다.

핸들러 클로저와 함께 작업하는 것은 단위 테스트 중에 자주 사용되는 개발 패턴입니다. 다른 패턴 중 하나는 메서드 호출 횟수를 카운트하는 것입니다. 예를 들어, 우리가 테스트하는 routeToLoggedIn 메서드의 구현에서는 LoggedInBuildable의 build 메서드를 정확히 한 번 호출해야 함을 알고 있으므로, 테스트 대상 메서드를 호출하기 전과 후에 해당 mock의 호출 횟수를 확인합니다.


## 요약

- 상위 RIB의 router는 하위 RIB builder를 갖게 되고 하위 RIB을 attach, detach한다.
- 하위 RIB을 attach, detach 할 때 하위 view를 dismiss 또는 present 해줘야한다.
- interactor의 listener를 통해 상위 RIB과 통신한다.
- view가 없는 RIB은 상위 RIB의 view를 갖게 되고, 자신이 detach 될 때 intractor willResignActive의 router?.cleanupViews() 실행을 통해 router에서 상위 뷰에 present된 view들을 dismiss한다. (템플릿에서 기본으로 제공된다.)
- 상위 RIB이 빌드될 때 하위 RIB들의 빌더를 생성하여 Router에 전달한다. Router는 하위 빌더들을 가지고 있다가 attach 직전에 해당 RIB을 빌드하여 attach한다.
