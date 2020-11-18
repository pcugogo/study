# APNs 간단 정리

## APNs(Apple push notification service)란?
APN은 애플의 푸쉬 알림 서비스입니다. 앱개발자가 iOS 장치에 정보를 보낼 수 있는 안전하고 효율 적인 서비스입니다.

사용자 기기에서 앱을 처음 시작할 때 시스템은 앱과 APN간에 인증되고 암호화 된 영구 IP 연결을 자동으로 설정합니다. 이 연결을 통해 앱은 원격 알림 지원 구성을 하여 알림을 수신 할 수 있도록 설정을 할 수 있습니다.

APN에 대해 구체적으로 이해하고 싶으시다면 [Apple 공식 문서](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html#//apple_ref/doc/uid/TP40008194-CH8-SW1)에 정리가 잘 되어 있으므로 살펴보시기바랍니다.

우선 APN 기능을 사용하려면 개발자 계정이 있어야합니다. 
개발자 계정의 개발자 페이지에서 푸쉬 서비스의 키를 생성할 수 있기때문입니다.

클라이언트 APNs 구현 흐름은 간략하게 인증서 생성 -> Xcode 설정 -> Notification 코드 작성 순서가 되겠습니다.

## 인증서 & 인증키 생성

### 1. 개인 인증서 생성
먼저 개인 인증서를 생성해야합니다. 기존에 생성 해두신 개인인증서가 있으시다면 다음 단계로 바로 가시면 됩니다. 개인 인증서는 런치패드 -> 기타 -> 키체인(열쇠모양) -> 상단 메뉴의 키체인 접근 -> 인증서 지원 -> 인증 기관에서 인증서 요청을 선택한 후 사용자 이메일주소, 일반 이름을 작성 후 디스크에 저장됨 본인이 키 쌍 정보지정을 체크하고 계속 버튼을 눌러 다음으로 넘어갑니다. 파일 위치를 정해 저장하시고 (푸쉬 기능 인증서 발급 외에도 다른 인증서 발급시 계속해서 사용되므로 파일 위치를 잘정하여 분류해야합니다.) 키 크기 2048, 알고리즘 RSA 기본 작성 그데로 두시고 계속을 누른 후 완료 버튼을 누릅니다.

### 2. 푸쉬 인증서 생성

### p.8 vs p.12
인증키 생성은 p.12 파일을 생성하는 방법과 p.8 파일을 생성하는 방법이 있습니다.
.p8과 .p12는 포멧이라고 하며, 큰 차이는 .p12는 1년마다 재발급을 해야하고 p8은 그렇게 하지 않아도 된다고합니다. 정확한 부분은 저도 숙지하고 있지 못하기때문에 서버 상황에 따라 발급 받으시면 되겠습니다.

### p.8 생성
개발자 페이지 -> Account -> Certificates, Identifiers & Profiles -> Keys 페이지로 이동하여
키 이름을 정하고 Apple Push NOtifications Service(APNs)를 체크하고 Continue 버튼을 눌러 다음 페이지로 이동한 후 키를 안전한 위치에 꼭 다운로드 합니다. (인증서끼리 한 폴더에 폴더링을 잘하여 보관해두는 것이 좋습니다.) .8 인증키 생성이 완료 되었습니다.

### p.12 생성
개발자 페이지 -> Account -> Certificates, Identifiers & Profiles -> Identifiers -> 해당 앱 클릭 ->
Capablities에서 Push Notifications를 체크하고 Edit버튼을 누릅니다 -> 팝업된 윈도우를 통해
Create Certificate 버튼을 눌러 인증서를 발급하고 안전한 위치에 꼭 다운로드 합니다. (인증서끼리 한 폴더에 폴더링을 잘하여 보관해두는 것이 좋습니다.)  .12 인증서 생성이 완료 되었습니다.

서버에 따라 .pem 포멧 파일로 변환하여 전달해야할 수 있습니다.
pem 파일 생성 방법은 여기에 잘 정리 되어있습니다. [DEVELOPER LEBY님의 블로그](https://app-developer.tistory.com/149)

## Xcode 설정
프로젝트 타겟 -> Signing & Capabilites 에서 +Capability를 눌러 Push Notification, Background Modes를 선택합니다.

signing 아래 기능들이 추가 된 것을 확인하 실 수 있습니다. 이제 Background Modes에서 Remote notifications를  체크하면 기본적인 세팅이 완료 되었습니다.


## Remote Push 로컬 테스트

Xcode 11.4버전부터 Remote Push를 시뮬레이터로 사용할 수 있습니다.
간단하게 APNs 파일을 생성하여 시뮬레이터에 드래그하면 됩니다.
이 테스트로 APN 서버에서 기기로 알림을 보내는 과정의 테스트를 진행 할 수 있습니다.
여기에 잘 정리 되어있습니다. [토미의 개발노트님의 블로그](https://jusung.github.io/apns-test/)
* APNs 파일은 Json 형식으로 텍스트를 작성하여 저장한 뒤에 파일 이름 뒤에 .apns를 입력하여 확장명을 바꾸면됩니다.
* 물론 서버와의 네트워크 테스트는 실제 서버에서 APN 서버에 알림요청을 보내 테스트 해야합니다.

### 참고 사이트

[Apple 공식 문서](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html#//apple_ref/doc/uid/TP40008194-CH8-SW1)

[겸손할 겸님 블로그](https://g-y-e-o-m.tistory.com/72)

[토미의 개발노트님의 블로그](https://jusung.github.io/apns-test/)