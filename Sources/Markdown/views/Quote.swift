//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

import SwiftUI
import RoomTime

public struct Quote<Content: View>: View {
    let element: QuoteElement
    let content: ([Element]) -> Content
    
    public init(
        element: QuoteElement,
        @ViewBuilder content: @escaping ([Element]) -> Content
    ) {
        self.element = element
        self.content = content
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            content(element.elements)
            
            Spacer(minLength: 0)
        }
        .foregroundColor(RTColor.black)
        .padding(9)
        .padding(.leading, 3)
        .background(RTColor.Tag.green)
        .padding(.leading, 5)
        .background(Color.green)
    }
}
