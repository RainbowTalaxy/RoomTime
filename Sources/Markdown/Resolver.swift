//
//  Markdown.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

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
    
    public func split(text: String) -> [Raw] {
        var result: [Raw] = [Raw(lock: false, text: text, type: nil)]
        splitRules.sorted { r1, r2 in
            return r1.priority < r2.priority
        }.forEach { rule in
            result = rule.splitAll(raws: result)
            result.removeAll { raw in
                raw.text.trimmed() == ""
            }
        }
        return result
    }
    
    public func map(raws: [Raw]) -> [Element] {
        var mapping: [Element?] = .init(repeating: nil, count: raws.count)
        mapRules.sorted { r1, r2 in
            return r1.priority < r2.priority
        }.forEach { rule in
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
    
    public func render(text: String) -> [Element] {
        let raws = split(text: text)
        let elements = map(raws: raws)
        return elements
    }
}
