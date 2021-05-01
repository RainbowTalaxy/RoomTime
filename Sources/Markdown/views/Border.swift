//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/12.
//

import SwiftUI

public struct Border: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.gray)
                .frame(height: 1)
            
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 2.5)
        }
        .padding(.vertical, 14)
    }
}

