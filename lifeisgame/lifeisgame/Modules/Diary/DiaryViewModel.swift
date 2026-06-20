//
//  DiaryViewModel.swift
//  lifeisgame
//
//  Created by Codex on 20.06.2026.
//

import Foundation

final class DiaryViewModel {

    var onEmotionEntriesSaved: (() -> Void)?
    var onSleepEntrySaved: (() -> Void)?
    var onSaveFailed: ((String) -> Void)?

    private let diaryService: DiaryService
    private let notificationService: LocalNotificationService

    init(
        diaryService: DiaryService,
        notificationService: LocalNotificationService = .shared
    ) {
        self.diaryService = diaryService
        self.notificationService = notificationService
    }

    func saveEmotionEntries(_ entries: [EmotionDiaryInput]) {
        guard let userID = SessionManager.shared.currentUserID else {
            onSaveFailed?("Пользователь не найден.")
            return
        }

        let date = Date()
        do {
            try diaryService.saveEmotionEntries(entries, forUserID: userID, on: date)
            notificationService.cancelEmotionDiaryReminders(on: date)
            onEmotionEntriesSaved?()
        } catch {
            onSaveFailed?(error.localizedDescription)
        }
    }

    func saveSleepEntry(bedtime: Date, wakeTime: Date) {
        guard let userID = SessionManager.shared.currentUserID else {
            onSaveFailed?("Пользователь не найден.")
            return
        }

        let date = Date()
        do {
            try diaryService.saveSleepEntry(bedtime: bedtime, wakeTime: wakeTime, forUserID: userID, on: date)
            notificationService.cancelSleepDiaryReminders(on: date)
            onSleepEntrySaved?()
        } catch {
            onSaveFailed?(error.localizedDescription)
        }
    }
}
