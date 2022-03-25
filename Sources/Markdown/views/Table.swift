//
//  File.swift
//  
//
//  Created by Talaxy on 2021/5/2.
//

import SwiftUI

public struct Table: View {
    public let element: TableElement
    
    public init(element: TableElement) {
        self.element = element
    }
    
    public var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(0..<element.heads.count) { col in
                    // single column
                    VStack(alignment: mapAlign(align: element.aligns[col]), spacing: 0) {
                        Text(AttributedString(element.heads[col]))
                            .bold()
                            .padding(8)
                        
                        Rectangle()
                            .fill()
                            .frame(height: 0.5)
                        
                        ForEach(0..<element.rows.count) { row in
                            Rectangle()
                                .fill()
                                .frame(height: 0.5)
                            
                            Text(element.rows[row][col])
                                .padding(8)
                        }
                    }
                }
                .fixedSize()
            }
        }
    }
    
    func mapAlign(align: TableElement.Alignment) -> HorizontalAlignment {
        switch align {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
}
