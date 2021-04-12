//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/12.
//

import SwiftUI

public class LineSplitRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
         return text.split(separator: "\n").map { text in
            Raw(lock: true, text: String(text).trimmed(), type: TypeMap.line)
        }
    }
}

public class LineMapRule: MapRule {
    public override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        return raw.type == TypeMap.line ? LineElement(raw: raw) : nil
    }
}

public class LineElement: Element {
    public let text: String
    
    public override init(raw: Raw, resolver: Resolver? = nil) {
        self.text = raw.text
        super.init(raw: raw)
    }
}

public struct Line: View {
    let element: LineElement
    
    public init(element: LineElement) {
        self.element = element
    }
    
    public var body: some View {
        Text(element.text)
    }
}
