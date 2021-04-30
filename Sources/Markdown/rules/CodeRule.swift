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

fileprivate let codeType = "code"
fileprivate let codeRegex = #"^ *`{3} *\w* *$[\s\S]*?^ *`{3} *$"#
fileprivate let codeHeadRegex = #"^ *`{3} *\w* *$"#
fileprivate let codeSignRegex = #"^ *`{3} *"#

public class CodeSplitRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
        return split(by: codeRegex, text: text, type: codeType)
    }
}

public class CodeMapRule: MapRule {
    public override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        if raw.type == codeType {
            var lines: [String]
            var lang: String?
            
            var texts = raw.text.split(separator: "\n")
            var indent = 0
            
            if let firstLine = texts.first {
                if firstLine.match(by: codeHeadRegex, options: lineRegexOption) {
                    lang = firstLine.replace(by: codeSignRegex, with: "", options: lineRegexOption).trimmed()
                    texts.removeFirst()
                }
            }
            
            if let lastLine = texts.last {
                if lastLine.match(by: codeSignRegex, options: lineRegexOption) {
                    indent = lastLine.preBlankNum
                    texts.removeLast()
                }
            }
            
            lines = texts.map { line in
                var line = String(line)
                line.removeFirst(indent)
                return line
            }
            
            return CodeElement(lines: lines, lang: lang)
        }
        
        return nil
    }
}
