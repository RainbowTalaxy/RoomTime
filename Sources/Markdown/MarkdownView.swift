//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

import SwiftUI

public let defaultSplitRules: [SplitRule] = [
    SpaceConvertRule(priority: 0),
    FrontMatterSplitRule(priority: 0.25),
    BorderSplitRule(priority: 0.5),
    ListSplitRule(priority: 1),
    TableSplitRule(priority: 1.5),
    CodeBlockSplitRule(priority: 3),
    CodeIndentSplitRule(priority: 3.1),
    HeaderSplitRule(priority: 4),
    QuoteSplitRule(priority: 5),
    LineSplitRule(priority: 6)
]

public let defaultMapRules: [MapRule] = [
    FrontMatterMapRule(priority: -1),
    HeaderMapRule(priority: 0),
    QuoteMapRule(priority: 1),
    CodeMapRule(priority: 2),
    ListMapRule(priority: 3),
    TableMapRule(priority: 3.5),
    BorderMapRule(priority: 4),
    LineMapRule(priority: 5)
]

public struct MarkdownView<Content: View>: View {
    
    public let elements: [Element]
    public let content: (Element) -> Content
    
    public init(
        elements: [Element],
        @ViewBuilder content: @escaping (Element) -> Content
    ) {
        self.elements = elements
        self.content = content
    }
    
    public init(
        text: String,
        resolver: Resolver? = Resolver(),
        @ViewBuilder content: @escaping (Element) -> Content
    ) {
        self.elements = resolver?.render(text: text) ?? []
        self.content = content
    }
    
    public init(
        text: String,
        splitRules: [SplitRule]? = defaultSplitRules,
        mapRules: [MapRule]? = defaultMapRules,
        @ViewBuilder content: @escaping (Element) -> Content
    ) {
        let resolver = Resolver(
            splitRules: splitRules ?? defaultSplitRules,
            mapRules: mapRules ?? defaultMapRules
        )
        self.elements = resolver.render(text: text)
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(elements) { element in
                HStack(spacing: 0) {
                    content(element)
                    Spacer(minLength: 0)
                }
            }
        }
    }
    
}

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
                MarkdownView(elements: item) { element in
                    ElementView(element: element)
                }
            }
        case let code as CodeElement:
            Code(element: code)
        case let orderList as OrderListElement:
            OrderList(element: orderList) { item in
                MarkdownView(elements: item) { element in
                    ElementView(element: element)
                }
            }
        case let unorderList as UnorderListElement:
            UnorderList(element: unorderList) { item in
                MarkdownView(elements: item) { element in
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
