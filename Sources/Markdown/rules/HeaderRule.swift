//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/30.
//

import Foundation

fileprivate let headerType = "header"
fileprivate let headerRegex = #"^ *#{1,6} +[^ \n]+.*$"#
fileprivate let headerSignRegex = #"^ *#{1,6} +"#

fileprivate let minLevel = 1
fileprivate let maxLevel = 6

public class HeaderSplitRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
        return split(by: headerRegex, text: text, type: headerType)
    }
}

public class HeaderMapRule: MapRule {
    public override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        if raw.type == headerType {
            var title: String
            var level: Int
            
            if let num = raw.text.matchResult(by: headerSignRegex).first?.trimmed().count {
                level = (num >= minLevel && num <= maxLevel) ? num : 1
            } else {
                level = maxLevel
            }
            title = raw.text.replace(by: headerSignRegex, with: "").trimmed()
            return HeaderElement(title: title, level: level)
        } else {
            return nil
        }
    }
}

public class HeaderElement: Element {
    public let title: String
    public let level: Int
    
    public init(title: String, level: Int) {
        self.title = title
        self.level = level
    }
}
