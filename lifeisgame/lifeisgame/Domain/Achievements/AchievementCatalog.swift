//
//  AchievementCatalog.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 12.05.2026.
//

import Foundation

struct AchievementMetrics {
    let completedTasks: Int
    let sleepEntryDays: Int
    let eightHourSleepDays: Int
    let emotionEntryDays: Int
    let highIntensityEmotionDays: Int
    let focusHours: Int
}

struct AchievementDefinition {
    let code: String
    let kind: AchievementKind
    let icon: String
    let title: String
    let goal: String
    let targetValue: Int
    let sortOrder: Int
    let cellHeight: Double
    let progress: (AchievementMetrics) -> Int
}

protocol AchievementCatalogProviding {
    var definitions: [AchievementDefinition] { get }
}

struct DefaultAchievementCatalog: AchievementCatalogProviding {

    let definitions: [AchievementDefinition]

    init() {
        definitions = [
            AchievementDefinition(
                code: "tasks_1",
                kind: .tasks,
                icon: "flame.fill",
                title: "Первый шаг",
                goal: "Выполни первое задание",
                targetValue: 1,
                sortOrder: 0,
                cellHeight: 160,
                progress: { $0.completedTasks }
            ),
            AchievementDefinition(
                code: "sleep_1",
                kind: .sleep,
                icon: "moon.fill",
                title: "Сон записан",
                goal: "Добавь первую запись сна",
                targetValue: 1,
                sortOrder: 1,
                cellHeight: 185,
                progress: { $0.sleepEntryDays }
            ),
            AchievementDefinition(
                code: "emotion_1",
                kind: .emotion,
                icon: "heart.fill",
                title: "На связи с собой",
                goal: "Добавь первую эмоцию в дневник",
                targetValue: 1,
                sortOrder: 2,
                cellHeight: 150,
                progress: { $0.emotionEntryDays }
            ),
            AchievementDefinition(
                code: "focus_1",
                kind: .focus,
                icon: "brain.head.profile",
                title: "Первый фокус",
                goal: "Проведи 1 час в фокусе",
                targetValue: 1,
                sortOrder: 3,
                cellHeight: 155,
                progress: { $0.focusHours }
            ),
            AchievementDefinition(
                code: "tasks_10",
                kind: .tasks,
                icon: "checkmark.seal.fill",
                title: "Вошел в ритм",
                goal: "Выполни 10 заданий",
                targetValue: 10,
                sortOrder: 4,
                cellHeight: 170,
                progress: { $0.completedTasks }
            ),
            AchievementDefinition(
                code: "sleep_8h_5",
                kind: .sleep,
                icon: "bed.double.fill",
                title: "Сладкий сон",
                goal: "Спи не меньше 8 часов 5 дней",
                targetValue: 5,
                sortOrder: 5,
                cellHeight: 185,
                progress: { $0.eightHourSleepDays }
            ),
            AchievementDefinition(
                code: "emotion_7",
                kind: .emotion,
                icon: "sparkles",
                title: "Неделя эмоций",
                goal: "Отмечай эмоции 7 разных дней",
                targetValue: 7,
                sortOrder: 6,
                cellHeight: 165,
                progress: { $0.emotionEntryDays }
            ),
            AchievementDefinition(
                code: "focus_10",
                kind: .focus,
                icon: "bolt.fill",
                title: "Глубокая работа",
                goal: "Накопи 10 часов фокуса",
                targetValue: 10,
                sortOrder: 7,
                cellHeight: 145,
                progress: { $0.focusHours }
            ),
            AchievementDefinition(
                code: "tasks_100",
                kind: .tasks,
                icon: "trophy.fill",
                title: "Чемпион",
                goal: "Выполни 100 заданий",
                targetValue: 100,
                sortOrder: 8,
                cellHeight: 170,
                progress: { $0.completedTasks }
            ),
            AchievementDefinition(
                code: "sleep_8h_14",
                kind: .sleep,
                icon: "moon.stars.fill",
                title: "Режим восстановлен",
                goal: "Спи не меньше 8 часов 14 дней",
                targetValue: 14,
                sortOrder: 9,
                cellHeight: 200,
                progress: { $0.eightHourSleepDays }
            ),
            AchievementDefinition(
                code: "emotion_high_10",
                kind: .emotion,
                icon: "face.smiling.fill",
                title: "Теплая полоса",
                goal: "Отметь эмоции интенсивностью 8+ в 10 дней",
                targetValue: 10,
                sortOrder: 10,
                cellHeight: 180,
                progress: { $0.highIntensityEmotionDays }
            ),
            AchievementDefinition(
                code: "focus_50",
                kind: .focus,
                icon: "crown.fill",
                title: "Мастер концентрации",
                goal: "Накопи 50 часов фокуса",
                targetValue: 50,
                sortOrder: 11,
                cellHeight: 200,
                progress: { $0.focusHours }
            ),
            AchievementDefinition(
                code: "tasks_25",
                kind: .tasks,
                icon: "bolt.badge.checkmark.fill",
                title: "Серийный исполнитель",
                goal: "Выполни 25 заданий в календаре",
                targetValue: 25,
                sortOrder: 12,
                cellHeight: 160,
                progress: { $0.completedTasks }
            ),
            AchievementDefinition(
                code: "tasks_250",
                kind: .tasks,
                icon: "medal.fill",
                title: "Легенда продуктивности",
                goal: "Выполни 250 заданий — это уже стиль жизни",
                targetValue: 250,
                sortOrder: 13,
                cellHeight: 205,
                progress: { $0.completedTasks }
            ),
            AchievementDefinition(
                code: "sleep_7",
                kind: .sleep,
                icon: "zzz",
                title: "Дневник сна",
                goal: "Записывай сон 7 разных дней",
                targetValue: 7,
                sortOrder: 14,
                cellHeight: 155,
                progress: { $0.sleepEntryDays }
            ),
            AchievementDefinition(
                code: "sleep_8h_30",
                kind: .sleep,
                icon: "sunrise.fill",
                title: "Железный режим",
                goal: "Спи не меньше 8 часов 30 дней",
                targetValue: 30,
                sortOrder: 15,
                cellHeight: 190,
                progress: { $0.eightHourSleepDays }
            ),
            AchievementDefinition(
                code: "emotion_30",
                kind: .emotion,
                icon: "book.closed.fill",
                title: "Месяц самонаблюдения",
                goal: "Отмечай эмоции 30 разных дней",
                targetValue: 30,
                sortOrder: 16,
                cellHeight: 175,
                progress: { $0.emotionEntryDays }
            ),
            AchievementDefinition(
                code: "emotion_high_25",
                kind: .emotion,
                icon: "flame.fill",
                title: "Яркая жизнь",
                goal: "Отметь эмоции интенсивностью 8+ в 25 дней",
                targetValue: 25,
                sortOrder: 17,
                cellHeight: 200,
                progress: { $0.highIntensityEmotionDays }
            ),
            AchievementDefinition(
                code: "focus_25",
                kind: .focus,
                icon: "timer",
                title: "В потоке",
                goal: "Накопи 25 часов фокуса",
                targetValue: 25,
                sortOrder: 18,
                cellHeight: 150,
                progress: { $0.focusHours }
            ),
            AchievementDefinition(
                code: "focus_100",
                kind: .focus,
                icon: "star.circle.fill",
                title: "Сила воли",
                goal: "Накопи 100 часов фокуса — настоящая дисциплина",
                targetValue: 100,
                sortOrder: 19,
                cellHeight: 215,
                progress: { $0.focusHours }
            )
        ]
    }
}
