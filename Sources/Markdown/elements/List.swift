//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/12.
//

import SwiftUI

fileprivate let listLineRegex = #"^ *(?:[*+-]|[0-9]+.) +[^ \n]+.*$"#
fileprivate let listIndentRegex = #"^ *(?:[*+-]|[0-9]+.) +(?=[^ \n]+.*$)"#

fileprivate let unorderListLineRegex = #"^ *[*+-] +[^ \n]+.*$"#
fileprivate let unorderIndentRegex = #"^ *[*+-] +(?=[^ \n]+.*$)"#

fileprivate let orderListLineRegex = #"^ *[0-9]+. +[^ \n]+.*$"#
fileprivate let orderIndentRegex = #"^ *[0-9]+. +(?=[^ \n]+.*$)"#

fileprivate func getLineRegex(type: String?) -> String {
    switch type {
    case TypeMap.unorderlist:
        return unorderListLineRegex
    case TypeMap.orderlist:
        return orderListLineRegex
    default:
        return ".*"
    }
}

fileprivate func getLineType(line: Substring) -> String? {
    if line.match(by: unorderListLineRegex, options: lineRegexOption) {
        return TypeMap.unorderlist
    } else if line.match(by: orderListLineRegex, options: lineRegexOption) {
        return TypeMap.orderlist
    } else {
        return nil
    }
}

fileprivate func getListIndentNum(text: Substring, type: String?) -> Int {
    var content = ""
    switch type {
    case TypeMap.unorderlist:
        content = text.replace(by: unorderIndentRegex, with: "", options: lineRegexOption)
    case TypeMap.orderlist:
        content = text.replace(by: orderIndentRegex, with: "", options: lineRegexOption)
    default:
        return String(text).preBlankNum
    }
    return text.count - content.count
}

fileprivate func build(_ item: String, num: Int) -> String {
    return (0..<num).map { _ in item }.joined()
}

fileprivate func getListSignRemoved(text: Substring, type: String?) -> String {
    var content = ""
    switch type {
    case TypeMap.unorderlist:
        content = text.replace(by: unorderIndentRegex, with: "", options: lineRegexOption)
    case TypeMap.orderlist:
        content = text.replace(by: orderIndentRegex, with: "", options: lineRegexOption)
    default:
        return String(text)
    }
    let indent = text.count - content.count
    return build(" ", num: indent) + content
}

public class ListSplitRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
        var elements: [Raw] = []
        let lines = text.split(separator: "\n")
        var indent = 0, content = "", type: String?
        
        for line in lines {
            
            if line.trimmed() == "" {
                continue
            }
            
            switch type {
            case TypeMap.unorderlist, TypeMap.orderlist:
                if line.preBlankNum >= indent {
                    content += line.withLine
                } else {
                    let lineType = getLineType(line: line)
                    if lineType != type {
                        elements.append(Raw(lock: type != nil, text: content, type: type))
                        type = lineType
                        content = line.withLine
                    } else {
                        content += line.withLine
                    }
                    indent = getListIndentNum(text: line, type: type)
                }
            default:
                if line.match(by: listLineRegex, options: lineRegexOption) {
                    elements.append(Raw(lock: false, text: content, type: type))
                    type = getLineType(line: line)
                    indent = getListIndentNum(text: line, type: type)
                    content = line.withLine
                } else {
                    content += line.withLine
                }
            }
            
        }
        
        if content != "" {
            elements.append(Raw(lock: type != nil, text: content, type: type))
        }
        
        return elements
    }
}

public class ListMapRule: MapRule {
    public override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        switch raw.type {
        case TypeMap.orderlist, TypeMap.unorderlist:
            return ListElement(raw: raw, resolver: resolver)
        default:
            return nil
        }
    }
}

public class ListElement: Element {
    public let items: [[Element]]
    public let type: String?
    
    public override init(raw: Raw, resolver: Resolver? = nil) {
        self.type = raw.type ?? nil
        
        let lineRegex = getLineRegex(type: type)
        let lines = raw.text.split(separator: "\n")
        var indent = Int.max, content = "", texts: [String] = []
        
        for line in lines {
            if line.trimmed() == "" {
                continue
            }
            
            if line.match(by: lineRegex, options: lineRegexOption) {
                if line.preBlankNum >= indent {
                    content += line.withLine
                } else {
                    if content != "" {
                        texts.append(content)
                    }
                    indent = getListIndentNum(text: line, type: type)
                    content = getListSignRemoved(text: line, type: type).withLine
                }
            } else {
                content += line.withLine
            }
        }
        
        if content != "" {
            texts.append(content)
        }
        
        self.items = texts.map { text in
            resolver?.render(text: text) ?? []
        }
        
        super.init(raw: raw)
    }
    
}

public struct List<Content: View>: View {
    let element: ListElement
    let content: ([Element]) -> Content
    
    public init(
        element: ListElement,
        @ViewBuilder content: @escaping ([Element]) -> Content
    ) {
        self.element = element
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(0..<element.items.count) { listIndex in
                HStack(alignment: .top, spacing: 5) {
                    switch element.type {
                    case TypeMap.unorderlist:
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 7, height: 7)
                            .padding(6.5)
                    case TypeMap.orderlist:
                        ZStack(alignment: .center) {
                            Text("\(listIndex + 1).")
                                .foregroundColor(.blue)
                                .bold()
                            
                            Text("\(element.items.count).")
                                .foregroundColor(.clear)
                                .bold()
                        }
                        .padding(.leading, 4.5)
                    default:
                        EmptyView()
                    }
                    
                    content(element.items[listIndex])
                }
            }
        }
        .frame(minHeight: 0)
        
    }
}
