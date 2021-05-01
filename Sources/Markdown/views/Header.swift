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
            Text(element.title)
                .font(.system(size: CGFloat(31 - 2 * element.level)))
                .bold()
                .padding(.vertical, 3)
            
            Rectangle()
                .fill(Color.gray)
                .frame(height: CGFloat(1.8 - Double(element.level) * 0.2))
        }
    }
}
