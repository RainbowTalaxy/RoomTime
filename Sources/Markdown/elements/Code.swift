//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/12.
//

import SwiftUI
import RoomTime

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
        return raw.type == codeType ? CodeElement(raw: raw) : nil
    }
}

public class CodeElement: Element {
    let lines: [String]
    var lang: String = ""
    
    public override init(raw: Raw, resolver: Resolver? = nil) {
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
        
        self.lines = texts.map { line in
            var line = String(line)
            line.removeFirst(indent)
            return line
        }
        
        super.init(raw: raw)
    }
    
}

public struct Code: View {
    let element: CodeElement
    
    public init(element: CodeElement) {
        self.element = element
    }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 15) {
                        VStack(alignment: .trailing, spacing: 5) {
                            ForEach(0..<element.lines.count) { i in
                                Text("\(i + 1)")
                                    .foregroundColor(Color.clear)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(element.lines, id: \.self) { line in
                                Text(line)
                                    // code text color
                                    .foregroundColor(RTColor.black)
                            }
                        }
                    }
                    .fixedSize()
                    .padding()
                }
                
                HStack {
                    VStack(alignment: .trailing, spacing: 5) {
                        ForEach(0..<element.lines.count) { i in
                            Text("\(i + 1)")
                                // line number color
                                .foregroundColor(Color.gray)
                        }
                    }
                    .padding([.vertical, .leading])
                    .padding(.trailing, 7)
                    // line number background color
                    .background(RTColor.Tag.gray)
                    
                    Spacer(minLength: 0)
                }
            }
            .font(.custom("menlo", size: 15))
            
            // language rect
            if element.lang != "" {
                Text(element.lang)
                    .foregroundColor(Color.gray)
                    .padding(4)
                    .padding(.horizontal, 3)
                    .background(RTColor.Tag.gray)
                    .cornerRadius(10)
                    .padding(7)
            }
        }
        .background(Color.gray.opacity(0.3))
        .cornerRadius(10)
    }
}
