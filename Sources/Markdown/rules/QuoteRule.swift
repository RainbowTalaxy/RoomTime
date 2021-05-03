//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/30.
//

import Foundation

fileprivate let quoteType = "quote"
fileprivate let quoteRegex = #"(?:^ *>+ +.*$\n?)+"#
fileprivate let quoteSignRegex = #"^ *> ?"#

public class QuoteSplitRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
        return split(by: quoteRegex, text: text, type: quoteType)
    }
}

public class QuoteMapRule: MapRule {
    public override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        if raw.type == quoteType {
            let text = raw.text.replace(by: quoteSignRegex, with: "").trimmed()
            let elements = resolver?.render(text: text) ?? []
            return QuoteElement(elements: elements)
        }
        
        return nil
    }
}

public class QuoteElement: Element {
    public let elements: [Element]
    
    public init(elements: [Element]) {
        self.elements = elements
    }
}
