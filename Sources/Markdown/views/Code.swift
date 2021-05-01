//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/12.
//

import SwiftUI
import RoomTime

public struct Code: View {
    let element: CodeElement
    
    public init(element: CodeElement) {
        self.element = element
    }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 15) {
                        VStack(alignment: .trailing, spacing: 5) {
                            ForEach(0..<element.lines.count) { i in
                                Text("\(i + 1)")
                                    .foregroundColor(Color.clear)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(element.lines, id: \.self) { line in
                                Text(line)
                                    // code text color
                                    .foregroundColor(RTColor.black)
                            }
                        }
                    }
                    .fixedSize()
                    .padding()
                }
                
                HStack {
                    VStack(alignment: .trailing, spacing: 5) {
                        ForEach(0..<element.lines.count) { i in
                            Text("\(i + 1)")
                                // line number color
                                .foregroundColor(Color.gray)
                        }
                    }
                    .padding([.vertical, .leading])
                    .padding(.trailing, 7)
                    .background(RTColor.Tag.gray)
                    
                    Spacer(minLength: 0)
                }
            }
            .font(.custom("menlo", size: 15))
            
            // language rect
            if let lang = element.lang {
                Text(lang)
                    .foregroundColor(RTColor.Tag.gray)
                    .padding(4)
                    .padding(.horizontal, 3)
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(10)
                    .padding(7)
            }
        }
        .background(RTColor.Tag.gray)
        .cornerRadius(10)
    }
}
