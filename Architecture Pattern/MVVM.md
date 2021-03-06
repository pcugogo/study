# MVVM
**MVVM(Model/View/ViewModel) 패턴은 UI를 가지는 응용프로그램을 위한 아키텍처 패턴(architectural pattern)** 이다. MVVM 패턴은 MVC(Model/View/Controller) 패턴의 변형으로 **뷰의 추상화를 만드는 것이 핵심이다.**

## Model / ViewModel / View(Controller)

- Model: 비즈니스 로직과 데이터를 캡슐화
- View: UI 레이아웃, UI 업데이트
- ViewModel: View의 추상화 된 모형으로 프리젠터 로직을 담당하며, View에서 사용되기 쉽게 데이터를 가공

## MVVM의 동작

1. 사용자의 Action을 뷰가 받는다.
2. 뷰의 Action과 바인딩 된 뷰모델의 데이터가 반응하여(Input) 모델에게 데이터를 요청한다.
3. 모델은 뷰모델에 데이터를 넘겨준다.
4. 뷰모델은 데이터를 넘겨받아 가공하여 저장한다.
5. 뷰는 뷰모델의 가공되어 저장된 데이터에 반응하여 UI를 업데이트한다.(Output)

## MVVM 패턴 구현의 핵심

Commands Pattern: 뷰에서 사용될 명령들을 프로토콜로 추상화하고 이 프로토콜을 뷰모델이 채택하여 명령들을 구현하게 됩니다. 추상화된 명령에 대해 로직을 구현함으로써 어떤 객체가 명령을 하여도 뷰모델은 같은 동작을 수행하게 되므로 테스트에 용이하고 뷰모델의 로직이 변경되어도 프로토콜에 정의된 기능이 변하지 않는다면 뷰컨트롤러 코드를 수정할 필요가 없게 됩니다.

DataBinding: 뷰의 UI와 뷰모델 데이터를 묶어 서로 반응하게 만듭니다. 
예를 들어 뷰의 버튼이 터치를 받아 액션을 실행하면 뷰모델의 데이터가 버튼 액션에 반응하여 어떤 로직을 수행하고(Input) 뷰모델에서 로직을 수행하여 결과물을 뷰모델의 데이터에 반영하면 뷰의 UI가 반응하여 UI가 업데이트됩니다.(Output)

## MVVM의 장점

- 시각 디자인과 표현 논리를 독립적으로 구현할 수 있다.
 - 뷰와 로직이 분리 되면서 코드를 분석하는 것이 용이하고 로직에 대한 유닛 테스트를 하기도 수월합니다.
- View와 ViewModel은 정의된 프로토콜을 의존하기 때문에 서로에 대한 의존성이 제거되어 코드를 리팩토링 하는 것이 수월합니다.
 - 예를들어, 뷰모델의 로직을 변경하여도 뷰컨트롤러는 코드를 변경하지 않아도 됩니다.
- Input, Output으로 나눌 수 있어, 코드를 이해하는데 좀 더 수월하다.

### [참고 자료](https://justhackem.wordpress.com/2017/03/05/mvvm-architectural-pattern/)
