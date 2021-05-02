//
//  File.swift
//  
//
//  Created by Talaxy on 2021/5/1.
//

import Foundation

/*
 test:
    1. '\' check
 */

fileprivate let tableType = "table"
fileprivate let tableAlignRowRegex = #"^ *\|? *:?-+ *:?(?:\| *:?-+ *:?)*\|? *$"#
fileprivate let tableAlignSignRegex = #" *:?-+ *:?"#
fileprivate let tableContentRegex = #"(?<=(?:(?<!\\)\|)|(?:^))[^|].*?(?=(?:(?<!\\)\|)|(?:$))"#
fileprivate let tableSplitLineRegex = #"(?<!\\)\|"#
//fileprivate let tableInlineSplitLineRegex = #"(?<!\\|^)\|(?!$)"#

fileprivate func getColumnNumFromAlignRow(text: Substring) -> Int {
    return text.matchNum(by: tableAlignSignRegex, options: lineRegexOption)
}

fileprivate func getColumnNumFromHeadRow(text: Substring) -> Int {
    var text = text.trimmed()
    let splitNum = text.matchNum(by: tableSplitLineRegex, options: lineRegexOption)
    
    if splitNum < 1 || (splitNum == 1 && text.count == 1) {
        return 0
    }
    
    text = text.replace(by: tableSplitLineRegex, with: " | ", options: lineRegexOption).trimmed()
    return text.matchNum(by: tableContentRegex, options: lineRegexOption)
}

fileprivate func getContentFromRow(text: Substring) -> [String] {
    var result: [String] = []
    let splitResult = text.trimmed()
        .replace(by: tableSplitLineRegex, with: " | ", options: lineRegexOption).trimmed()
        .split(by: tableContentRegex, options: lineRegexOption)
    splitResult.result.forEach { section in
        if section.match {
            result.append(splitResult.raw[section.range].trimmed())
        }
    }
    return result
}

fileprivate func getContentFromAlignRow(text: Substring) -> [TableElement.Alignment] {
    var result: [TableElement.Alignment] = []
    let splitResult = text.split(by: tableAlignSignRegex, options: lineRegexOption)
    splitResult.result.forEach { section in
        if section.match {
            let sign = splitResult.raw[section.range].trimmed()
            if sign.hasPrefix(":") && sign.hasSuffix(":") {
                result.append(.center)
            } else if sign.hasSuffix(":") {
                result.append(.trailing)
            } else {
                result.append(.leading)
            }
        }
    }
    return result
}

public class TableSplitRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
        var raws: [Raw] = []
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        var preLine: Substring?
        var content = "", type: String?
        
        for line in lines {
            if type == tableType {
                if line.trimmed() == "" {
                    raws.append(Raw(lock: type != nil, text: content, type: type))
                    type = nil
                    content = ""
                } else {
                    content += line.withLine
                }
            } else {
                if line.match(by: tableAlignRowRegex, options: lineRegexOption) {
                    let alignNum = getColumnNumFromAlignRow(text: line)
                    if let headLine = preLine {
                        let headNum = getColumnNumFromHeadRow(text: headLine)
                        if headNum == alignNum {
                            raws.append(Raw(lock: type != nil, text: content, type: type))
                            type = tableType
                            content = headLine.withLine + line.withLine
                            preLine = line
                            continue
                        }
                    }
                }
                content += preLine?.withLine ?? ""
            }
            preLine = line
        }
        
        if type == nil {
            content += preLine?.withLine ?? ""
        }
        
        if content != "" {
            raws.append(Raw(lock: type != nil, text: content, type: type))
        }
//        print("[CASE STA]")
//        raws.forEach { raw in
//            if raw.type == tableType {
//                print(raw.text)
//                print("[CASE END]")
//            }
//        }
        return raws
    }
}

public class TableMapRule: MapRule {
    public override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        if raw.type == tableType {
            var lines = raw.text.split(separator: "\n")
            let heads = getContentFromRow(text: lines[0])
            let aligns = getContentFromAlignRow(text: lines[1])
            lines.removeFirst(2)
            let rows = lines.map { line in
                return getContentFromRow(text: line)
            }
//            print(heads)
//            print(aligns)
//            print(rows)
//            print("[CASE END]")
            return TableElement(heads: heads, aligns: aligns, rows: rows)
        }
        return nil
    }
}

public class TableElement: Element {
    public enum Alignment {
        case leading, center, trailing
    }
    
    public let heads: [String]
    public let aligns: [Alignment]
    public let rows: [[String]]
    
    public init(heads: [String], aligns: [Alignment], rows: [[String]]) {
        self.heads = heads
        self.aligns = aligns
        self.rows = rows.map { row in
            var row = row
            if row.count < heads.count {
                row.append(contentsOf: [String](repeating: "", count: heads.count - row.count))
            }
            return row
        }
    }
}
