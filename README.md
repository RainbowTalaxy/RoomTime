# RoomTime

RoomTime is a bundle of tools developed in my app `RoomTime Lite`. (😊 RoomTime Lite is still in development)

# Features

- [TextArea](#textarea)
- *more in developing ...*

# Requirements

- iOS 13

# Installation

1. In Xcode project, navigate to **File -> Swift Packages -> Add Package Dependency...**.
2. Paste `https://github.com/RainbowTalaxy/RoomTime` and click **Next**.

# Usage

## TextArea

`TextArea` uses like SwiftUI's `TextEditor`, but not supports internal modifier such as `.font(_)`.

```swift
struct TextAreaDemo: View {
    @State private var text = ""
    
    var body: some View {
        // 'extraHeight' is default by 0
        TextArea(text: $text, extraHeight: 100)
    }
}
```

