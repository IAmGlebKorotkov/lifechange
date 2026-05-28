//
//  AnalyzeUserDayUseCase.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 19.05.2026.
//

import Foundation

final class AnalyzeUserDayUseCase {

    private let userRepository: UserRepositoryProtocol
    private let diaryRepository: DiaryRepositoryProtocol
    private let taskRepository: TaskRepositoryProtocol
    private let analysisEngine: UserAnalysisEngineProtocol
    private let calendar: Calendar

    init(userRepository: UserRepositoryProtocol,
         diaryRepository: DiaryRepositoryProtocol,
         taskRepository: TaskRepositoryProtocol,
         analysisEngine: UserAnalysisEngineProtocol,
         calendar: Calendar = .current) {
        self.userRepository = userRepository
        self.diaryRepository = diaryRepository
        self.taskRepository = taskRepository
        self.analysisEngine = analysisEngine
        self.calendar = calendar
    }

    func execute(userID: UUID,
                 date: Date = Date(),
                 completion: @escaping (Result<UserAnalysisResult, Error>) -> Void) {
        let user: User
        let emotionEntries: [EmotionDiaryEntry]
        let sleepEntries: [SleepDiaryEntry]
        let todayTasks: [TaskItem]
        let tomorrowTasks: [TaskItem]

        do {
            guard let fetchedUser = try userRepository.fetchUser(byID: userID) else {
                throw RepositoryError.notFound
            }
            user = fetchedUser
            emotionEntries = try diaryRepository.fetchEmotionEntries(forUserID: userID)
            sleepEntries = try diaryRepository.fetchSleepEntries(forUserID: userID)
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            todayTasks = try taskRepository.fetchTasks(forUserID: userID, on: date)
            tomorrowTasks = try taskRepository.fetchTasks(forUserID: userID, on: tomorrow)
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        let input = UserAnalysisInput(
            user: user,
            date: date,
            todayTasks: todayTasks,
            tomorrowTasks: tomorrowTasks,
            emotionEntries: emotionEntries,
            sleepEntries: sleepEntries
        )

        DispatchQueue.main.async {
            completion(.success(self.analysisEngine.analyze(input: input)))
        }
    }
}
