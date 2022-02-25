//
//  String.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

import Foundation

public extension StringProtocol {
    var withLine: String {
        return self + "\n"
    }
    
    var withSpace: String {
        return self + " "
    }
    
    var withComma: String {
        return self + ","
    }
    
    var withDot: String {
        return self + "."
    }
    
    func trimmed() -> String {
        self.trimmingCharacters(in: [" ", "\n"])
    }
    
    func trimLine() -> String {
        self.trimmingCharacters(in: ["\n"])
    }
}

public let lineRegexOption: NSRegularExpression.Options = [.anchorsMatchLines]

public struct RegexSplitResult {
    public typealias Result = (range: Range<String.Index>, match: Bool)
    public let raw: String
    public let result: [Result]
}

public extension StringProtocol {
    // count number of previous space
    var preBlankNum: Int {
        var result = 0
        for c in self {
            if c == " " {
                result += 1
            } else {
                return result
            }
        }
        return result
    }
    
    // check if match target regular expression
    func match(
        by regexText: String,
        options: NSRegularExpression.Options = lineRegexOption
    ) -> Bool {
        let text = String(self)
        if let regex = try? NSRegularExpression(pattern: regexText, options: options) {
            let matches = regex.matches(
                in: text,
                options: [],
                range: NSRange(text.startIndex..., in: text)
            )
            
            if matches.count == 1 && Range(matches.first!.range) == 0..<text.count {
                return true
            }
        }
        return false
    }
    
    // replace internal text which matches target regular expression
    func replace(
        by regexText: String,
        with template: String,
        options: NSRegularExpression.Options = lineRegexOption
    ) -> String {
        let text = String(self)
        if let regex = try? NSRegularExpression(pattern: regexText, options: options) {
            let result = regex.stringByReplacingMatches(
                in: text,
                options: [],
                range: NSRange(text.startIndex..., in: text),
                withTemplate: template
            )
            return result
        } else {
            return text
        }
    }
    
    func contains(
        by regexText: String,
        options: NSRegularExpression.Options = lineRegexOption
    ) -> Bool {
        let text = String(self)
        if let regex = try? NSRegularExpression(pattern: regexText, options: options) {
            let matches = regex.matches(
                in: text,
                options: [],
                range: NSRange(text.startIndex..., in: text)
            )
            
            if matches.count > 0 {
                return true
            }
        }
        return false
    }
    
    func matchNum(
        by regexText: String,
        options: NSRegularExpression.Options = lineRegexOption
    ) -> Int {
        let text = String(self)
        if let regex = try? NSRegularExpression(pattern: regexText, options: options) {
            let matches = regex.matches(
                in: text,
                options: [],
                range: NSRange(text.startIndex..., in: text)
            )
            
            return matches.count
        }
        return 0
    }
}

extension StringProtocol {
    func matchResult(
        by rawRegex: String,
        options: NSRegularExpression.Options = lineRegexOption
    ) -> [String] {
        let text = String(self)
        if let regex = try? NSRegularExpression(pattern: rawRegex, options: options) {
            let matches = regex.matches(
                in: text,
                options: [],
                range: NSRange(text.startIndex..., in: text)
            )
            return matches.map { match in
                if let range = Range(match.range) {
                    let lowerBound = text.index(text.startIndex, offsetBy: range.lowerBound)
                    let upperBound = text.index(text.startIndex, offsetBy: range.upperBound)
                    return String(text[lowerBound..<upperBound])
                } else {
                    return "[ERROR] match error"
                }
            }
        } else {
            return []
        }
    }
    
    func split(
        by rawRegex: String,
        maxSplits: Int = Int.max,
        options: NSRegularExpression.Options = lineRegexOption
    ) -> RegexSplitResult {
        let text = String(self)
        var result: [RegexSplitResult.Result] = []
        if let regex = try? NSRegularExpression(pattern: rawRegex, options: options) {
            let matches = regex.matches(
                in: text,
                options: [],
                range: NSRange(text.startIndex..., in: text)
            )
            var lowerBoundOffset = 0
            for match in matches[..<Swift.min(matches.count, maxSplits)] {
                if let range = Range(match.range) {
                    if range.lowerBound > lowerBoundOffset {
                        let lowerBound = text.index(text.startIndex, offsetBy: lowerBoundOffset)
                        let upperBound = text.index(text.startIndex, offsetBy: range.lowerBound)
                        result.append((lowerBound..<upperBound, false))
                    }
                    let lowerBound = text.index(text.startIndex, offsetBy: range.lowerBound)
                    let upperBound = text.index(text.startIndex, offsetBy: range.upperBound)
                    result.append((lowerBound..<upperBound, true))
                    lowerBoundOffset = range.upperBound
                }
            }
            let lowerBound = text.index(text.startIndex, offsetBy: lowerBoundOffset)
            if lowerBound != text.endIndex {
                result.append((lowerBound..<text.endIndex, false))
            }
        } else {
            result.append((text.startIndex..<text.endIndex, false))
        }
        
        return RegexSplitResult(raw: text, result: result)
    }
}
