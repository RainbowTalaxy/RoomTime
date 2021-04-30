//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

import SwiftUI
import RoomTime

public class QuoteElement: Element {
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
}

public struct Quote: View {
    let element: QuoteElement
    
    public init(element: QuoteElement) {
        self.element = element
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            Text(element.text)
            
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
