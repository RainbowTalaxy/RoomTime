//
//  TextArea.swift
//  
//
//  Created by Talaxy on 2021/4/8.
//

import SwiftUI

public struct TextArea: View {
    
    struct TextView: UIViewRepresentable {
        public typealias Context = UIViewRepresentableContext<TextView>
        
        @Binding var text: String
        @Binding var height: CGFloat
        
        let width: CGFloat
        let extraHeight: CGFloat
        
        public init(text: Binding<String>, height: Binding<CGFloat>, width: CGFloat, extraHeight: CGFloat = 0.0) {
            self._text = text
            self._height = height
            self.width = width
            self.extraHeight = extraHeight
        }
        
        public func makeUIView(context: Context) -> UIView {
            let textView = UITextView()
            textView.delegate = context.coordinator
    //        textView.font = .preferredFont(forTextStyle: .body)
            textView.font = .monospacedSystemFont(ofSize: 17, weight: .regular)
            textView.isScrollEnabled = false
            textView.backgroundColor = .clear
            
            let uiView = UIView()
            uiView.addSubview(textView)
            
            return uiView
        }
        
        public func updateUIView(_ uiView: UIView, context: Context) {
            let textView = uiView.subviews.first! as! UITextView
            
            if !context.coordinator.isEditing {
                textView.text = text
            }
            
            let bounds = CGSize(width: width, height: height + extraHeight)
            
            DispatchQueue.main.async {
                height = textView.sizeThatFits(bounds).height + extraHeight
                let size = CGSize(width: width, height: height)
                uiView.frame.size = size
                textView.frame.size = size
            }
            
        }
        
        public func makeCoordinator() -> Coordinator {
            Coordinator(text: $text)
        }
        
        public class Coordinator: NSObject, UITextViewDelegate {
            var text: Binding<String>
            var isEditing: Bool = false
            
            init(text: Binding<String>) {
                self.text = text
            }
            
            public func textViewDidChange(_ textView: UITextView) {
                self.text.wrappedValue = textView.text
            }
            
            public func textViewDidBeginEditing(_ textView: UITextView) {
                isEditing = true
            }
            
            public func textViewDidEndEditing(_ textView: UITextView) {
                isEditing = false
            }
        }
    }
    
    
    @State private var height: CGFloat = .zero
    @Binding var text: String
    let extraHeight: CGFloat
    
    public init(text: Binding<String>, extraHeight: CGFloat = 0.0) {
        self._text = text
        self.extraHeight = extraHeight
    }
    
    public var body: some View {
        GeometryReader { geo in
            TextView(text: $text, height: $height, width: geo.size.width, extraHeight: extraHeight)
        }
        .frame(height: height)
    }
}
