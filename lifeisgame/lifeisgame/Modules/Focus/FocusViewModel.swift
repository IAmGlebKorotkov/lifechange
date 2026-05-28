//
//  FocusViewModel.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 14.05.2026.
//

import Foundation

struct FocusTaskItem {
    let id: UUID
    let mainTaskName: String?
    let typeTitle: String
    let title: String
    let startDate: Date
    let deadlineDate: Date
    let estimatedDuration: TimeInterval
    let importance: Int

    var focusDuration: TimeInterval {
        let fallbackDuration = deadlineDate.timeIntervalSince(startDate)
        return max(60, estimatedDuration > 0 ? estimatedDuration : fallbackDuration)
    }

    var displayTitle: String {
        if let mainTaskName {
            return "\(mainTaskName): \(title)"
        }
        return title
    }
}

final class FocusViewModel {

    var onTasksUpdated: (([FocusTaskItem]) -> Void)?
    var onPlaylistsUpdated: (([FocusMusicPlaylist]) -> Void)?
    var onMusicPlaybackError: ((String) -> Void)?

    private let fetchTasksUseCase: FetchTasksUseCase
    private let toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase
    private let achievementRepository: AchievementRepositoryProtocol
    private let musicPlayer: FocusMusicPlaying
    private let playlists: [FocusMusicPlaylist]
    private let date: Date

    init(
        fetchTasksUseCase: FetchTasksUseCase,
        toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase,
        achievementRepository: AchievementRepositoryProtocol = AchievementRepository(),
        musicPlayer: FocusMusicPlaying = FocusMusicPlayer.shared,
        playlists: [FocusMusicPlaylist] = FocusMusicLibrary.playlists,
        date: Date = Date()
    ) {
        self.fetchTasksUseCase = fetchTasksUseCase
        self.toggleTaskCompletionUseCase = toggleTaskCompletionUseCase
        self.achievementRepository = achievementRepository
        self.musicPlayer = musicPlayer
        self.playlists = playlists
        self.date = date
    }

    func viewDidLoad() {
        onPlaylistsUpdated?(playlists)
        loadTasks()
    }

    func refresh() {
        loadTasks()
    }

    func completeTask(id: UUID) {
        try? toggleTaskCompletionUseCase.setCompleted(taskID: id)
        loadTasks()
    }

    func recordFocusSession(taskID: UUID?, startedAt: Date?, endedAt: Date) {
        guard let userID = SessionManager.shared.currentUserID,
              let startedAt else { return }
        try? achievementRepository.recordFocusSession(
            forUserID: userID,
            taskID: taskID,
            startedAt: startedAt,
            endedAt: endedAt
        )
    }

    func playMusic(playlistID: FocusMusicPlaylist.ID) {
        guard let playlist = playlists.first(where: { $0.id == playlistID }) else {
            return
        }

        do {
            try musicPlayer.play(playlist)
        } catch {
            musicPlayer.stop()
            onMusicPlaybackError?(error.localizedDescription)
        }
    }

    func stopMusic() {
        musicPlayer.stop()
    }

    private func loadTasks() {
        guard let userID = SessionManager.shared.currentUserID else {
            onTasksUpdated?([])
            return
        }

        fetchTasksUseCase.execute(userID: userID, date: date) { [weak self] tasks in
            self?.onTasksUpdated?(Self.incompleteFocusTasks(from: tasks))
        }
    }

    private static func incompleteFocusTasks(from tasks: [TaskItem]) -> [FocusTaskItem] {
        tasks.flatMap { task -> [FocusTaskItem] in
            if task.isHardTask && !task.subtasks.isEmpty {
                return task.subtasks
                    .filter { !$0.isCompleted }
                    .map {
                        FocusTaskItem(
                            id: $0.id,
                            mainTaskName: task.name,
                            typeTitle: "Подзадача",
                            title: $0.name,
                            startDate: $0.startDate,
                            deadlineDate: $0.deadlineDate,
                            estimatedDuration: $0.estimatedDuration,
                            importance: $0.importance
                        )
                    }
            }

            guard !task.isCompleted else { return [] }
            let typeTitle = task.source == .calendar ? "Событие" : (task.isHardTask ? "Сложная задача" : "Задача")
            return [
                FocusTaskItem(
                    id: task.id,
                    mainTaskName: nil,
                    typeTitle: typeTitle,
                    title: task.name,
                    startDate: task.startDate,
                    deadlineDate: task.deadlineDate,
                    estimatedDuration: task.estimatedDuration,
                    importance: task.importance
                )
            ]
        }
    }
}
