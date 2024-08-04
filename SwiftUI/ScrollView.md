스크롤 뷰는 이름처럼 스크롤을 할 수 있는 뷰다. 스크롤뷰의 동작과 다양한 사용케이스를 정리해보자.

### ScrollView 가 사이즈를 잡는 방식
- 우선 세로로 스크롤되는 스크롤뷰라고 가정을 해보면 높이가 부모가 제안하는 사이즈에 딱맞게 채워진다.
- 넓이는 자식 뷰의 넓이 만큼 잡게 된다. 만약 자식 뷰가 없으면 넓이도 부모뷰가 제안하는 넓이와 같아진다.
### ContentSize, ContentOffset 확인
iOS 18부터는 [onScrollGeometryChange(for:of:action:)](https://developer.apple.com/documentation/swiftui/view/onscrollgeometrychange(for:of:action:)) 함수를 통해 contentOffset을 확인할 수 있다. 그러나 iOS 18 이전 버전에서는 contentOffset 기능이 지원되지 않아서 GeometryReader를 활용해 contentOffset을 확인해야한다. 아래 코드를 통해 사용 방법을 살펴보자.

```
import SwiftUI

struct ContentView: View {

    var body: some View {
        ScrollView {
            Text("높이 1000")
                .frame(height: 1000)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                print("contentSize:", geometry.size)
                            }
                            .onChange(
                                of: geometry.frame(in: .global).origin.y
                            ) { newValue in
                                print("contentOffset:", newValue)
                            }
                    }
                    .background(.green)
                )
        }
        .ignoresSafeArea()
    }
}

// print: contentSize: (72.33333333333333, 1000.0)
// 스크롤이 끝까지 되었을 때 print: contentOffset: -148.0
// 스크롤 위치를 초기화했을 때 print: contentOffset: 0

```

위 코드에서는 GeometryReader에 투명한 컬러를 넣어 contentSize와 contentOffset을 확인하였는데, 꼭 Color가 아니어도 상관없다.Spacer를 넣어도 문제 없다.

print 된 텍스트들을 보면 사이즈가 잘 찍히고 있다. 테스트 기기가 iPhonePro15였고, 이 기기의 높이는 852다. 852에 1000 빼면 -148. 그리고 contentOffset의 경우 스크롤 중에 찍히는 여러 값 들을 생략했다.

여기서 눈 여겨 볼 부분이 있는데, `geometry.frame(in: .global)` 바로 여기다. frame(in:) 함수는 정의된 좌표 공간에서 내 뷰의 위치를 계산하여 return 하는 함수다. global로 작성한 경우 전체 화면의 좌표 시스템 안에서 내 뷰의 위치를 계산하여 return 된다.

### ScrollViewReader

다음으로 원하는 위치로 스크롤하는 방법을 살펴보자. UIKit으로 치면 scrollToRow 같은 기능.
SwiftUI에서는 원하는 row로 스크롤하기 위해 ScrollViewReader를 사용한다.

```
import SwiftUI

struct ContentView: View {
    private let topID = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Text("높이 1000")
                    .frame(height: 1000)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    print("contentSize:", geometry.size)
                                }
                                .onChange(
                                    of: geometry.frame(in: .global).origin.y
                                ) { newValue in
                                    print("contentOffset:", newValue)
                                }
                        }
                        .background(.green)
                    )
                    .id(topID)
            }
            .ignoresSafeArea()
            
            Button {
                withAnimation {
                    proxy.scrollTo(topID, anchor: .top)
                }
            } label: {
                Text("scrollToText")
            }
        }
    }
}
```

우선 Text의 위쪽까지 스크롤하기 위해 Text에게 id를 줬다. 그리고 버튼을 하나 만들었고, 버튼을 누르면 ScrollViewReader의 proxy의 scrollTo 함수를 호출하여 Text 상단으로 스크롤을 이동하게 했다. anchor를 변경하면 대상 뷰의 하단으로 이동할 수도 있다. 다양한 옵션들이 있으니 필요한 옵션을 사용하면 될 것 같다.

그리고 문서에 한가지 주의사항이 적혀있는데, 컨텐츠 뷰 빌더가 실행되는 중에 사용을 하면 런타임 에러가 발생하니 주의해야한다고 한다. 대신 제스쳐 핸들러나 onChange 메서드같은 함수를 이용해서 사용하라고 한다.

## 참고 사이트

- [애플 공식 문서 - ScrollView](https://developer.apple.com/documentation/swiftui/scrollview)
- [애플 공식 문서 - ScrollViewReader](https://developer.apple.com/documentation/swiftui/scrollviewreader)
- [애플 공식 문서 - onScrollGeometryChange(for:of:action:)](https://developer.apple.com/documentation/swiftui/view/onscrollgeometrychange(for:of:action:))
- [애플 공식 문서 - frame(in:)](https://developer.apple.com/documentation/swiftui/geometryproxy/frame(in:)-6i40i)
