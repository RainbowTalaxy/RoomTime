# Markdown 使用

`Markdown` 能够帮助你在 SwiftUI 中渲染 markdown 文本。同时，你也可以选择启用哪些语法规则，或者是添加自定义的规则，又或者是完全的自定义元素视图。

## 基本使用

如果你只想单纯的渲染 markdown 文本，你可以：

```swift
import Markdown

struct MarkdownDemo: View {
    let text: String
    
    var body: some View {
        ScrollView {
            Markdown(text: text) { element in
                ElementView(element: element)
            }
            .padding()
        }
    }
}
```

在这个 Demo 中，我们传给了 `Markdown` 一个 `text` ，即 markdown 文本，以及一个元素视图映射组件 `ElementView` 。`ElementView` 会告诉 `Markdown` 每个元素应当呈现什么视图。

## Element 元素

目前，`Markdown` 拥有以下几种元素（以及他们的属性）：

* `HeaderElement` 标题
    | Property | Type       | Description |
    | -------- | ---------- | ----------- |
    | title    | `String`   | 标题内容 |
    | level    | `Int`      | 标题等级 |
* `QuoteElement` 引用
    | Property | Type        | Description |
    | -------- | ----------- | ----------- |
    | element  | `[Element]` | 引用块中内嵌的元素 |
* `CodeElement` 标题
    | Property | Type       | Description |
    | -------- | ---------- | ----------- |
    | lines    | `[String]` | 代码行 |
    | lang     | `String?`  | 语言标注 |
* `OrderListElement` 有序列表
    | Property | Type          | Description |
    | -------- | ------------- | ----------- |
    | offset   | `Int`         | 序号偏移 |
    | items    | `[[Element]]` | 列表元素组 |
* `UnorderListElement` 无序列表
    | Property | Type                      | Description |
    | -------- | ------------------------- | ----------- |
    | sign     | `UnorderListElement.Sign` | 列表符号 |
    | items    | `[[Element]]`             | 列表元素组 |
* `TableElement` 表格
    | Property | Type                       | Description |
    | -------- | -------------------------- | ----------- |
    | heads    | `[String]`                 | 标题行 |
    | aligns   | `[TableElement.Alignment]` | 列对齐 |
    | rows     | `[[String]]`               | 内容行 |
* `BorderElement` 分割线（无属性）
* `LineElement` 普通文本
    | Property | Type       | Description |
    | -------- | ---------- | ----------- |
    | text     | `String`   | 文本内容 |

## 自定义元素视图

这里我可以给出 `ElementView` 的实现代码，利用了 `ViewBuilder` 的 `switch` 语法支持：

```swift
public struct ElementView: View {
    public let element: Element
    
    public init(element: Element) {
        self.element = element
    }
    
    public var body: some View {
        switch element {
        case let header as HeaderElement:
            Header(element: header)
        case let quote as QuoteElement:
            Quote(element: quote) { item in
                Markdown(elements: item) { element in
                    ElementView(element: element)
                }
            }
        case let code as CodeElement:
            Code(element: code)
        case let orderList as OrderListElement:
            OrderList(element: orderList) { item in
                Markdown(elements: item) { element in
                    ElementView(element: element)
                }
            }
        case let unorderList as UnorderListElement:
            UnorderList(element: unorderList) { item in
                Markdown(elements: item) { element in
                    ElementView(element: element)
                }
            }
        case let table as TableElement:
            Table(element: table)
        case _ as BorderElement:
            Border()
        case let line as LineElement:
            Line(element: line)
        default:
            EmptyView()
        }
    }
}
```

这里如果你想自定义视图，你可以遵循以上的形式：

```swift
struct YourCustomElementView: View {
    let element: Element

    var body: some View {
        switch element {
        case let header as HeaderElement:
            // customize your own `Header`, for example:
            Text(header.title).bold()
        case let quote as QuoteElement:
            // ...
        case let code as CodeElement:
            // ...
        /* some other cases */
        default:
            EmptyView()
        }
    }
}
```

然后直接在 `Markdown` 中使用：

```swift
import Markdown

struct MarkdownDemo: View {
    let text: String
    
    var body: some View {
        ScrollView {
            Markdown(text: text) { element in
                YourCustomElementView(element: element)
            }
            .padding()
        }
    }
}
```

同时，如果你仔细地话，你会注意到 `ElementView` 中的 `default` 设定为了 `EmptyView` 。这意味着，我们可以直接在原 ElementView 之外进行拓展（我觉得这是非常 cool 的）：

```swift
import Markdown

struct MarkdownDemo: View {
    let text: String
    
    var body: some View {
        ScrollView {
            Markdown(text: text) { element in
                ElementView(element: element)

                switch element {
                case let customElement as CustomElement:
                    CustomView(element: customElement)
                /* other cases */
                default:
                    EmptyView()
                }
            }
            .padding()
        }
    }
}
```

你可能注意到了在 `Quote` `OrderList` `UnorderList` 中还嵌套了 `Markdown` 组件，这是因为这些元素支持内容嵌套，比如这样的文本中就用到了语法嵌套：

