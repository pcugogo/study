# Intrinsic Content Size

일부 뷰들은 콘텐츠 고유 크기를 갖습니다. 예를 들어 **Button의 intrinsic content size 크기는 title 크기에 작은 여백을 더한 것**입니다.

**모든 뷰가 고유 컨텐츠 크기를 가지고 있는 것은 아니며, 고유 컨텐츠 크기를 가지고 있는 뷰의 경우 내장 콘텐츠 크기는 뷰의 높이, 너비, 또는 둘 다를 정의할 수 있습니다.**

| View | Intrinsic Content Size |
|---|---|---|
|UIView and NSView|Intrinsic content size가 없습니다.|
|Sildies|Width(iOS)만 정의합니다. 슬라이더 유형(OS X)에 따라 Width, Height 또는 둘 다를 정의합니다.|
|Label, Button, Switch, TextField|Witdh와 Height를 모두 정의합니다.|
|TextView, ImageView| Content 크기에 따라 변화합니다.|

Intrinsic Content Size는 View의 Content를 기반으로 정해집니다. **Label 또는 Button의 Intrinsic Content 크기는 text 의 크기와 font 를 기반으로 정해집니다.** 다른 뷰의 경우 고유 컨텐츠 크기가 훨씬 더 복잡합니다. 예를 들어, **빈 이미지뷰에는 고유 콘텐츠 크기가 없습니다. 하지만 이미지를 추가하자마자 고유 콘텐츠 크기가 이미지 크기로 설정됩니다.**

텍스트뷰의 고유 콘텐츠 크기는 콘텐츠, 스크롤 사용 여부 및 뷰에 적용된 다른 제약 조건에 따라 달라집니다. 예를 들어 스크롤이 활성화 된 경우 뷰에 고유 콘텐츠 크기가 없습니다. 스크롤을 사용하지 않으면 기본적으로 뷰의 고유 콘텐츠 크기는 줄바꿈이 되지 않은 한줄의 텍스트 크기로 레이아웃에 필요한 Width와 Height 크기로 정해집니다.

오토레이아웃은 각 dimension에 대한 한쌍의 Contraint 를 사용하여 뷰의 고유 컨텐츠 크기를 나타냅니다. Content Hugging은 뷰의 안쪽으로 당겨 컨텐츠 주변에 맞도록 합니다. compression resistance 는 컨텐츠를 자르지 않도록 뷰를 바깥쪽을 밀어냅니다.

![Auto layout](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/Art/intrinsic_content_size_2x.png)

가능하면 레이아웃에서 뷰의 intrinsic Content Size 크기를 사용하는 것이 좋습니다. 뷰의 컨텐츠가 변경되면 레이아웃이 동적으로 조정됩니다. 또한 모호하지 않고 충돌하지 않는 레이아웃을 생성하는 데 필요한 제약의 수를 줄이지만 뷰의 컨텐츠 Hugging 및 compression resistance 우선순위를 관리해야합니다. 다음은 컨텐츠 크기를 처리하기 위한 몇가지 지침입니다.

- 일련의 뷰를 확장하여 공간을 채울 때 모든 뷰의 컨텐츠 허깅 우선 순위가 동일하면 레이아웃이 모호합니다. 오토레이아웃은 어떤 뷰를 늘려야하는 지 알지 못합니다. 일반적인 예는 Label 및 TextField 쌍입니다. 일반적으로 Label이 Instrinsic Content Size로 유지되는 동안 추가 공간을 채우기 위해 TextField 크기를 늘려야합니다. 이를 수행 하려면 TextField의 가로 컨텐츠 허깅 우선순위가 Label보다 낮아야합니다.

- 보이지 않는 배경 (예 : 단추 또는 레이블)이있는보기가 원래 콘텐츠 크기를 넘어서 실수로 늘어난 경우 이상하고 예기치 않은 레이아웃이 종종 발생합니다. 텍스트가 잘못된 위치에 표시되기 때문에 실제 문제가 명확하지 않을 수 있습니다. 원하지 않는 확장을 방지하려면 콘텐츠 포옹 우선 순위를 높이십시오.

- 기준선 제약 조건은 고유 콘텐츠 높이에있는 뷰에서만 작동합니다. 뷰가 수직으로 늘어나거나 압축되면 기준선 구속 조건이 더 이상 제대로 정렬되지 않습니다.

- 스위치와 같은 일부보기는 항상 고유 콘텐츠 크기로 표시되어야합니다. 스트레칭 또는 압축을 방지하기 위해 필요에 따라 CHCR 우선 순위를 높입니다.

