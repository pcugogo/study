

# Deeplinking and Workflows

RIBs github의 [튜토리얼](https://github.com/uber/RIBs/wiki/iOS-Tutorial-4)을 통해 RIBs에 대해 이해합니다.

## Goals

튜토리얼 1-3에서는 다섯 개의 RIB으로 구성된 tic-tac-toe 게임을 구축했습니다. 이번 튜토리얼에서는 앱에 딥링크 지원을 추가하는 방법과 Safari에서 URL을 열어 새로운 게임을 시작하는 방법을 안내하겠습니다.

이 연습을 완료한 후에는 RIB 워크플로 및 actionable items의 기본 개념을 이해하고, Safari에서 ribs-training://launchGame?gameId=ticTacToe URL을 열어 앱을 시작하는 방법을 배울 수 있을 것입니다. 이 링크를 열면 앱이 실행되는 것뿐만 아니라 시작 화면을 건너뛰고 새로운 게임을 시작할 수 있습니다.

## handler 핸들러 구현하기

Custom URL schemes 지원 또는 딥링킹은 iOS의 맞춤형 URL을 통한 앱 간 통신을 가능하게 하는 메커니즘입니다. 특정 URL scheme의 handler로 자신을 등록한 앱은 사용자가 다른 앱에서 해당 scheme과 일치하는 URL을 열면 실행됩니다. 열린 앱은 수신한 URL의 내용에 액세스할 수 있으며, URL에 설명된 상태로 전환할 수 있습니다.

TicTacToe 앱을 커스텀 URL scheme ribs-training://의 핸들러로 등록하려면 Info.plist에 다음 라인을 추가해야 합니다.
```
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.uber.TicTacToe</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>ribs-training</string>
        </array>
    </dict>
</array>
```

시스템에서 앱으로 전송된 커스텀 URL을 처리하려면 앱 delegate에 일부 조정을 해야 합니다.

AppDelegate.swift에 UrlHandler라는 새로운 프로토콜을 추가합니다. 이 프로토콜은 나중에 앱별 URL 처리 로직을 포함한 구체적인 클래스에 의해 구현될 것입니다.

```
protocol UrlHandler: class {
    func handle(_ url: URL)
}
```

앱 delegate 내부에 URL 핸들러에 대한 참조를 저장하도록 하여, deeplink URL을 수신한 후 해당 핸들러에 처리를 요청할 수 있도록 합시다. AppDelegate 클래스에 새로운 인스턴스 변수를 추가해주세요.

```
private var urlHandler: UrlHandler?
```

이제, 앱으로 deeplink가 전송되었을 때 트리거되는 AppDelegate의 메서드를 구현해봅시다. 이 메서드에서는 URL을 URL 핸들러로 전달합니다.

```
public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    urlHandler?.handle(url)
    return true
}
```

커스텀 URL은 RIB 계층 구조의 맨 위에 있는 Root RIB에서 처리되어야 합니다. URL을 루트에서 처리하면 deeplink를 수신한 후 원하는 방식으로 앱을 구성할 수 있습니다. 왜냐하면 Root RIB은 모든 하위 RIB을 빌드하고 화면에 표시할 수 있기 때문입니다(직접적으로 또는 RIB 트리를 따라 내려가면서 간접적으로). RootInteractor를 URL 핸들러로 사용하겠습니다. 먼저 RootInteractor가 UrlHandler 및 RootActionableItem 프로토콜을 준수하도록 요구하겠습니다. RootActionableItem은 다음 섹션에서 설명될 빈 프로토콜입니다.

```
final class RootInteractor: PresentableInteractor<RootPresentable>, 
    RootInteractable, 
    RootPresentableListener, 
    RootActionableItem, 
    UrlHandler
```

  
앱 내부에서 URL을 처리하기 위해 "workflow"라는 RIBs 메커니즘을 사용할 것입니다. 워크플로우에 대해서는 다음 섹션에서 더 자세히 설명하겠습니다. 지금은 아래의 코드를 RootInteractor 클래스에 복사해주세요.

```
// MARK: - UrlHandler

func handle(_ url: URL) {
    let launchGameWorkflow = LaunchGameWorkflow(url: url)
    launchGameWorkflow
        .subscribe(self)
        .disposeOnDeactivate(interactor: self)
}
```

이미 Promo 그룹에 워크플로우 스텁이 있습니다. 나중에 적절한 구현으로 대체해야 합니다.

다음으로, RootBuilder를 수정하여 UrlHandler와 RootRouting 인스턴스를 함께 반환하도록 합시다.

```
protocol RootBuildable: Buildable {
    func build() -> (launchRouter: LaunchRouting, urlHandler: UrlHandler)
}
```

```
func build() -> (launchRouter: LaunchRouting, urlHandler: UrlHandler) {
    let viewController = RootViewController()
    let component = RootComponent(dependency: dependency,
                                  rootViewController: viewController)
    let interactor = RootInteractor(presenter: viewController)

    let loggedOutBuilder = LoggedOutBuilder(dependency: component)
    let loggedInBuilder = LoggedInBuilder(dependency: component)
    let router = RootRouter(interactor: interactor,
                            viewController: viewController,
                            loggedOutBuilder: loggedOutBuilder,
                            loggedInBuilder: loggedInBuilder)

    return (router, interactor)
}
```

  
이 모든 변경 사항을 통해 이제 앱 delegate로 돌아가서 이전에 생성한 urlHandler 속성을 초기화할 수 있습니다.

```
public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window

    let result = RootBuilder(dependency: AppComponent()).build()
    launchRouter = result.launchRouter
    urlHandler = result.urlHandler
    launchRouter?.launch(from: window)

    return true
}
```

우리는 앱에 딥링킹 지원을 추가했습니다. ribs-training:// scheme으로 deeplink를 수신한 후, 앱은 RootInteractor에서 정의된 워크플로우를 실행할 것입니다. 하지만 워크플로우는 스텁일 뿐이므로 앱이 열린 후에는 아무런 변경 사항이 없을 것입니다.

## Workflows and actionable items

***RIBs 용어로 말하면, 워크플로우는 특정 작업을 구성하는 일련의 단계***입니다. 이 작업은 RIBs 트리에서 실행될 수 있으며, 작업이 진행됨에 따라 트리를 위로 올라가거나 아래로 내려갈 수 있습니다. 일반적으로 워크플로우는 트리의 루트에서 시작하여 특정 경로를 통해 아래로 이동하며 앱을 기대하는 상태로 전환할 수 있는 지점에 도달합니다. 기본 워크플로우는 액션 가능한 아이템과 제네릭 클래스로 구현되며, 앱별 워크플로우는 기본 워크플로우를 확장하는 것이 기대됩니다.

워크플로우는 반응형 스트림과 함께 사용되며, ReactiveX의 옵저버블에서 찾을 수 있는 것과 유사한 API를 노출합니다. 워크플로우를 시작하기 위해서는 구독해야 하고, 반환된 disposable을 dispose bag에 추가해야 합니다. 이는 일반적인 옵저버블과 동일하게 동작합니다. ***워크플로우가 시작되면, 더 이상 step이 남지 않을 때까지 step별로 비동기적으로 실행***됩니다.

workflow step는 ActionableItem과 해당 값을 짝지은 형태로 정의될 수 있습니다. ***ActionableItem은 해당 step에서 실행되어야 할 로직을 포함***하며, 값은 워크플로우가 진행되면서 step 간에 상태를 전달하는 데 사용되어 결정을 돕습니다.

workflow step의 ActionableItem은 RIB의 interactor가 갖습니다. step를 실행하고 RIBs 트리를 탐색하는 데 필요한 로직을 캡슐화합니다. 기억하시다시피, 이전 스니펫 중 하나에서 우리는 RootInteractor가 RootActionableItem 프로토콜을 준수하도록 했습니다. 이는 RootInteractor가 Root RIB의 ActionableItem으로 동작하길 원한다는 것을 의미합니다.

이전에 생성한 LaunchGameWorkflow는 RootActionableItem 유형으로 파라미터화되어 있습니다. 이는 이 워크플로우가 RootActionableItem 프로토콜을 준수하는 클래스의 코드(우리의 경우에는 RootInteractor 클래스)를 사용하여 첫 번째 step를 구성하고 실행할 것을 의미합니다. RootActionableItem에서 호출된 코드는 결국 두 번째 step를 위해 액션 가능한 아이템과 해당 값을 제공해야 합니다. 첫 번째 step에서는 해당 값이 void로 가정됩니다.

## 워크플로우 구현

이전에 설명한 대로, deeplink를 받은 후 앱은 주어진 identifier로 새 게임을 시작할 수 있어야 합니다. 그러나 플레이어가 로그인하지 않은 경우, 앱은 플레이어가 로그인할 때까지 기다렸다가 그 후에 플레이어를 게임 필드로 리디렉션해야 합니다.

이를 두 개의 step으로 구성된 워크플로우로 모델링할 수 있습니다. 첫 번째 step에서는 플레이어가 로그인했는지 확인하고 필요한 경우 로그인할 때까지 기다립니다. 이 작업은 Root RIB 수준에서 수행됩니다. 플레이어가 준비되었다고 결정한 후, 첫 번째 step은 두 번째 step으로 제어를 전달할 것입니다 (observable 스트림을 통해 값을 방출하여).

두 번째 step은 LoggedIn RIB에 의해 구현될 것입니다. 이 RIB는 Root RIB의 직접적인 자식이며, 새 게임을 시작하는 방법을 알고 있습니다. 해당 router interface는 게임 필드로 이동하려면 routeToGame 메서드를 트리거해야 합니다. 두 번째 step에서는 이 메서드를 트리거합니다. 이로써 워크플로우에서 수행해야 할 작업이 완료됩니다.

플레이어가 로그인할 때까지 기다릴 수 있는 인터페이스를 선언합시다. RootActionableItem 프로토콜로 이동하여 새로운 메서드의 시그니처를 추가하세요.

```
public protocol RootActionableItem: class {
    func waitForLogin() -> Observable<(LoggedInActionableItem, ())>
}
```

위의 메서드 시그니처에서 알 수 있듯이, 이 메서드는 (Next ActionableItemType, Next ValueType) 튜플을 방출하는 observable을 반환합니다. 이 튜플을 사용하여 현재 step이 완료된 후에 실행될 workflow step을 구축할 수 있습니다. observable이 첫 번째 값을 방출하기 전까지는 워크플로우가 차단됩니다. 이러한 반응형 패턴을 통해 워크플로우는 비동기적으로 동작할 수 있으며, 시작 후 즉시 모든 step를 완료할 필요는 없습니다.

또한 우리 경우 NextActionableItemType이 LoggedInActionableItem임을 알 수 있습니다. 이는 두 번째 step를 위해 LoggedIn RIB에 추가해야 할 actionable item의 이름입니다. NextValueType은 Root RIB에서 아래로 워크플로우 체인을 통해 추가 상태를 전달할 필요가 없으므로 void로 설정됩니다.

이제 ActionableItems 그룹 내에 새로운 Swift 파일에서 LoggedInActionableItem 프로토콜을 정의해보겠습니다.

swiftCopy code

```
import RxSwift

public protocol LoggedInActionableItem: class {
    func launchGame(with id: String?) -> Observable<(LoggedInActionableItem, ())>
}
```

이 프로토콜은 우리가 구축 중인 워크플로우의 두 번째 및 마지막 step를 설명합니다. 완료 후 다른 step을 트리거할 필요가 없으므로 LoggedInActionableItem 자체를 다음 actionable item 타입으로 반환합니다. 이는 워크플로우의 타입 제약 조건을 준수하기 위해 필요합니다. 이전 step과 마찬가지로 체인 아래로 추가 데이터를 전달할 필요가 없으므로 void 객체를 step의 값으로 사용합니다.

워크플로우에서 실행되어야 하는 step를 선언한 후, 이제 드디어 워크플로우 자체를 구축할 수 있습니다. 이 워크플로우는 우리의 프로모션 캠페인 중 하나를 지원하기 위해 생성된 딥링크를 가정하고, 워크플로우 구현을 다른 프로모션 관련 코드 근처에 두고자 합니다. Promo 그룹으로 이동하여 더미 워크플로우 파일을 삭제하고 LaunchGameWorkflow.swift라는 새로운 Swift 파일을 추가하세요. 아래 코드 조각을 새 파일로 복사하세요.

```
import RIBs
import RxSwift

public class LaunchGameWorkflow: Workflow<RootActionableItem> {
    public init(url: URL) {
        super.init()

        let gameId = parseGameId(from: url)

        self
            .onStep { (rootItem: RootActionableItem) -> Observable<(LoggedInActionableItem, ())> in
                rootItem.waitForLogin()
            }
            .onStep { (loggedInItem: LoggedInActionableItem, _) -> Observable<(LoggedInActionableItem, ())> in
                loggedInItem.launchGame(with: gameId)
            }
            .commit()
    }

    private func parseGameId(from url: URL) -> String? {
        let components = URLComponents(string: url.absoluteString)
        let items = components?.queryItems ?? []
        for item in items {
            if item.name == "gameId" {
                return item.value
            }
        }

        return nil
    }
}
```

이 코드 스니펫에서는 워크플로우를 직접 초기화하는 방식으로 워크플로우를 구성합니다. 두 개의 workflow step 각각은 Swift 클로저로 구성되며, actionable item과 값(또는 첫 번째 step의 경우 actionable item만)을 매개변수로 받고 (NextActionableItemType, NextValueType) 형태의 튜플을 방출하는 observable을 반환합니다.

내부에서 워크플로우는 클로저를 실행하고 반환된 observable에 구독합니다. 각 step에서 워크플로우는 observable이 첫 번째 값을 방출할 때까지 대기한 다음에 다음 step으로 전환됩니다.

RootInteractor에서 waitForLogin 메서드를 구현하여 RootInteractor가 컴파일될 수 있도록 만들어야 합니다.

먼저, RootInteractor 내에서 이미 선언된 waitForLogin 메서드를 구현합니다. 로그인을 기다리는 것은 비동기 작업입니다. 이를 구현하기 위해 리액티브 서브젝트를 사용할 것입니다. 먼저, RootInteractor 내에서 LoggedInActionableItem을 보유하는 ReplaySubject 상수를 선언해야 합니다.

```
private let loggedInActionableItemSubject = ReplaySubject<LoggedInActionableItem>.create(bufferSize: 1)
```

다음으로, waitForLogin 메서드에서 이 서브젝트를 Observable로 반환해야 합니다. Observable에서 LoggedInActionableItem이 방출되면 사용자의 로그인 대기 step가 완료됩니다. 따라서 LoggedInActionableItem을 actionable item 타입으로 사용하여 다음 step로 이동할 수 있습니다.

```
// MARK: - RootActionableItem

func waitForLogin() -> Observable<(LoggedInActionableItem, ())> {
    return loggedInActionableItemSubject
        .map { (loggedInItem: LoggedInActionableItem) -> (LoggedInActionableItem, ()) in
            (loggedInItem, ())
        }
}
```

마지막으로, Root RIB에서 LoggedIn RIB로 라우팅할 때, LoggedInActionableItem을 ReplaySubject에 방출합니다. 이를 위해 RootInteractor의 didLogin 메서드를 수정합니다.

```
// MARK: - LoggedOutListener

func didLogin(withPlayer1Name player1Name: String, player2Name: String) {
    let loggedInActionableItem = router?.routeToLoggedIn(withPlayer1Name: player1Name, player2Name: player2Name)
    if let loggedInActionableItem = loggedInActionableItem {
        loggedInActionableItemSubject.onNext(loggedInActionableItem)
    }
}
```

didLogin 메서드의 새로운 구현에서 알 수 있듯이, RootRouting 프로토콜의 routeToLoggedIn 메서드를 수정하여 LoggedInActionableItem 인스턴스인 LoggedInInteractor를 반환해야 합니다.

```
protocol RootRouting: ViewableRouting {
    func routeToLoggedIn(withPlayer1Name player1Name: String, player2Name: String) -> LoggedInActionableItem
}
```

이제 RootRouter 구현을 업데이트해야 합니다. RootRouting 프로토콜이 수정되었기 때문입니다. LoggedInActionableItem인 LoggedInInteractor를 반환해야 합니다.

```
func routeToLoggedIn(withPlayer1Name player1Name: String, player2Name: String) -> LoggedInActionableItem {
    // Detach logged out.
    if let loggedOut = self.loggedOut {
        detachChild(loggedOut)
        viewController.replaceModal(viewController: nil)
        self.loggedOut = nil
    }

    let loggedIn = loggedInBuilder.build(withListener: interactor, player1Name: player1Name, player2Name: player2Name)
    attachChild(loggedIn.router)
    return loggedIn.actionableItem
}
```

이에 따라 LoggedInBuildable 프로토콜도 업데이트하여 LoggedInRouting 및 LoggedInActionableItem 인스턴스의 튜플을 반환하도록 합니다.

```
protocol LoggedInBuildable: Buildable {
    func build(withListener listener: LoggedInListener, player1Name: String, player2Name: String) -> (router: LoggedInRouting, actionableItem: LoggedInActionableItem)
}
```

그리고 LoggedInBuilder 구현도 변경 사항을 준수하도록 업데이트해야 합니다. 인터랙터도 반환해야 합니다. 앞서 언급했듯이, 스코프의 인터랙터는 해당 스코프의 actionable item입니다.

```
func build(withListener listener: LoggedInListener, player1Name: String, player2Name: String) -> (router: LoggedInRouting, actionableItem: LoggedInActionableItem) {
    let component = LoggedInComponent(dependency: dependency,
                                      player1Name: player1Name,
                                      player2Name: player2Name)
    let interactor = LoggedInInteractor(games: component.games)
    interactor.listener = listener

    let offGameBuilder = OffGameBuilder(dependency: component)
    let router = LoggedInRouter(interactor: interactor,
                          viewController: component.loggedInViewController,
                          offGameBuilder: offGameBuilder)
    return (router, interactor)
}
```

이러한 변경 사항을 통해 워크플로우의 첫 번째 step을 구현했습니다. 실행 후, 워크플로우는 사용자가 로그인할 때까지 대기한 다음 게임을 시작하기 위해 LoggedIn RIB에 구현해야 할 두 번째 step로 전환됩니다.

## LoggedInInteractor를 업데이트하여 이전에 선언한 LoggedInActionableItem 프로토콜을 준수하도록 합시다. 

각 scope의 interactor는 해당 scope의 actionable item 프로토콜을 항상 준수해야 함을 상기하세요.

```
final class LoggedInInteractor: Interactor, LoggedInInteractable, LoggedInActionableItem
```

LoggedInActionableItem 프로토콜에서 요구하는 launchGame 메서드의 제공된 구현을 사용할 수 있습니다. 이 메서드는 워크플로우의 두 번째 step에 대한 로직을 구현합니다.

```
// MARK: - LoggedInActionableItem

func launchGame(with id: String?) -> Observable<(LoggedInActionableItem, ())> {
    let game: Game? = games.first { game in
        return game.id.lowercased() == id?.lowercased() 
    }

    if let game = game {
        router?.routeToGame(with: game.builder)
    }

    return Observable.just((self, ()))
}
```

이 메서드의 구현에서 보시는 대로, LoggedIn의 router에게 게임 필드로 이동하도록 요청한 후, 예상되는 유형 제약을 준수하기 위해 observable을 반환합니다. 이 step은 워크플로우에서 마지막이므로 반환된 actionable 유형은 실제로 사용되지 않습니다.

## 워크플로우를 실행

두 개의 워크플로우 step을 모두 구현한 후, 딥링킹 메커니즘과 워크플로우가 예상대로 작동하는지 확인하기 위해 애플리케이션을 테스트할 수 있습니다.

애플리케이션을 빌드하고 실행한 후에 종료하고, 핸드폰의 Safari 브라우저를 엽니다. ribs-training://launchGame?gameId=ticTacToe URL을 입력한 다음 "이동"을 탭하세요. Safari에서 TicTacToe 앱을 열도록 요청할 것입니다. 앱에 로그인한 후에는 시작 화면 대신 게임 필드를 볼 수 있습니다. 이는 우리가 구현한 워크플로우를 실행할 때 구성한 것입니다.

ticTacToe 대신에 randomWin을 게임 identifier로 사용해 볼 수도 있습니다. 이 경우 다른 게임 화면으로 이동될 것입니다.

앱을 종료하지 않고 게임에 로그인한 후 Safari로 전환하면 URL을 입력한 후 바로 게임 필드로 이동하게 됩니다. 이는 워크플로우가 이미 로그인되어 있음을 즉시 인식하기 때문에 플레이어가 로그인할 때까지 기다리지 않습니다.

## 정리

- 딥링킹을 할 때, Workflow라는 class를 활용할 수 있다.
- 커스텀 URL을 통한 딥링킹을 할 때, 워크플로우는 최상위 RIB의 interactor에서 생성된다. 
- 워크플로우가 시작되면, 더 이상 step이 남지 않을 때까지 step별로 비동기적으로 실행된다.
- ActionableItem은 아래 코드와 같이 해당 step에서 실행되어야 할 로직을 포함한다.
	```
	public protocol RootActionableItem: class {
    func waitForLogin() -> Observable<(LoggedInActionableItem, ())>
    }
    ```