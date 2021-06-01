# Firebase Remote Config

Firebase Remote Config란 이름처럼 Firebase에서 지원하는 원격으로 엡의 데이터를 구성하는 기능입니다. 이 기능을 통해 앱을 새로 배포하지 않고도 앱의 레이아웃 또는 색상 테마 등을 변경할 수 있습니다.
이 기능은 A/B 테스트에도 매우 유용합니다.

## 앱에 Remote Config 추가를 위한 Step

1. 원격 구성 객체 생성

```
remoteConfig = RemoteConfig.remoteConfig()
let settings = RemoteConfigSettings()
settings.minimumFetchInterval = 0
remoteConfig.configSettings = settings
```
minimumFetchInterval의 기본 값은 12시간입니다.

2. in-app default parameter 설정
remote config 객체에 in-app parameter 값을 설정하여 *앱이 remote config 백엔드에 연결되기 전에  기본 값을 사용할 수 있도록 할 수 있습니다.*

```
remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
```

3. 앱에서 사용할 파라미터 변수 가져오기
이제 RemoteConfig.remoteConfig().configValue(forKey: key) (fetched value, in-app default value, initilalise value) 를 통해 값을 가져올 수 있습니다. 3. 내용과 같이 백엔드에 아무것도 설정되지 않은 경우 setDefaults를 통해 설정된 값을 가져옵니다.

4. 파라미터 값 설정
Firebase 콘솔을 통해 Remote Config Value를 설정

5. value fetch 및 활성화
remote config에서 매개 변수 값을 가져 오려면 fetch():또는 fetch(withExpirationDuration:) 메소드를 호출하세요. 백엔드에 설정 한 모든 값은 원격 구성 개체에서 가져 와서 *캐시*됩니다.

여기서 fetch() 파라미터에 캐싱 타임을 입력할 수 있습니다. 예를 들어 3600초를 입력할 경우 1시간 동안 캐시 데이터가 유지되고 이 시간 동안 새로운 데이터를 패치하지 않습니다.
패치를 빈번하게 자주할 경우 호출이 제한되기 때문에 이 값을 너무 낮게하면 안됩니다. 자세한 내용은 아래 Throttling에 작성되었습니다.

한 번의 호출로 값을 가져오고 활성화하려는 경우 fetchAndActivateWithCompletionHandler: 사용합니다.

아래 예에서는 원격 구성 백엔드에서 값 (캐시 된 값 아님)을 가져오고 activate() 를 호출하여 앱에서 사용할 수 있도록합니다.

```
remoteConfig.fetch() { (status, error) -> Void in
  if status == .success {
    print("Config fetched!")
    self.remoteConfig.activate() { (changed, error) in
      // ...
    }
  } else {
    print("Config not fetched")
    print("Error: \(error?.localizedDescription ?? "No error available.")")
  }
  self.displayWelcome()
}
```

이러한 업데이트 된 매개 변수 값은 앱의 동작과 모양에 영향을 미치므로 사용자가 다음에 앱을 열 때와 같이 사용자에게 원활한 경험을 보장하는 한 번에 가져온 값을 활성화해야합니다.

### remote config Loading 전략

전략 1: Fetch and activate on load
앱이 처음 시작 될 때 fetch(), activate()를 실행하여 데이터를 업데이트
이 방식은 UI에 극적인 시각적 변화를 일으키지 않는 구성 변경에 적합합니다. 사용자가 사용하는 동안 UI가 눈에 띄게 변경 될 수 있는 상황에서 피해야합니다.

전략 2: Activate behind loading screen
앱을 바로 시작하는 대신 로딩 화면을 표시하고 fetch(), activate()를 호출
전략 1에서 발생할 수 있는 잠재적인 UI 문제에 대한 해결책으로 사용할 수 있습니다.

전략 3: Load new values for next startup
효과적인 전략은 앱의 다음 실행시 활성화할 새 구성 값을 로드 하는 것입니다. 이 전략에서 앱은 새 config 값을 이미 가져왔지만 아직 활성화하지 않았다는 가정하에 새 config 값을 가져 오기 전에 시작시 가져온 값을 활성화합니다. 이 전략의 작업 순서는 다음과 같습니다.
1. 시작시 이전에 가져온 값을 즉시 활성화
2. 사용자가 앱과 상호 작용하는 동안 기본 minimumfetchInterval에 따라 새 값을 패치하는 비동기 호출을 시작
3. 패치 완료 핸들러 또는 콜백에서 아무 작업도 수행하지 않습니다. 다음에 앱을 시작할 때 활성화 할 때까지 앱은 다운로드 된 값을 유지합니다.

## Throttling

앱이 짧은 시간에 너무 많이 패치를 할 경우 호출이 제한되고 SDK는 FIRRemoteConfigFetchStatusThrottled를 반환합니다.

remote config의 기본 권장 production fetch interval은 12 시간입니다. 즉, 실제로 수행 된 fetch 호출 횟수에 관계없이 12시간 동안 백엔드에서 config를 두 번 이상 fetch하지 않습니다. 특히 minimumFetchInterval은 다음 순서로 결정됩니다.
1. fetch()의 파라미터
2. FIRRemoteConfigSettings.MinimumFetchInterval의 파라미터
3. 기본 값은 12 시간

## 출처
[Firebase 공식 문서](https://firebase.google.com/docs/remote-config)