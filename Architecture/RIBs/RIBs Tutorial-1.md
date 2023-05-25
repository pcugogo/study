# Create your first RIB

## 설치
1. RIBs 클론 (https://github.com/uber/RIBs)
2. 터미널로 cd .../RIBs/ios/tooling 경로 진입
3. sh install-xcode-template.sh 실행
4. Xcode에서 RIB 생성 가능

## Tutorials 
RIBs github의 [튜토리얼](https://github.com/uber/RIBs/tree/main/ios/tutorials)을 통해 RIBs에 대해 이해합니다.

## Tutorial1
RIBs -> ios -> tutorials -> tutrial1 -> TicTacToe 프로젝트의 Cocoa Pods 를 설치한다.

코코아팟을 설치할 때 아키텍쳐 호환 문제나미니멈 타겟 문제로 error가 발생할 수 있다. 아키텍쳐 문제는 arch -x86_64 pod install 명령어로 해결하고, 미니멈 타겟 문제는 코코아팟 버전을 올려 해결했다.

### Goal
이 튜토리얼의 목표는 RIB의 다양한 부분을 이해하고 더 중요한 것은 서로 상호 작용하고 통신하는 방법을 이해하는 것입니다. 로그인 버튼을 누르면 플레이어의 이름이 Xcode 콘솔에 프린트 되는 앱을 만듭니다.

### 프로젝트 구조
제공되는 코드는 두 개의 RIB으로 구성된 iOS 프로젝트를 포함합니다. 앱을 실행하면 AppDelegate가 Root RIB을 생성하고 애플리케이션의 제어권을 Root RIB에 전달합니다. Root RIB의 목적은 RIB 트리의 루트 역할을 하고 필요할 때 자식에게 제어권을 전달하는 것입니다. Root RIB의 코드는 대부분 Xcode 템플릿에 의해 자동 생성됩니다. 이 코드를 이해하는 것은 튜토리얼을 진행할 때 필요하지 않습니다.

TicTacToe 앱에서 두 번째 RIB은 LoggedOut이라고 부르며, 로그인 인터페이스를 포함하고 인증 관련 이벤트를 처리해야합니다. AppDelegate에서 앱 제어권을 Root RIB에게서 받으면 즉시 LoggedOut RIB에게 전달하여 로그인 폼을 표시합니다. LoggedOut RIB을 빌드하고 표시하는 코드는 RootRouter에서 이미 제공되므로 별도로 구현할 필요가 없습니다.

현재 LoggedOut RIB은 구현되어 있지 않습니다. LoggedOut 그룹을 열면 컴파일에 필요한 Stub이 포함된 DELETE_ME.swift 파일만 찾을 수 있습니다. 이 튜토리얼에서는 LoggedOut RIB의 적절한 구현을 만들 것입니다.

### Create LoggedOut RIB
LoggedOut 그룹에서 New File을 누른 후 RIB 템플릿을 선택하여 파일을 생성합니다.

RIB이 자체적인 뷰(컨트롤러)를 갖는 것은 필수적이지 않습니다. 그러나 우리는 LoggedOut RIB을 위해 뷰컨트롤러를 생성하고자 합니다. 왜냐하면 이 RIB은 로그인 인터페이스 (즉, 플레이어 이름이 있는 텍스트 필드 및 "로그인" 버튼)의 구현을 포함해야하기 때문입니다. "Owns corresponding view" 확인란을 선택하면 새 RIB가 해당하는 뷰컨트롤러 클래스와 함께 생성되도록 보장할 수 있습니다.

이제 DLELTE_ME.swift 파일은 필요 없기때문에 삭제하면 됩니다.

### 생성된 코드 이해

![[RIBs Understanding the generated code.png]]

우리는 방금 LoggedOut RIB을 구성하는 모든 클래스를 생성했습니다.

LoggedOutBuilder는 LoggedOutBuildable 프로토콜을 준수하므로 Builder를 사용하는 다른 RIBs는 Buildable 프로토콜을 준수하는 mock 인스턴스를 사용할 수 있습니다. 

LoggedOutInteractor는 LoggedOutRouting 프로토콜을 사용하여 Router와 통신합니다. 이는 의존성 역전 원칙에 기반한 것으로, Interactor가 필요한 것을 선언하고 이를 제공하는 무언가, 이 경우 LoggedOutRouter가 구현을 제공합니다. Buildable 프로토콜과 마찬가지로 Interactor를 단위 테스트 할 수 있도록합니다. 

LoggedOutPresentable은 Interactor가 ViewController와 통신할 수 있도록 하는 동일한 개념입니다. LoggedOutRouter는 LoggedOutInteractable에서 필요한 것을 선언하여 Interactor와 통신합니다. LoggedOutViewController와 통신하기 위해 LoggedOutViewControllable을 사용합니다. LoggedOutViewController는 LoggedOutPresentableListener를 사용하여 Interactor와 통신하며 동일한 의존성 역전 원칙을 따릅니다.

-> 의존성 주입이 가능하도록 하여 mocking을 수월하게 할 수 있고, 서로의 의존성을 끊어줘서 재사용에 용이하다.

### Login Logic

유저가 "Login" 버튼을 누른 후, LoggedOutViewController는 리스너(LoggedOutPresentableListener)를 호출하여 사용자가 로그인을 원한다는 것을 알려야 합니다. 리스너는 로그인 요청을 처리하려면 게임에 참가하는 플레이어의 이름을 받아야 합니다.

이 로직을 구현하려면, 뷰 컨트롤러에서 리스너를 업데이트하여 뷰 컨트롤러로부터 로그인 요청을 받도록 해야 합니다.

LoggedOutViewController.swift 파일에서 LoggedOutPresentableListener 프로토콜을 다음과 같이 수정하세요:

```
protocol LoggedOutPresentableListener: class {
    func login(withPlayer1Name player1Name: String?, player2Name: String?)
}
```

두 플레이어 이름 모두 선택적(optional)이므로 사용자가 플레이어 이름을 입력하지 않을 수도 있습니다. 두 이름이 모두 입력될 때까지 로그인 버튼을 비활성화할 수 있지만, 이 연습에서는 LoggedOutInteractor가 빈 이름을 처리하도록 합니다. 이름이 비어 있으면, 구현에서는 기본적으로 "Player 1"과 "Player 2"로 설정합니다.

이제 다음 메서드를 추가하여 `LoggedOutInteractor` 수정된 프로토콜을 준수하도록 수정합니다. `LoggedOutPresentableListener`

```
// MARK: - LoggedOutPresentableListener
func login(withPlayer1Name player1Name: String?, player2Name: String?) {
    let player1NameWithDefault = playerName(player1Name, withDefaultName: "Player 1")
    let player2NameWithDefault = playerName(player2Name, withDefaultName: "Player 2")

    print("\(player1NameWithDefault) vs \(player2NameWithDefault)")
}

private func playerName(_ name: String?, withDefaultName defaultName: String) -> String {
    if let name = name {
        return name.isEmpty ? defaultName : name
    } else {
        return defaultName
    }
}
```

마지막으로 아래 코드를 추가하여 버튼을 누르면 로그인 리스너를 호출하도록합니다.

```
@objc private func didTapLoginButton() {
    listener?.login(withPlayer1Name: player1Field?.text, player2Name: player2Field?.text)
}
```

### 튜토리얼 완료

첫 번째 RIB을 생성했습니다. 이 튜토리얼에서는 Xcode 템플릿에서 새 RIB을 생성하고 인터페이스를 업데이트 했으며 뷰컨트롤러에서 인터랙터로 사용자가 입력하 데이터를 전달하는 버튼 탭 이벤트에 대한 핸들러를 추가했습니다. 이를 통해 두 유닛 사이의 책임이 분리되었고 testable한 코드를 작성하게 되었습니다.


## RIBs Intractor <-> View 통신 플로우

View는 Interactor에게 유저 입력을 받아 비즈니스 로직 수행을 요청한다.
Interactor는 View에게 가공된 데이터를 전달하고 View는 데이터를 받아 화면을 업데이트한다.

