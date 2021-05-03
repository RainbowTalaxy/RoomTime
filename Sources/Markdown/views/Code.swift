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
                                .foregroundColor(Color.white.opacity(0.5))
                        }
                    }
                    .padding([.vertical, .leading])
                    .padding(.trailing, 7)
                    
                    ScrollView(.horizontal) {
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(element.lines, id: \.self) { line in
                                Text(line)
                                    .foregroundColor(Color.white)
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
                    .foregroundColor(Color.white.opacity(0.5))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
            }
        }
        .background(Color.gray)
        .cornerRadius(10)
    }
}
