//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/30.
//

import Foundation

/*
 todo:
    1. supports indent codeblock
 */

fileprivate let codeBlockType = "code"
fileprivate let codeBlockRegex = #"^ *`{3} *\w* *$[\s\S]*?^ *`{3} *$"#
fileprivate let codeBlockHeadRegex = #"^ *`{3} *\w* *$"#
fileprivate let codeBlockSignRegex = #"^ *`{3} *"#

public class CodeBlockSplitRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
        return split(by: codeBlockRegex, text: text, type: codeBlockType)
    }
}

fileprivate let codeIndent = 4
fileprivate let codeIndentType = "codeIndent"
fileprivate let codeIndentRegex = #"(?:^ {\#(codeIndent)}.+$\n*)+"#

public class CodeIndentSplitRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
        return split(by: codeIndentRegex, text: text, type: codeIndentType)
    }
}

public class CodeMapRule: MapRule {
    public override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        switch raw.type {
        case codeBlockType:
            var lang: String?
            
            var texts = raw.text.split(separator: "\n")
            var indent = 0
            
            if let firstLine = texts.first {
                if firstLine.match(by: codeBlockHeadRegex) {
                    lang = firstLine.replace(by: codeBlockSignRegex, with: "").trimmed()
                    texts.removeFirst()
                }
            }
            
            if let lastLine = texts.last {
                if lastLine.match(by: codeBlockSignRegex) {
                    indent = lastLine.preBlankNum
                    texts.removeLast()
                }
            }
            
            let lines: [String] = texts.map { line in
                var line = String(line)
                line.removeFirst(indent)
                return line
            }
            
            return CodeElement(lines: lines, lang: lang == "" ? nil : lang)
            
        case codeIndentType:
            let texts = raw.text.split(separator: "\n")
            
            let lines: [String] = texts.map { line in
                if line.preBlankNum >= codeIndent {
                    var line = String(line)
                    line.removeFirst(codeIndent)
                    return line
                } else {
                    return ""
                }
            }
            
            return CodeElement(lines: lines)
            
        default:
            return nil
        }
    }
}

public class CodeElement: Element {
    let lines: [String]
    let lang: String?
    
    public init(lines: [String], lang: String? = nil) {
        self.lines = lines
        self.lang = lang
    }
}
