//
//  EmotionPalette.swift
//  lifeisgame
//
//  Цвета эмоций из design_handoff_life_is_game_screens.
//

import UIKit

struct EmotionStyle {
    let name: String
    let sfSymbol: String
    let tileColor: UIColor
    let tintColor: UIColor

    static let all: [EmotionStyle] = [
        EmotionStyle(name: EmotionKind.joy.rawValue, sfSymbol: "sun.max", tileColor: UIColor(rgb: 0xFFEDCF), tintColor: UIColor(rgb: 0xE8920C)),
        EmotionStyle(name: EmotionKind.sadness.rawValue, sfSymbol: "cloud.rain", tileColor: UIColor(rgb: 0xD9E6FF), tintColor: UIColor(rgb: 0x3A6FD8)),
        EmotionStyle(name: EmotionKind.anger.rawValue, sfSymbol: "flame", tileColor: UIColor(rgb: 0xFFDFDA), tintColor: UIColor(rgb: 0xE2402F)),
        EmotionStyle(name: EmotionKind.anxiety.rawValue, sfSymbol: "wind", tileColor: UIColor(rgb: 0xEAE0FF), tintColor: UIColor(rgb: 0x7A4FD8)),
        EmotionStyle(name: EmotionKind.calm.rawValue, sfSymbol: "leaf", tileColor: UIColor(rgb: 0xD3F5E2), tintColor: UIColor(rgb: 0x1E9E63)),
        EmotionStyle(name: EmotionKind.love.rawValue, sfSymbol: "heart", tileColor: UIColor(rgb: 0xFFDEEB), tintColor: UIColor(rgb: 0xE84B8A))
    ]

    static func style(named name: String) -> EmotionStyle? {
        all.first { $0.name == name }
    }
}
