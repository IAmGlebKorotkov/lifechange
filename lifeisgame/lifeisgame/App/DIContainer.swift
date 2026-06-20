//
//  DIContainer.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

final class DIContainer {

    private let authService: AuthService
    private let taskService: TaskService
    private let diaryService: DiaryService
    private let analysisService: AnalysisService
    private let achievementService: AchievementService

    init(authService: AuthService? = nil,
         taskService: TaskService? = nil,
         diaryService: DiaryService? = nil,
         analysisService: AnalysisService? = nil,
         achievementService: AchievementService? = nil) {
        let resolvedAuthService = authService ?? AuthService()
        let resolvedTaskService = taskService ?? TaskService()
        let resolvedDiaryService = diaryService ?? DiaryService()

        self.authService = resolvedAuthService
        self.taskService = resolvedTaskService
        self.diaryService = resolvedDiaryService
        self.analysisService = analysisService ?? AnalysisService(
            authService: resolvedAuthService,
            diaryService: resolvedDiaryService,
            taskService: resolvedTaskService
        )
        self.achievementService = achievementService ?? AchievementService()
    }

    func makeAuthService() -> AuthService {
        authService
    }

    func makeTaskService() -> TaskService {
        taskService
    }

    func makeDiaryService() -> DiaryService {
        diaryService
    }

    func makeAnalysisService() -> AnalysisService {
        analysisService
    }

    func makeAchievementService() -> AchievementService {
        achievementService
    }
}
