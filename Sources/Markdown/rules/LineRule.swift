//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/30.
//

import Foundation

fileprivate let lineType = "line"

public class LineSplitRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
         return text.split(separator: "\n").map { text in
            Raw(lock: true, text: String(text).trimmed(), type: lineType)
        }
    }
}

public class LineMapRule: MapRule {
    public override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        if raw.type == lineType {
            return LineElement(text: raw.text)
        }
        
        return nil
    }
}

public class LineElement: Element {
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
}
