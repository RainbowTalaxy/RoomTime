//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/30.
//

import Foundation

fileprivate let borderType = "border"
fileprivate let borderRegex = #"^ *(?:[-*_]+ *){3,} *$"#

public class BorderSplitRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
        return split(by: borderRegex, text: text, type: borderType)
    }
}

public class BorderMapRule: MapRule {
    public override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        return raw.type == borderType ? BorderElement() : nil
    }
}

public class BorderElement: Element {}
