# ReactorKit
ReactorKit 학습 & 경험을 정리합니다.

## ReactorKit 이란?

Flux와 Reactive Programming의 개념을 결합하여 만들어진 아키텍처 프레임워크입니다.

Flux는 페이스북에서 고안한 아키텍처이며, Dispatcher > Store > View > Action > Dispatcher 이렇게 단방향 데이터 흐름을 가지고 있습니다.
(MVC는 뷰 <-> 컨트롤러 <-> 모델 이런 흐름을 가지고 있으므로 양방향 아키텍처라고 할 수 있습니다.)

자세한 내용은 [Flux 소개](https://haruair.github.io/flux/docs/overview.html) 글을 읽어보시면 좋을 것 같습니다.


ReactorKit은 Flux와 같이 View -> Action -> Reactor -> State -> View 이런 단방향 데이터 흐름을 가지고 있습니다. 이렇게 단방향으로 데이터가 흐르게 되면서 데이터 관리가 수월해집니다.
또 Rx와 사용하기 매우 편리합니다.

## ReactorKit의 장점

1. 상태 관리가 수월하다.
 - 리액터로 액션을 보내면 mutate 함수에 작성된 비즈니스 로직을 통해 데이터가 가공됩니다. 사이드 이펙트도 여기서 처리하게 됩니다. 상태에 문제가 생기게 되면 이곳에서 확인을 할 수 있으며, 아예 반응이 없는 경우는 뷰의 바인딩 부분이나 reduce를 확인해 볼 수 있습니다.
 
2. 단방향 아키텍처를 사용하기 위한 기능이 모두 구현 되어 있다.
 - MVVM 패턴을 새로 작성할 경우 추상화를 위한 프로토콜 작성이나 바인딩 구현 등 다양한 코드를 작성해야합니다. 또 개인마다 구현 방식에 차이가 있기때문에 서로 코드를 이해하는데 어느정도 시간이 들 수 있습니다. 
 - ReactorKit은 프레임워크이므로 단방향 아키텍처 개발을 위한 기능이 모두 구현 되어 있습니다. 이 차이는 마치 빈칸에 글씨를 채우냐 아니면 글을 처음부터 모두 작성하느냐 같은 느낌이라고 생각합니다. (물론 MVVM도 한번 템플릿화 해놓으면 재사용이 가능합니다..)

3. 유닛 테스트가 매우 편리하다.
 - 리액터는 UI 레이어에서 독립적이기 때문에 테스트하기 쉽습니다.
 - 리액터를 테스트 할때 인풋 아웃풋이 굉장히 쉽기때문에 테스트가 매우 수월합니다.

### 참고 자료

[Flux 소개 사이트](https://haruair.github.io/flux/docs/overview.html)

[ReactorKit Github](https://github.com/ReactorKit/ReactorKit)

[전수열님의 미디엄 글](https://medium.com/styleshare/reactorkit-%EC%8B%9C%EC%9E%91%ED%95%98%EA%B8%B0-c7b52fbb131a)