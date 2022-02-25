//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/12.
//

import SwiftUI

// MARK: Order list

public struct OrderList<Content: View>: View {
    let element: OrderListElement
    let content: ([Element]) -> Content

    public init(
        element: OrderListElement,
        @ViewBuilder content: @escaping ([Element]) -> Content
    ) {
        self.element = element
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(0..<element.items.count) { listIndex in
                HStack(alignment: .top, spacing: 5) {
                    ZStack(alignment: .center) {
                        Text("\(listIndex + element.offset).")

                        ForEach(0..<element.items.count) { i in
                            Text("\(i + element.offset).")
                                .bold()
                        }
                        .foregroundColor(.clear)
                    }

                    content(element.items[listIndex])
                }
            }
        }
        .frame(minHeight: 0)
    }
}

// MARK: Unorder list

public struct UnorderList<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    
    let element: UnorderListElement
    let content: ([Element]) -> Content

    public init(
        element: UnorderListElement,
        @ViewBuilder content: @escaping ([Element]) -> Content
    ) {
        self.element = element
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(0..<element.items.count) { listIndex in
                HStack(alignment: .top, spacing: 7) {
                    VStack(spacing: 0) {
                        switch element.sign {
                        case .star:
                            Circle()
                                .fill()
                        case .plus:
                            Rectangle()
                                .fill()
                        case .minus:
                            Circle()
                                .stroke()
                        }
                    }
                    .frame(width: 7, height: 7)
                    .padding(.top, 6.5)
                    .padding(.horizontal, 2)

                    content(element.items[listIndex])
                }
            }
        }
        .frame(minHeight: 0)
    }
}
