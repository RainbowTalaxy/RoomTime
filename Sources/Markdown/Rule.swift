//
//  Rules.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

import Foundation

public struct Raw: Hashable {
    public let lock: Bool
    public let text: String
    public let type: String?
    
    public init(lock: Bool, text: String, type: String? = nil) {
        self.lock = lock
        self.text = text
        self.type = type
    }
}

open class Element: Identifiable {
    public let id = UUID()
    
    public init() {}
}

open class SplitRule {
    public let priority: Double
    
    public init(priority: Double) {
        self.priority = priority
    }
    
    open func split(from text: String) -> [Raw] {
        return [Raw(lock: false, text: text)]
    }
    
    final func splitAll(raws: [Raw]) -> [Raw] {
        var result: [Raw] = []
        for raw in raws {
            if raw.lock {
                result.append(raw)
            } else {
                result.append(contentsOf: self.split(from: raw.text))
            }
        }
        return result
    }
    
    public final func split(by regex: String, text: String, type: String, maxSplits: Int = Int.max) -> [Raw] {
        var elements: [Raw] = []
        let splitResult = text.split(by: regex, maxSplits: maxSplits)
        for section in splitResult.result {
            let content = String(splitResult.raw[section.range])
            if section.match {
                elements.append(Raw(lock: true, text: content, type: type))
            } else {
                elements.append(Raw(lock: false, text: content, type: nil))
            }
        }
        return elements
    }
}

open class MapRule {
    public let priority: Double
    
    public init(priority: Double) {
        self.priority = priority
    }
    
    open func map(from raw: Raw, resolver: Resolver?) -> Element? {
        return nil
    }
    
    public final func map(from raw: Raw) -> Element? {
        return map(from: raw, resolver: nil)
    }
}
