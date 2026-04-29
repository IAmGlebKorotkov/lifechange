//
//  UIControl+PressAnimation.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

extension UIControl {

    func enablePressScale(to scale: CGFloat = 0.95) {
        addTarget(self, action: #selector(_pressDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(_pressUp),   for: [.touchUpInside, .touchUpOutside,
                                                              .touchCancel, .touchDragExit])
    }

    @objc private func _pressDown() {
        UIView.animate(withDuration: 0.1, delay: 0,
                       options: [.allowUserInteraction, .curveEaseIn]) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func _pressUp() {
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8,
                       options: .allowUserInteraction) {
            self.transform = .identity
        }
    }
}
