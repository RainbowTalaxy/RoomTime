//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

import SwiftUI

public struct MarkdownView<Content: View>: View {
    
    public let elements: [Markdown.Element]
    public let content: (Markdown.Element) -> Content
    
    public init(
        elements: [Markdown.Element],
        @ViewBuilder content: @escaping (Markdown.Element) -> Content
    ) {
        self.elements = elements
        self.content = content
    }
    
    public init(
        text: String,
        resolver: Markdown.Resolver? = Markdown.Resolver(),
        @ViewBuilder content: @escaping (Markdown.Element) -> Content
    ) {
        self.elements = resolver?.render(text: text) ?? []
        self.content = content
    }
    
    public init(
        text: String,
        splitRules: [Markdown.SplitRule]? = Markdown.defaultSplitRules,
        mapRules: [Markdown.MapRule]? = Markdown.defaultMapRules,
        @ViewBuilder content: @escaping (Markdown.Element) -> Content
    ) {
        let resolver = Markdown.Resolver(
            splitRules: splitRules ?? Markdown.defaultSplitRules,
            mapRules: mapRules ?? Markdown.defaultMapRules
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
