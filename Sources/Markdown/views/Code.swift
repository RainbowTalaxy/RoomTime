//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/12.
//

import SwiftUI

public struct Code: View {
    let element: CodeElement
    
    public init(element: CodeElement) {
        self.element = element
    }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                HStack {
                    VStack(alignment: .trailing, spacing: 5) {
                        ForEach(0..<element.lines.count) { i in
                            Text("\(i + 1)")
                                .foregroundColor(Color.black.opacity(0.5))
                        }
                    }
                    .padding([.vertical, .leading])
                    .padding(.trailing, 7)
                    
                    ScrollView(.horizontal) {
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(element.lines, id: \.self) { line in
                                Text(line)
                                    .foregroundColor(Color.black)
                            }
                        }
                        .fixedSize()
                        .padding(.vertical)
                    }
                }
            }
            .font(.custom("menlo", size: 15))
            
            // language rect
            if let lang = element.lang {
                Text(lang)
                    .foregroundColor(Color.black.opacity(0.3))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
            }
        }
        .background(Color(red: 246/256, green: 248/256, blue: 250/256))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}
