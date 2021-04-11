//
//  RTColor.swift
//  
//
//  Created by Talaxy on 2021/4/11.
//

import SwiftUI

public struct RTColor {
    public struct Tag {
        public static let red = Color(hex: 0xF5BCBC)
        public static let orange = Color(hex: 0xFDD0B2)
        public static let yellow = Color(hex: 0xFCE8B2)
        public static let green = Color(hex: 0xD3F2B2)
        public static let cyan = Color(hex: 0xC6F3E9)
        public static let sky = Color(hex: 0xC1EDFF)
        public static let blue = Color(hex: 0xB2DEFF)
        public static let purple = Color(hex: 0xCFC2FF)
        public static let pink = Color(hex: 0xE9BCF5)
        public static let gray = Color(hex: 0xD3D4D6)
        public static let lightgray = Color(hex: 0xE9E9E9)
        
        static let allColors = [
            red, orange, yellow, green, cyan, sky, blue, purple, pink,
            gray, lightgray
        ]
        
        public static func random() -> Color {
            return allColors.randomElement() ?? gray
        }
    }
    
    public static let black = Color(hex: 0x000000)
}

extension UIColor {
    convenience init(hex: Int) {
        var red: CGFloat = 1
        var green: CGFloat = 1
        var blue: CGFloat = 1
        var alpha: CGFloat = 1
        
        if hex <= 0xFFFFFF {
            red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
            green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
            blue = CGFloat((hex & 0x0000FF) >> 0) / 255.0
        } else {
            red = CGFloat((hex & 0xFF000000) >> 24) / 255.0
            green = CGFloat((hex & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((hex & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat((hex & 0x000000FF) >> 0) / 255.0
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension Color {
    init(hex: Int) {
        self.init(UIColor(hex: hex))
    }
}
