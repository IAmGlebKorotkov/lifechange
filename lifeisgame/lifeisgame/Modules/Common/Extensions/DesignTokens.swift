//
//  DesignTokens.swift
//  lifeisgame
//
//  Палитра и тени из design_handoff_life_is_game_screens.
//

import UIKit

extension UIColor {

    convenience init(rgb: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: alpha
        )
    }

    static let inkDark = UIColor(rgb: 0x1C1C1E)
    static let textSecondaryToken = UIColor(rgb: 0x3C3C43, alpha: 0.55)
    static let appSuccess = UIColor(rgb: 0x34C759)
    static let appWarning = UIColor(rgb: 0xFF9F0A)
    static let appInfo = UIColor(rgb: 0x0A84FF)
    static let appSleepPurple = UIColor(rgb: 0x7C5CFF)
    static let appDanger = UIColor(rgb: 0xFF3B30)
    static let segmentTrack = UIColor(rgb: 0x787880, alpha: 0.12)
    static let progressTrackToken = UIColor(rgb: 0x787880, alpha: 0.16)
    static let timelineLine = UIColor(rgb: 0x3C3C43, alpha: 0.12)
}

extension UIView {

    /// Тень карточки: offset-y 2–4, blur 10–16, rgba(45,32,84,0.10–0.16).
    func applyCardShadow(strength: CGFloat = 1) {
        layer.shadowColor = UIColor(rgb: 0x2D2054).cgColor
        layer.shadowOpacity = Float(0.12 * strength)
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 7
    }

    /// Тень primary-кнопки: offset-y 14, blur 28, rgba(95,51,225,0.5).
    func applyPrimaryButtonShadow() {
        layer.shadowColor = UIColor(rgb: 0x5F33E1).cgColor
        layer.shadowOpacity = 0.45
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowRadius = 14
    }
}
