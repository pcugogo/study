# Layer에 Shadow 적용

## Layer의 Shadow 속성

#### shadowColor
- 그림자 색상

#### shadowRadius
- 그림자 라운딩 값

#### shadowOffset
- 그림자 위치
- width가 x축, height는 y축

#### shadowOpacity
- 그림자 불투명도

## + cornerRadius와 shadow를 함께 설정하는 방법

뷰에 CornerRadius를 적용하려면 clipToBounds를 true로 변경해야하는데, shadow를 적용하려면 clipsToBounds가 false여야한다. (shadow 영역은 view 영역 바깥에서 표시되기때문) 때문에 이를 구현하기 위해서 containerView를 만들어 containerView에 shadow를 적용하고 innerView(containerView의 subView)의 cornerRadius를 변경하면 그림자에 라운딩이 적용된다.

*view의 clipsToBounds를 true로 변경하면 view의 subView의 크기가 view보다 컸을 때, subView가 view 크기만큼만 표시되게 된다.
