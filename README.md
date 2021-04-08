# RoomTime

RoomTime is a bundle of tools developed in my app `RoomTime Lite`(^^ RoomTime is still in development). 

# Features

- [TextArea](##TextArea)
- *more in developing ...*

# Requirements

- iOS 13

# Installation

*in editing*

# Usage

## TextArea

TextArea uses like SwiftUI's TextEditor, but not supports internal modifier such as `.font(_)`.

```swift
struct TextAreaDemo: View {
    @State private var text = ""
    
    var body: some View {
        // 'extraHeight' is default by 0
        TextArea(text: $text, extraHeight: 100)
    }
}
```

