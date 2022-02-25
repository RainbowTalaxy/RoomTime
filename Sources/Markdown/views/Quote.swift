//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

import SwiftUI
import RoomTime

public struct Quote<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    
    let element: QuoteElement
    let content: ([Element]) -> Content
    
    var isDarkMode: Bool {
        colorScheme == .dark
    }
    
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
        .frame(minHeight: 0)
        .foregroundColor(isDarkMode ? .white : .black)
        .padding(.vertical, 9)
        .padding(.leading, 9)
        .padding(.leading, 3)
        .background(isDarkMode ? Color.black : Color.white)
        .padding(.leading, 5)
        .background(Color.gray.opacity(0.5))
    }
}
