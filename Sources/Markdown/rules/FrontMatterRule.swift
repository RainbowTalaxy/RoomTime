//
//  File.swift
//  
//
//  Created by Talaxy on 2022/2/24.
//

import Foundation
import Yams

fileprivate let frontMatterType = "fm"
fileprivate let frontMatterRegex = #"^( *\n)*?\s*---\s*?\n(.*\n)*?\s*---\s*?$"#
fileprivate let frontMatterSign = #"^\s*---\s*$"#

public class FrontMatterSplitRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
        let splitResult = text.split(by: frontMatterRegex, maxSplits: 1)
        if let firstSection = splitResult.result.first {
            if firstSection.match {
                var elements: [Raw] = []
                for section in splitResult.result {
                    let content = String(splitResult.raw[section.range])
                    if section.match {
                        elements.append(Raw(lock: true, text: content, type: frontMatterType))
                    } else {
                        elements.append(Raw(lock: false, text: content, type: nil))
                    }
                }
                return elements
            }
        }
        return [Raw(lock: false, text: text, type: nil)]
    }
}

public class FrontMatterMapRule: MapRule {
    public override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        if raw.type == frontMatterType {
            let content = raw.text.replace(by: frontMatterSign, with: "").trimmed()
            do {
                let properties = try Yams.load(yaml: content) as? [String: Any]
                return FrontMatterElement(properties: properties ?? [:])
            } catch {
                return FrontMatterElement(properties: [:])
            }
        } else {
            return nil
        }
    }
}

public class FrontMatterElement: Element {
    public let properties: [String: Any]
    
    init(properties: [String: Any]) {
        self.properties = properties
    }
}
