//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/12.
//

import Foundation

public class SpaceConvertRule: SplitRule {
    public override func split(from text: String) -> [Raw] {
        let result = text
            .replace(by: "\r", with: "", options: lineRegexOption)
            .replace(by: "\t", with: "    ", options: lineRegexOption)
        return [Raw(lock: false, text: result)]
    }
}
