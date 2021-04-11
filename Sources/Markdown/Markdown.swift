//
//  Markdown.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

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

public class Resolver {
    
    public let splitRules: [SplitRule]
    public let mapRules: [MapRule]
    
    public init(
        splitRules: [SplitRule] = defaultSplitRules,
        mapRules: [MapRule] = defaultMapRules
    ) {
        self.splitRules = splitRules
        self.mapRules = mapRules
    }
    
    public func split(text: String, allowEmptyText: Bool = false) -> [Raw] {
        var result: [Raw] = [Raw(lock: false, text: text, type: nil)]
        splitRules.forEach { rule in
            result = rule.splitAll(raws: result)
            if !allowEmptyText {
                result.removeAll { raw in
                    raw.text.trimmed() == ""
                }
            }
        }
        return result
    }
    
    public func map(raws: [Raw]) -> [Element] {
        var mapping: [Element?] = .init(repeating: nil, count: raws.count)
        mapRules.forEach { rule in
            for i in 0..<raws.count {
                if mapping[i] == nil {
                    mapping[i] = rule.map(from: raws[i], resolver: self)
                }
            }
        }
        var result: [Element] = []
        for element in mapping {
            if let element = element {
                result.append(element)
            }
        }
        return result
    }
    
    public func render(text: String, allowEmptyText: Bool = false) -> [Element] {
        let raws = split(text: text, allowEmptyText: allowEmptyText)
        let elements = map(raws: raws)
        return elements
    }
}
