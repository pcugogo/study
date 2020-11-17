# App Connect 초기 업로드 및 인증서 생성 정리

##  App Connect & Xcode Settings

1. developer.apple.com 로그인 -> account -> Certificates, IDs & Profiles 로 이동
2. Identifiers 생성
 - App IDs (앱등록을 위한 ID) 선택 -> APP 선택 -> 설명 & 번들 & Capablilties (Push Notifications 애플 로그인 등 기능을 선택) 작성
3. Devices 등록 -> 테스트할 기기의 UUID 또는 UDID를 작성하여 생성
4. 키체인 -> 상단의 키체인 접근 탭 -> 인증서 지원 -> 인증서 기관에서 인증서 요청 ->
    CA 이메일 주소 외에 모두 작성 -> 디스크에 저장됨, 본인이 키 쌍 정보 지정 선택 후 생성 -> 2048 비트, RSA 기본 설정으로 생성 -> 인증서 폴더를 생성하여 생성한 파일을 보관 -> 생성 파일을 키체인에 드래그하여 키체인 등록
    
### [인증서 자동 생성 Ver.] 

5. 바로아래 App Connect Upload 단계로 진입 

### [인증서 수동 생성 Ver.] 

5. Certificate 생성 배포용은 iOS Distribution, 개발용은 iOS App Development를 선택 후
    파일 선택 단계 에서 4번에서 생성한 인증서를 선택 후 생성하여 다운로드 -> 다운로드한 인증서 파일을 4번에서 생성한 폴더에 함께 보관 -> 키체인에 드래그하여 등록
6. profiles 에서 위에서 생성한 ID, Device, 인증서를 선택하여 프로비저닝 파일을 생성
7. xcode Signing & Capabilities Provisioning Profile 에서 생성 된 프로비저닝 파일을 선택
 자동으로 디스플레이 되기도 하지만 자동으로 디스플레이 되지않을 시 automatically manage signing 체크를 해제하고 import profile을 선택하여 생성한 프로비저닝 파일을 선택한다.
 
###  [참고 링크] 

[인증서 생성 및 앱 커넥트 업로드 플로우](https://dev-yakuza.posstree.com/ko/react-native/ios-certification/)

[Line 기술 블로그 인증서 관련 글](https://engineering.linecorp.com/ko/blog/ios-code-signing/)

[코드 사이닝, 인증서, 프로비저닝이란?](https://medium.com/jinshine-%EA%B8%B0%EC%88%A0-%EB%B8%94%EB%A1%9C%EA%B7%B8/%EC%BD%94%EB%93%9C%EC%82%AC%EC%9D%B4%EB%8B%9D-%EC%9D%B8%EC%A6%9D%EC%84%9C-%ED%94%84%EB%A1%9C%EB%B9%84%EC%A0%80%EB%8B%9D-%ED%94%84%EB%A1%9C%ED%8C%8C%EC%9D%BC%EC%9D%B4%EB%9E%80-2bd2c652d00f)


## App Connect Upload

1. xcode 상단 메뉴인 Product -> Achive를 선택하여 앱을 아카이빙한다.
2. window -> Organizer 에서 오른쪽 Distribute App 버튼을 클릭

### [자동 인증서 선택 Ver.] 

3. App Store Connect 체크하여 Next > 다음 계속 기본 체크로 Next > Automatically manage signing, manually manage signing 에서 Automatically manage signing을 선택합니다. 

이  옵션을 선택하게 되면 여러 과정들을 생략할 수 있으며 

앱 배포 시에 따로 배포 인증서 선택을 하지않고 항상 Automatically 옵션을 선택하여 간편하게 배포를 할 수 있습니다.  

*Xcode 11 버전에서 자동으로 생성 되는 인증서 타입은 Apple Distribution 이며,  기존 배포 인증서는 iOS Distribution이었습니다. 

Apple Distribution은 iOS, tvOS, watchOS, macOS 등의 배포 가능한 인증서이며, iOS Distribution은 iOS, tvOS 등의 배포가 가능한 인증서 입니다. 

[Apple Distribution VS iOS Distribution 참고사이트](https://qiita.com/Arime/items/e9816a4f1fd08b1406c0)

### [수동 인증서 선택 Ver.] 

3. App Store Connect 체크하여 Next > 다음 계속 기본 체크로 Next > Automatically manage signing, manually manage signing 에서 manually signing 을 선택하여 CranePop.app 옆의 탭을 클릭하여 CranePop_iOS를 선택 후 next > Upload를 클릭