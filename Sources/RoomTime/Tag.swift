//
//  Tag.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

import SwiftUI

public struct Tag: View {
    let text: String
    let fgcolor: Color
    let bgcolor: Color
    
    public init(_ text: String, fgcolor: Color? = RTColor.black, bgcolor: Color? = RTColor.Tag.gray) {
        self.text = text
        self.fgcolor = fgcolor ?? RTColor.black
        self.bgcolor = bgcolor ?? RTColor.Tag.gray
    }
    
    public var body: some View {
        Text(text)
            .foregroundColor(fgcolor)
            .fixedSize()
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(bgcolor)
            .cornerRadius(10)
    }
}
