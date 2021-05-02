//
//  statics.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

import Foundation

// option for common regular expression executes
public let lineRegexOption: NSRegularExpression.Options = [.anchorsMatchLines]

// this default rules is used by Markdown view and Resolver
public let defaultSplitRules: [SplitRule] = [
    SpaceConvertRule(priority: 0),
    ListSplitRule(priority: 1),
    TableSplitRule(priority: 1.5),
    BorderSplitRule(priority: 2),
    CodeBlockSplitRule(priority: 3),
    CodeIndentSplitRule(priority: 3.1),
    HeaderSplitRule(priority: 4),
    QuoteSplitRule(priority: 5),
    LineSplitRule(priority: 6)
]

// this default rules is used by Markdown view and Resolver
public let defaultMapRules: [MapRule] = [
    HeaderMapRule(priority: 0),
    QuoteMapRule(priority: 1),
    CodeMapRule(priority: 2),
    ListMapRule(priority: 3),
    TableMapRule(priority: 3.5),
    BorderMapRule(priority: 4),
    LineMapRule(priority: 5)
]
