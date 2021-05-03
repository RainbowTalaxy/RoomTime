//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/30.
//

import Foundation

fileprivate let unorderListType = "ul"
fileprivate let orderListType = "ol"
fileprivate let listLineRegex = #"^ *(?:[*+-]|[0-9]+\.) +[^ \n]+.*$"#
fileprivate let listIndentRegex = #"^ *(?:[*+-]|[0-9]+\.) +(?=[^ \n]+.*$)"#

fileprivate let unorderListLineRegex = #"^ *[*+-] +[^ \n]+.*$"#
fileprivate let unorderIndentRegex = #"^ *[*+-] +(?=[^ \n]+.*$)"#
fileprivate let unorderListSignRegex = #"^ *[*+-](?= +[^ \n]+.*$)"#

fileprivate let orderListLineRegex = #"^ *[0-9]+\. +[^ \n]+.*$"#
fileprivate let orderIndentRegex = #"^ *[0-9]+\. +(?=[^ \n]+.*$)"#
fileprivate let orderListNumberRegex = #"^ *[0-9]+(?=\. +[^ \n]+.*$)"#

//fileprivate func getLineRegex(type: String?) -> String {
//    switch type {
//    case unorderListType:
//        return unorderListLineRegex
//    case orderListType:
//        return orderListLineRegex
//    default:
//        return ".*"
//    }
//}

fileprivate func getLineType(line: Substring) -> String? {
    if line.match(by: unorderListLineRegex) {
        return unorderListType
    } else if line.match(by: orderListLineRegex) {
        return orderListType
    } else {
        return nil
    }
}

fileprivate func getUnorderListSign(text: Substring) -> UnorderListElement.Sign? {
    let splitResult = text.split(by: unorderListSignRegex)
    for section in splitResult.result {
        if section.match {
            switch text[section.range].trimmed() {
            case "*":
                return .star
            case "+":
                return .plus
            case "-":
                return .minus
            default:
                return .star
            }
        }
    }
    return nil
}

fileprivate func getOrderListNumberSign(text: Substring) -> Int? {
    let splitResult = text.split(by: orderListNumberRegex)
    for section in splitResult.result {
        if section.match {
            return Int(text[section.range].trimmed())
        }
    }
    return nil
}

fileprivate func getListIndentNum(text: Substring, type: String?) -> Int {
    var content = ""
    switch type {
    case unorderListType:
        content = text.replace(by: unorderIndentRegex, with: "")
    case orderListType:
        content = text.replace(by: orderIndentRegex, with: "")
    default:
        return String(text).preBlankNum
    }
    return text.count - content.count
}

fileprivate func build(_ item: String, num: Int) -> String {
    return (0..<num).map { _ in item }.joined()
}

fileprivate func getListSignRemoved(text: Substring, type: String?) -> String {
    switch type {
    case unorderListType:
        return text.replace(by: unorderIndentRegex, with: "")
    case orderListType:
        return text.replace(by: orderIndentRegex, with: "")
    default:
        return String(text)
    }
}

public class ListSplitRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
        var raws: [Raw] = []
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        var indent = 0, content = "", type: String?
        
        for line in lines {
            
            if line.trimmed() == "" {
                content += line.withLine
                continue
            }
            
            switch type {
            case unorderListType, orderListType:
                if line.preBlankNum >= indent {
                    content += line.withLine
                } else {
                    let lineType = getLineType(line: line)
                    if lineType != type {
                        if content != "" {
                            content.removeLast()
                            raws.append(Raw(lock: type != nil, text: content, type: type))
                        }
                        type = lineType
                        content = line.withLine
                    } else {
                        content += line.withLine
                    }
                    indent = getListIndentNum(text: line, type: type)
                }
            default:
                if line.match(by: listLineRegex) {
                    if content != "" {
                        content.removeLast()
                        raws.append(Raw(lock: false, text: content, type: type))
                    }
                    type = getLineType(line: line)
                    indent = getListIndentNum(text: line, type: type)
                    content = line.withLine
                } else {
                    content += line.withLine
                }
            }
            
        }
        
        if content != "" {
            content.removeLast()
            raws.append(Raw(lock: type != nil, text: content, type: type))
        }
        
//        print("[CASE START]")
//        print(text.debugDescription)
//        print(raws)
//        print("[CASE END]")
        return raws
    }
}

public class ListMapRule: MapRule {
    public override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        switch raw.type {
        // Order list
        case orderListType:
            let lines = raw.text.split(separator: "\n")
            var indent = Int.max, content = "", texts: [String] = []
            var offset: Int?

            for line in lines {
                if line.trimmed() == "" {
                    content += line.withLine
                    continue
                }

                if line.match(by: orderListLineRegex) {
                    if offset == nil {
                        offset = getOrderListNumberSign(text: line)
                    }
                    
                    if line.preBlankNum >= indent {
                        var tempLine = line
                        tempLine.removeFirst(indent)
                        content += tempLine.withLine
                    } else {
                        if content != "" {
                            content.removeLast()
                            texts.append(content)
                        }
                        indent = getListIndentNum(text: line, type: orderListType)
                        content = getListSignRemoved(text: line, type: orderListType).withLine
                    }
                } else {
                    var tempLine = line
                    tempLine.removeFirst(indent)
                    content += line.withLine
                }
            }

            if content != "" {
                content.removeLast()
                texts.append(content)
            }

            let items = texts.map { text in
                resolver?.render(text: text) ?? []
            }
            
            return OrderListElement(items: items, offset: offset ?? 1)
            
        // Unorder list
        case unorderListType:
            let lines = raw.text.split(separator: "\n")
            var indent = Int.max, content = "", texts: [String] = []
            var sign: UnorderListElement.Sign?

            for line in lines {
                if line.trimmed() == "" {
                    content += line.withLine
                    continue
                }

                if line.match(by: unorderListLineRegex) {
                    if sign == nil {
                        sign = getUnorderListSign(text: line)
                    }

                    if line.preBlankNum >= indent {
                        var tempLine = line
                        tempLine.removeFirst(indent)
                        content += tempLine.withLine
                    } else {
                        if content != "" {
                            content.removeLast()
                            texts.append(content)
                        }
                        indent = getListIndentNum(text: line, type: unorderListType)
                        content = getListSignRemoved(text: line, type: unorderListType).withLine
                    }
                } else {
                    var tempLine = line
                    tempLine.removeFirst(indent)
                    content += line.withLine
                }
            }

            if content != "" {
                content.removeLast()
                texts.append(content)
            }

            let items = texts.map { text in
                resolver?.render(text: text) ?? []
            }
            
            return UnorderListElement(items: items, sign: sign ?? .star)
            
        default:
            return nil
        }
    }
}

public class OrderListElement: Element {
    public let offset: Int
    public let items: [[Element]]

    public init(items: [[Element]], offset: Int = 1) {
        self.items = items
        self.offset = offset
    }
}

public class UnorderListElement: Element {
    public enum Sign {
        case star, plus, minus
    }
    
    public let sign: Sign
    public let items: [[Element]]

    public init(items: [[Element]], sign: Sign = .star) {
        self.items = items
        self.sign = sign
    }
}
