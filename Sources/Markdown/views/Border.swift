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
                .fill(Color.gray.opacity(0.5))
                .frame(height: 1)
                .shadow(radius: 1)
        }
        .padding(.vertical, 14)
    }
}

