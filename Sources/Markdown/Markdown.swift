//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

import SwiftUI

public struct Markdown<Content: View>: View {
    
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
