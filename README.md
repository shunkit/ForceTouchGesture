# ForceTouchGesture
3D Touch Gesture Recognizer written in Swift 2.

This documentation is in Japanese. Please wait for translating to English.

iPhone6S, iPhone6S Plusより3D Touchが導入されました。詳細は以下のAppleの公式ドキュメントをご覧下さい。

- [Getting Started with 3D Touch](https://developer.apple.com/library/prerelease/ios/documentation/UserExperience/Conceptual/Adopting3DTouchOniPhone/index.html#//apple_ref/doc/uid/TP40016543-CH1-SW1)

- [3D Touch APIs](https://developer.apple.com/library/prerelease/ios/documentation/UserExperience/Conceptual/Adopting3DTouchOniPhone/3DTouchAPIs.html#//apple_ref/doc/uid/TP40016543-CH4-SW1)

UITouchクラスに`force`プロパティが追加され、スクリーンを押したときの圧力を取得できるようになりました。ForceTouchGestureはこの`force`プロパティを簡単に取得できるようにしたUIGestureRecognizerのサブクラスを含んでいます。

# Requirements
- iOS 7.0+
- Xcode7.1+

# How to use

イニシャライズとUIViewへの追加は一般的なUIGestureRecognizerと同じです。

```swift:
let gestureRecognizer = ForceTouchGestureRecognizer(target: self, action: "forceTouchHandler:")
gestureRecognizer.minimumForce = 4.5
self.touchView.addGestureRecognizer(gestureRecognizer)
```

Selectorの実装部分では`force`で圧力を取得することができます。
また、`force`が`minimumForce`に設定した値を超えたときに、stateがEndedになります。

```swift:
func forceTouchHandler(gestureRecognizer: ForceTouchGestureRecognizer) {
	
	let force = gestureRecognizer.force
	// do something
	
	switch gestureRecognizer.state {
		case .Ended:
			// do something
		default:
			break
	}
}
```

設定できるプロパティは以下です。

- `minimumForce: CGFloat`: GestureRecognizerのstateをEndedにする最小のforceの値です。デフォルトは3.0。
- `vibrationEnabled`: trueにするとGestureRecognizerのstateがEndedになったときに、システムのバイブレーションが発生します。デモアプリを触ってもらえると分かりますが、3D Touchのデフォルトのバイブレーションではないので、おまけのようなものです。デフォルトはfalse。

取得できるプロパティは

# License
ForceTouchGestureRecognizer is released under the MIT license. See LICENSE for details.