//
//  SubtaskValidator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 09.04.2026.
//

import Foundation


struct SubtaskValidationInput {
    let name: String
}


struct SubtaskValidator {

    func isValid(_ input: SubtaskValidationInput) -> Bool {
        !input.name.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
