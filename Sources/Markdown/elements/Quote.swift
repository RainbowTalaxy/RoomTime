//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

import SwiftUI
import RoomTime

fileprivate let quoteRegex = #"^ *>+ +[^ \n]+.*$"#
fileprivate let quoteSignRegex = #"^ *>+ +"#

public class QuoteSplitRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
        return split(by: quoteRegex, text: text, type: TypeMap.quote)
    }
}

public class QuoteMapRule: MapRule {
    public override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        return raw.type == TypeMap.quote ? QuoteElement(raw: raw) : nil
    }
}

public class QuoteElement: Element {
    public let text: String
    
    public override init(raw: Raw, resolver: Resolver? = nil) {
        text = raw.text.replace(by: quoteSignRegex, with: "", options: lineRegexOption).trimmed()
        super.init(raw: raw)
    }
}

public struct Quote: View {
    let element: QuoteElement
    
    public init(element: QuoteElement) {
        self.element = element
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            Text(element.text)
            
            Spacer(minLength: 0)
        }
        .foregroundColor(RTColor.black)
        .padding(9)
        .padding(.leading, 3)
        .background(RTColor.Tag.green)
        .padding(.leading, 5)
        .background(Color.green)
    }
}
