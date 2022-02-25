//
//  File.swift
//  
//
//  Created by Talaxy on 2022/2/25.
//

import Foundation

public class ComsumeRule: MapRule {
    public override func map(from raw: Raw, resolver: Resolver?) -> Element? {
        if !raw.lock {
            return RawElement(text: raw.text)
        }
        return nil
    }
}

public class RawElement: Element {
    public let text: String
    
    init(text: String) {
        self.text = text
    }
}
