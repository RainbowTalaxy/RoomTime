//
//  File.swift
//  
//
//  Created by Talaxy on 2021/4/12.
//

import SwiftUI

// MARK: Order list

public class OrderListElement: Element {
    public let offset: Int
    public let items: [[Element]]

    public init(items: [[Element]], offset: Int = 1) {
        self.items = items
        self.offset = offset
    }
}

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
                            .foregroundColor(.blue)
                            .bold()

                        ForEach(0..<element.items.count) { i in
                            Text("\(i + element.offset).")
                                .bold()
                        }
                        .foregroundColor(.clear)
                    }
//                    .padding(.leading, 4.5)

                    content(element.items[listIndex])
                }
            }
        }
        .frame(minHeight: 0)
    }
}

// MARK: Unorder list

public class UnorderListElement: Element {
    public enum Sign {
        case star, plus, minus
    }
    
    public let sign: Sign
    public let items: [[Element]]

    public init(items: [[Element]], sign: Sign = .star) {
        self.items = items
        self.sign = sign
    }
}

public struct UnorderList<Content: View>: View {
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
                                .fill(Color.blue)
                        case .plus:
                            Rectangle()
                                .fill(Color.blue)
                        case .minus:
                            Circle()
                                .stroke(Color.blue)
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