- 보기에 필요한 CHCR 우선 순위를 제공하지 마십시오. 일반적으로 뷰의 크기가 잘못된 것이 우연히 충돌을 일으키는 것보다 낫습니다. 뷰가 항상 고유 콘텐츠 크기 여야하는 경우 대신 매우 높은 우선 순위 (999)를 사용하는 것이 좋습니다. 이 접근 방식은 일반적으로보기가 늘어나거나 압축되지 않도록하지만 예상보다 크거나 작은 환경에서보기가 표시되는 경우에 대비하여 여전히 비상 압력 밸브를 제공합니다.

## Intrinsic Content Size Versus Fitting Size

Intrinsic Content Size는 오토레이아웃에 대한 Input으로 작동됩니다. **뷰에 Intrinsic content size가 있는 경우 시스템은 해당 크기를 나타내는 Constriants 를 생성하고 Constriants 를 사용하여 레이아웃을 계산합니다.**

반면에 Fitting Size는 오토레이아웃 엔진의 Output 입니다. 뷰의 Constraints 를 기반으로 뷰에 대해 계산 된 크기입니다. 뷰가 오토레이아웃을 사용하여 하위뷰를 레이아웃하는 경우 시스템은 해당 내용을 기반으로 뷰에 맞는 크기를 계산할 수 있습니다.

스택뷰가 좋은 예입니다. 다른 Constraints 를 제외하고 시스템은 콘텐츠 및 속성을 기반으로 스택 뷰의 크기를 계산합니다. 여러면에서 스택뷰는 Intrinsic Content Size가 있는 것처럼 작동합니다. 수직 및 수평 제약 조건만 사용하여 위치를 정의하는 유효한 레이아웃을 만들 수 있습니다. 그러나 크기는 자동 레이아웃에 의해 계산되며 자동 레이아웃에 대한 입력이 아닙니다. 스택뷰에는 Intrinsic Content Size가 없기때문에 스택뷰의 컨텐츠 허깅/압축 저항 우선순위를 설정해도 효과가 없습니다.

스택뷰 외부의 항목을 기준으로 피팅 크기를 조정해야하는 경우, 해당 관계를 캡처하기위한 명시적 Constraints 를 생성하거나 스택 외부 항목에 대한 스택 콘텐츠의 컨텐츠 허깅/압축 저항 우선 순위를 수정합니다.

## Interpreting Values

| AutoLayout Attributes | Value | Notes |
|---|---|---|
| Height, Width|뷰의 크기 | 이 속성은 상수 값을 할당하거나, 다른 Height 및 Width 속성과 결합 할 수 있습니다. 이 값은 음수 일 수 없습니다. |
|Top, Bottom, Baseline | 화면 아래로 이동하면 값이 증가합니다. | 이 속성은 Center Y, Top, Bottom 및 Baseline 속성과만 결합할 수 있습니다. |
| Leading, Trailing | trailing edge 로 이동하면 값이 증가합니다. 오른쪽에서 왼쪽 레이아웃 방향의 경우 왼쪽으로 이동하면 값이 증가합니다. | 이 속성은 Leading, Trailing 또는 Center X 속성과만 결합할 수 있습니다. |
| Left, Right | 오른쪽으로 이동하면 값이 증가합니다. | 이 속성은 Left, Right 및 Center X 속성과만 결합할 수 있습니다. Left 및 Right 속성을 사용하지 마십시오. **대신 Leading 및 Trailing 속성을 사용하십시오. 이렇게 하면 레이아웃 뷰의 읽기 방향에 맞게 조정됩니다.** 기본적으로 읽기 방향은 사용자가 설정한 현재 언어에 따라 결정됩니다. 그러나 필요한 경우 이를 재정의 할 수 있습니다. iOS에서는 [sementicContentAttribute](https://developer.apple.com/documentation/uikit/uiview/1622461-semanticcontentattribute) Constraints(Constraints의 영향을 받는 모든 뷰의 가장 가까운 부모)를 유지하는 뷰의 속성을 설정하여 왼쪽에서 오른쪽 및 오른쪽에서 왼쪽 언어간에 전환할 때 컨텐츠 레이아웃을 뒤집어야하는지 여부를 지정합니다. |
| Center X, CenterY || Center X는 Center X, Leading, Trailing, Right 및 Left 속성과 결합 될 수 있습니다. Center Y는 Center Y, Top, Bottom 및 Baseline 속성과 결합 될 수 있습니다. |


## 참고 사이트

[공식 문서](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/ViewswithIntrinsicContentSize.html)
[공식 문서](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/AnatomyofaConstraint.html#//apple_ref/doc/uid/TP40010853-CH9-SW21)