```md
* fruit
  - apple
  - banana
  - pine
* flow
  1. eat
  2. code!
  3. sleep
```

## 渲染机制

### 概要

如果你想自定义 `Markdown` 的渲染规则，我觉得需要先了解 `Markdown` 内部的渲染机制。这里给出我自认为原理展现特别清晰的图：

![Render mechanism](../Assets/markdown.png)

这张图大体上展现了 `Markdown` 的输入（Text 文本）和输出（View 视图）。

`Markdown` 内部被分成了解析器 Resolver 和元素视图映射器 ViewMapper 。Resolver 的职责是将文本转换为一组元素，而 ViewMapper 是将元素映射为视图，前面代码展示中的 `ElementView` 就是一个 ViewMapper 。

实际上通过 `Markdown` 的初始化器我们也可以看到其接受三个参数：

```swift
public struct Markdown<Content: View>: View {
    public init(
        text: String,
        resolver: Resolver? = Resolver(),
        @ViewBuilder content: @escaping (Element) -> Content
    )
}
```

这里我想着重介绍下 Resolver ，也就是文本解析器。它的初始化接受两个参数：一组 "分割规则" 和一组 "映射规则" 。

```swift
public class Resolver {
    public init(splitRules: [SplitRule], mapRules: [MapRule])
}
```

Resolver 的工作分为两个阶段："Spliting" 和 "Mapping" ，也就是 "文本分割" 和 "元素映射" 。

### Spliting 文本分割

这一阶段，解析器会先将文本分割，并标注每小段文本的类型。

首先，解析器会先把 Text 转为一个 `Raw` 数据。`Raw` 的定义如下：

```swift
public struct Raw: Hashable {
    // 是否允许被分割
    public let lock: Bool
    // 文本内容
    public let text: String
    // 所标注的类型
    public let type: String?
    
    public init(lock: Bool, text: String, type: String? = nil)
}
```

接着，解析器会根据分割规则 `SplitRule` 来进行文本的分割。这是 SplitRule 的定义：

```swift
// 如果要自定义一个分割规则，只需继承 `SplitRule` 类，并实现 `split(from:)` 方法
open class SplitRule {
    public let priority: Double
    
    public init(priority: Double)
    // 文本的分割规则
    open func split(from text: String) -> [Raw]
    // 批处理分割，由 `Resolver` 调用
    final func splitAll(raws: [Raw]) -> [Raw]
}
```

由于解析器有一组 `SplitRule` ，所以解析器会先将这组 `SplitRule` 根据优先级 `priority` 进行升序排序。然后，解析器会依次调用 `SplitRule` 的 `splitAll(raws:)` 方法对所有 `lock` 为 `false` 的 `Raw` 进行分割。

这是 `Markdown` 的默认分割规则组：

```swift
public let defaultSplitRules: [SplitRule] = [
    // 预处理空白符，将所有空白符（比如'\t'）转为纯空格
    SpaceConvertRule(priority: 0),
    // 分割线片段分割
    BorderSplitRule(priority: 0.5),
    // 列表片段分割
    ListSplitRule(priority: 1),
    // 表格片段分割
    TableSplitRule(priority: 1.5),
    // 代码块片段分割
    CodeBlockSplitRule(priority: 3),
    // 缩进代码块片段分割
    CodeIndentSplitRule(priority: 3.1),
    // 标题片段分割
    HeaderSplitRule(priority: 4),
    // 引用块片段分割
    QuoteSplitRule(priority: 5),
    // 行文本分割
    LineSplitRule(priority: 6)
]
```

这里提到一点的是，虽然是说分割，但是我们也可以对 `Raw` 进行别的处理，比如修改 `Raw` ，甚至是丢弃 `Raw` 。比如上面的 `SpaceConvertRule` 并不是一个分割的作用，而是对原 Raw 做了修改。

### Mapping 元素映射

这一阶段，解析器会根据一组 `MapRule` ，同样是根据优先级，有序的将 `Raw` 转为 `Element` 子类。这是 `MapRule` 和 `Element` 的定义:

```swift
// 如果要自定义一个映射规则，只需继承 `SplitRule` 类，并实现 `map(from:)` 方法
open class MapRule {
    public let priority: Double
    
    public init(priority: Double)
    // Raw 的映射规则
    open func map(from raw: Raw, resolver: Resolver?) -> Element?
}

// 如果要自定一个元素类型，需要继承 `Element` 类
open class Element: Identifiable {
    public let id = UUID()
    
    public init()
}
```

在 `[Raw]` 转为 `[Element]` 之后，解析器会将 `[Element]` 传给 `Markdown` 作为其属性。其实 `Markdown` 也提供了另一个构造器：

```swift
public struct Markdown<Content: View>: View {

    public let elements: [Element]
    public let content: (Element) -> Content
    
    public init(
        elements: [Element],
        @ViewBuilder content: @escaping (Element) -> Content
    )
}
```

这是 `Markdown` 的默认映射规则组：

```swift
public let defaultMapRules: [MapRule] = [
    HeaderMapRule(priority: 0),
    QuoteMapRule(priority: 1),
    CodeMapRule(priority: 2),
    ListMapRule(priority: 3),
    TableMapRule(priority: 3.5),
    BorderMapRule(priority: 4),
    LineMapRule(priority: 5)
]
```

