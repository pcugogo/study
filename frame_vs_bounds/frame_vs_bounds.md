

## frame vs bounds

### frame

- SuperView의 좌표시스템 안에서 뷰의 위치와 크기를 나타낸다.
 - 뷰의 위치나 크기를 설정하는 경우 사용한다.
- **transform 속성이 identity transform이 아닌 경우이 frame의 값은 정의되지 않는 다.**
- frame을 변경하면 draw(_:)메서드를 호출하지 않아도 자동으로 위치가 업데이트 됩니다.
- frame 속성 변경을 애니메이션으로 표시할 수 있습니다. 그러나 transform 속성이 identity transform가 아닌 다른 속성으로 포함되어 있으면 frame은 정의되지 않습니다. 이 경우 center 속성을 사용하여 뷰의 위치를 조정하고 bounds 속성을 사용하여 크기를 조정하세요.

greenView (SuperView)
blueView (greenView의 SubView)

greenView.frame.origin이 (x: 50 y: 50) 이고, blueView.frame.origin이 (x: 20 y: 20) 이라고 가정할 때 

greenView frame.origin을 (x:0, y:0) 으로 변경하면 greenView의 위치가 좌측 상단에 위치하게 되고
blueView의 위치는 여전히 greenView를 기준으로 x: 20, y: 20에 위치한다.

### bounds

- self의 좌표시스템안에서 위치와 크기를 나타낸다. 
- 뷰 내부에 그림을 그릴때 사용한다.
- bounds을 변경하면 draw(_:)메서드를 호출하지 않아도 자동으로 위치가 업데이트 됩니다.
- bounds 속성 변경을 애니메이션으로 표시할 수 있습니다.

greenView.bounds.origin이 (x: 0 y: 0) 이고, blueView frame.origin이 (x:0 y: 0)이라고 가정할 때 

greenView frame.origin을 (x: 20, y: 20) 으로 변경하면 greenView의 위치가 우측 하단으로 이동하고 나머지 뷰들의 위치는 모두 그대로이다.

이렇게 위치와 크기를 상위 뷰를 기준으로 작성되는지, 자신을 기준으로 작성되는지의 차이가 있다.