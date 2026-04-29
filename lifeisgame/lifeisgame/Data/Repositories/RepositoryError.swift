//
//  RepositoryError.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

enum RepositoryError: LocalizedError {
    case notFound
    case mappingFailed
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .notFound: return "Запись не найдена"
        case .mappingFailed: return "Ошибка обработки данных"
        case .invalidCredentials: return "Неверный логин или пароль"
        }
    }
}
