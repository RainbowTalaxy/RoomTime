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
fileprivate let tableAlignRowRegex = #"^ *\|? *:?-+:? *(?:\| *:?-+:? *)*\|? *$"#
fileprivate let tableAlignSignRegex = #" *:?-+:? *"#
fileprivate let tableContentRegex = #"(?<=(?:(?<!\\)\|)|(?:^))[^|].*?(?=(?:(?<!\\)\|)|(?:$))"#
fileprivate let tableSplitLineRegex = #"(?<!\\)\|"#

fileprivate func getColumnNumFromAlignRow(text: Substring) -> Int {
    return text.matchNum(by: tableAlignSignRegex)
}

fileprivate func getColumnNumFromHeadRow(text: Substring) -> Int {
    var text = text.trimmed()
    let splitNum = text.matchNum(by: tableSplitLineRegex)
    
    if splitNum < 1 || (splitNum == 1 && text.count == 1) {
        return 0
    }
    
    text = text.replace(by: tableSplitLineRegex, with: " | ").trimmed()
    return text.matchNum(by: tableContentRegex)
}

fileprivate func getContentFromRow(text: Substring) -> [String] {
    var result: [String] = []
    let splitResult = text.trimmed()
        .replace(by: tableSplitLineRegex, with: " | ").trimmed()
        .split(by: tableContentRegex)
    splitResult.result.forEach { section in
        if section.match {
            result.append(
                splitResult.raw[section.range]
                    .trimmed()
                    .replace(by: "\\|", with: "|")
            )
        }
    }
    return result
}

fileprivate func getContentFromAlignRow(text: Substring) -> [TableElement.Alignment] {
    var result: [TableElement.Alignment] = []
    let splitResult = text.split(by: tableAlignSignRegex)
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
                if line.match(by: tableAlignRowRegex) {
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
                row.append(contentsOf: [String](repeating: " ", count: heads.count - row.count))
            }
            return row
        }
    }
}
