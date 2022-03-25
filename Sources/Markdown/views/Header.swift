//
//  Header.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

import SwiftUI

public struct Header: View {
    let element: HeaderElement
    
    public init(element: HeaderElement) {
        self.element = element
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(try! AttributedString(markdown: element.title))
                .font(.system(size: CGFloat(31 - 2 * element.level)))
                .bold()
                .padding(.vertical, 3)
        }
    }
}
