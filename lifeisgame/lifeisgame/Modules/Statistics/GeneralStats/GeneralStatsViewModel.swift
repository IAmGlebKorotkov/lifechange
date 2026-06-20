//
//  GeneralStatsViewModel.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import Foundation

final class GeneralStatsViewModel {

    private let analysisService: AnalysisService

    var onAchievementsTapped: (() -> Void)?
    var onFocusTapped: (() -> Void)?
    var onAnalysisChanged: ((UserAnalysisResult) -> Void)?
    var onAnalysisLoadingChanged: ((Bool) -> Void)?
    var onAnalysisError: ((String) -> Void)?
    var onWeeklyStatsChanged: ((GeneralWeeklyStats) -> Void)?

    init(analysisService: AnalysisService) {
        self.analysisService = analysisService
    }

    func loadAnalysis() {
        guard let userID = SessionManager.shared.currentUserID else {
            onAnalysisError?("Пользователь не найден.")
            onWeeklyStatsChanged?(.empty)
            return
        }

        loadWeeklyStats(userID: userID)
        onAnalysisLoadingChanged?(true)
        analysisService.analyzeUserDay(userID: userID) { [weak self] result in
            guard let self else { return }
            self.onAnalysisLoadingChanged?(false)

            switch result {
            case .success(let analysis):
                self.onAnalysisChanged?(analysis)
            case .failure(let error):
                self.onAnalysisError?(error.localizedDescription)
            }
        }
    }

    private func loadWeeklyStats(userID: UUID) {
        do {
            onWeeklyStatsChanged?(try analysisService.weeklyStats(userID: userID))
        } catch {
            onWeeklyStatsChanged?(.empty)
        }
    }
}
