//
//  statics.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

import Foundation

public let lineRegexOption: NSRegularExpression.Options = [.anchorsMatchLines]

public let defaultSplitRules: [SplitRule] = [
    ListSplitRule(priority: 0),
    CodeSplitRule(priority: 1),
    HeaderSplitRule(priority: 2),
    QuoteSplitRule(priority: 3),
    LineSplitRule(priority: 4)
]

public let defaultMapRules: [MapRule] = [
    HeaderMapRule(priority: 0),
    QuoteMapRule(priority: 1),
    CodeMapRule(priority: 2),
    ListMapRule(priority: 3),
    LineMapRule(priority: 4)
]