## 自定义一套语法规则

根据上述的渲染机制，我们可以加入一些自定义的语法。虽然步骤可能有些多，但是这是值得的。这里我通过一个例子来介绍如何加入自定义语法：

我们期望能对以 `$` 作为开头的文本行进行黄色粗体显示。比如 "\$ warning" 就是个以 `$` 作为开头的文本行。

首先，我们定义好分割规则，映射规则，以及元素：

```swift
import Markdown

class DollarLineElement: Element {
    let text: String
    
    init(text: String) {
        self.text = text
    }
}

fileprivate let dollerLineType = "doller"
fileprivate let dollerLineRegex = #"^\$ +.*$"#
fileprivate let dollerSignRegex = #"^\$ +(?=.*$)"#

class DollarSplitRule: SplitRule {
    override func split(from text: String) -> [Raw] {
        // 我们可以使用继承的 `split(by:text:type:)` 方法来快速地根据正则来分割文本
        // 但这里我想说的是，我们需要确认好的 Raw 的类型来让 MapRule 识别 
        return split(by: dollerLineRegex, text: text, type: dollerLineType)
    }
}

class DollarMapRule: MapRule {
    override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        if raw.type == dollerLineType {
            // `replace(by:with:)` 是 `Markdown` 模块中的对 `StringProtocol` 的扩展方法
            // 它帮助你根据正则快速地替换文本
            // `Markdown` 模块还提供了关于正则地相关方法，后面会进行介绍
            let line = raw.text.replace(by: dollerSignRegex, with: "")
            return DollarLineElement(text: line)
        } else {
            return nil
        }
    }
}
```

接着定义元素视图：

```swift
import SwiftUI

struct DollarLine: View {
    let element: DollarLineElement
    
    var body: some View {
        Text(element.text)
            .bold()
            .foregroundColor(Color.yellow)
    }
}
```

然后，配置 `Resolver` ，加入自定义的规则:

```swift
let splitRules: [SplitRule] = defaultSplitRules + [
    DollarSplitRule(priority: 4.5)
]

let mapRules: [MapRule] = defaultMapRules + [
    DollarMapRule(priority: 4.5)
]

let resolver = Resolver(splitRules: splitRules, mapRules: mapRules)
```

最后，将所有内容都应用到 `Markdown` 组件中：

```swift
struct MarkdownDemo: View {
    let text: String = """
        # DollarLine
        $ Here is a dollar line.
        """
    
    var body: some View {
        ScrollView {
            Markdown(text: text, resolver: resolver) { element in
                // default view mapping
                ElementView(element: element)
                
                switch element {
                case let dollarLine as DollarLineElement:
                    DollarLine(element: dollarLine)
                default:
                    EmptyView()
                }
            }
            .padding()
        }
    }
}
```

这是最终成果：

![Dollar line](../Assets/dollar.png)

## 正则文本处理

如果你能熟练运用正则，并且不想直接使用 `NSRegularExpression` ，那么 `Markdown` 的正则文本处理支持一定会对你有所帮助。`Markdown` 对 `StringProtocol` 提供了许多扩展支持：

```swift
// 单行处理
public extension StringProtocol {
    // 添加 '\n' 后缀
    var withLine: String
    // 添加 ' ' 后缀
    var withSpace: String
    // 添加 ',' 后缀
    var withComma: String
    // 添加 '.' 后缀
    var withDot: String
    // 去除首尾的 ' '、'\n' 符号
    func trimmed() -> String
    // 去除首尾的 '\n' 符号
    func trimLine() -> String
}

// 默认的正则选项：支持全局多行
public let lineRegexOption: NSRegularExpression.Options = [.anchorsMatchLines]

// 正则支持
public extension StringProtocol {
    // 前缀 ' ' 的数量
    var preBlankNum: Int
    
    // 是否满足正则表达式
    func match(
        by regexText: String,
        options: NSRegularExpression.Options = lineRegexOption
    ) -> Bool
    
    // 替换文本中满足正则的内容
    func replace(
        by regexText: String,
        with template: String,
        options: NSRegularExpression.Options = lineRegexOption
    )
    
    // 文本中是否有满足正则的内容
    func contains(
        by regexText: String,
        options: NSRegularExpression.Options = lineRegexOption
    ) -> Bool
    
    // 文本中满足正则的内容数量
    func matchNum(
        by regexText: String,
        options: NSRegularExpression.Options = lineRegexOption
    ) -> Int

    // 返回符合正则的文本内容
    func matchResult(
        by rawRegex: String,
        options: NSRegularExpression.Options = lineRegexOption
    ) -> [String]
    
    // 根据正则分割文本内容
    func split(
        by rawRegex: String,
        options: NSRegularExpression.Options = lineRegexOption
    ) -> RegexSplitResult
}

// split(by:options:) 的返回类型
public struct RegexSplitResult {
    // range 为匹配的下标范围，match 为是否匹配
    public typealias Result = (range: Range<String.Index>, match: Bool)
    public let raw: String
    public let result: [Result]
}
```
