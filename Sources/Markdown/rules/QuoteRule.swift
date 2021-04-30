//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/30.
//

import Foundation

/*
 todo:
    1. supports nested blockquote
 */

fileprivate let quoteType = "quote"
fileprivate let quoteRegex = #"^ *>+ +[^ \n]+.*$"#
fileprivate let quoteSignRegex = #"^ *>+ +"#

public class QuoteSplitRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
        return split(by: quoteRegex, text: text, type: quoteType)
    }
}

public class QuoteMapRule: MapRule {
    public override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        if raw.type == quoteType {
            let text = raw.text.replace(by: quoteSignRegex, with: "", options: lineRegexOption).trimmed()
            return QuoteElement(text: text)
        }
        
        return nil
    }
}
