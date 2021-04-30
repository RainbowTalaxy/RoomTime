//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/12.
//

import SwiftUI

public class LineElement: Element {
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
}

public struct Line: View {
    let element: LineElement
    
    public init(element: LineElement) {
        self.element = element
    }
    
    public var body: some View {
        Text(element.text)
    }
}
