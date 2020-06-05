//
//  KeyboardAdaptive.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/5/25.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import Combine
import CoreGraphics
import UIKit
import SwiftUI

extension Publishers {
    static var keyboardMinY: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.keyboardMinY }
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in  CGFloat(9999) }
        return willShow.merge(with: willHide).eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardMinY: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.minY ?? 0
    }
}

extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder?
    
    static var currentFirsrResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }
    
    @objc private func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
    
    var globalFrame: CGRect? {
        guard let view = self as? UIView else { return nil }
        return view.superview?.convert(view.frame, to: nil)
    }
}

struct KeyboardAdaptive: ViewModifier {
    @State private var yOffset: CGFloat = 0
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .offset(x: 0, y: -self.yOffset)
                .onReceive(Publishers.keyboardMinY) { keyboardMinY in
                    let focusedTextInputBottom = UIResponder.currentFirsrResponder?.globalFrame?.maxY ?? 0
                    self.yOffset = max(0, focusedTextInputBottom - keyboardMinY)
            }
        }
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}
