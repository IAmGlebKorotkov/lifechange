//
//  FocusViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 14.05.2026.
//

import UIKit

final class FocusViewController: UIViewController {

    private let viewModel: FocusViewModel
    private var playlists: [FocusMusicPlaylist] = FocusMusicLibrary.playlists
    private var selectedPlaylistID = FocusMusicLibrary.silentPlaylistID
    private var currentTasks: [FocusTaskItem] = []
    private var selectedTaskID: UUID?
    private var completedFocusTaskID: UUID?
    private var focusTimer: Timer?
    private var focusStartDate: Date?
    private var focusEndDate: Date?
    private var isFocusRunning = false

    init(viewModel: FocusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        focusTimer?.invalidate()
        viewModel.stopMusic()
        NotificationCenter.default.removeObserver(self)
    }

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Фокус"
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let closeButton: UIButton = {
        let b = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        b.tintColor = .label
        b.backgroundColor = UIColor.systemGray6
        b.layer.cornerRadius = 18
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let outerScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let taskPickerView = FocusTaskPickerView()

    private let timerCard = FocusTimerCardView()
    private let parametersView = FocusParametersView()
    private let startButton = CustomButton(title: "Начать", type: .main)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupLayout()
        setupActions()
        bindViewModel()
        observeLiveActivityActions()
        updateStartButtonState()
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isFocusRunning {
            viewModel.refresh()
        }
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(outerScrollView)
        view.addSubview(startButton)
        outerScrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(taskPickerView)
        contentStack.addArrangedSubview(timerCard)
        contentStack.addArrangedSubview(parametersView)

        timerCard.isHidden = true

        outerScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 92, right: 0)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),

            outerScrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            outerScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            outerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            outerScrollView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -12),

            contentStack.topAnchor.constraint(equalTo: outerScrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: outerScrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: outerScrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: outerScrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: outerScrollView.frameLayoutGuide.widthAnchor, constant: -40),

            taskPickerView.heightAnchor.constraint(equalToConstant: 400),

            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18)
        ])
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.enablePressScale(to: 0.90)
        parametersView.onPlaylistTapped = { [weak self] in
            self?.selectPlaylist()
        }
        startButton.addTarget(self, action: #selector(startFocus), for: .touchUpInside)
        taskPickerView.onTaskSelected = { [weak self] taskID in
            self?.selectTask(taskID)
        }
    }

    private func observeLiveActivityActions() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(liveActivityTaskCompleted(_:)),
            name: .focusLiveActivityTaskCompleted,
            object: nil
        )
    }

    private func bindViewModel() {
        viewModel.onTasksUpdated = { [weak self] tasks in
            self?.configureTasks(tasks)
        }
        viewModel.onPlaylistsUpdated = { [weak self] playlists in
            self?.configurePlaylists(playlists)
        }
        viewModel.onMusicPlaybackError = { [weak self] message in
            self?.showAlert(title: "Музыка не запустилась", message: message)
        }
    }

    private func configurePlaylists(_ playlists: [FocusMusicPlaylist]) {
        self.playlists = playlists
        if !playlists.contains(where: { $0.id == selectedPlaylistID }) {
            selectedPlaylistID = FocusMusicLibrary.silentPlaylistID
        }
        parametersView.setPlaylistTitle(selectedPlaylistTitle)
    }

    private func configureTasks(_ tasks: [FocusTaskItem]) {
        currentTasks = tasks
        if let selectedTaskID, !tasks.contains(where: { $0.id == selectedTaskID }) {
            self.selectedTaskID = nil
        }
        taskPickerView.configure(tasks: tasks, selectedTaskID: selectedTaskID)
        updateStartButtonState()
    }

    private var selectedTask: FocusTaskItem? {
        guard let selectedTaskID else { return nil }
        return currentTasks.first { $0.id == selectedTaskID }
    }

    private var selectedPlaylistTitle: String {
        playlists.first { $0.id == selectedPlaylistID }?.title ?? "Без музыки"
    }

    private func selectTask(_ taskID: UUID) {
        guard !isFocusRunning else { return }
        selectedTaskID = taskID
        completedFocusTaskID = nil
        taskPickerView.setSelectedTaskID(taskID)
        updateStartButtonState()
    }

    private func setTaskSelectionEnabled(_ isEnabled: Bool) {
        taskPickerView.setSelectionEnabled(isEnabled)
    }

    @objc private func closeTapped() {
        guard isFocusRunning else {
            dismiss(animated: true)
            return
        }

        let alert = UIAlertController(
            title: "Завершить фокус?",
            message: "Таймер будет остановлен.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Завершить", style: .destructive) { [weak self] _ in
            self?.finishFocusSession()
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    @objc private func selectPlaylist() {
        guard !isFocusRunning else { return }
        let alert = UIAlertController(title: "Выбор музыки", message: nil, preferredStyle: .actionSheet)
        playlists.forEach { playlist in
            let title = playlist.isSilent ? playlist.title : "\(playlist.title) • \(playlist.tracks.count)"
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.selectedPlaylistID = playlist.id
                self?.parametersView.setPlaylistTitle(playlist.title)
            })
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.popoverPresentationController?.sourceView = parametersView.playlistButtonSourceView
        alert.popoverPresentationController?.sourceRect = parametersView.playlistButtonSourceRect
        present(alert, animated: true)
    }

    @objc private func startFocus() {
        if isFocusRunning {
            finishFocusSession()
            return
        }

        guard let selectedTask else {
            showAlert(title: "Выберите задачу", message: "Перед началом фокуса нужно выбрать задачу.")
            return
        }

        let startDate = Date()
        let endDate = startDate.addingTimeInterval(selectedTask.focusDuration)
        focusStartDate = startDate
        focusEndDate = endDate
        isFocusRunning = true
        timerCard.configure(taskTitle: selectedTask.displayTitle, countdown: remainingString(until: endDate))
        timerCard.isHidden = false
        updateTimerLabels()
        startFocusTimer()
        setTaskSelectionEnabled(false)
        FocusLiveActivityManager.shared.start(
            taskID: selectedTask.id,
            taskTitle: selectedTask.displayTitle,
            taskTypeTitle: selectedTask.typeTitle,
            endDate: endDate
        )
        viewModel.playMusic(playlistID: selectedPlaylistID)
        updateStartButtonState()
    }

    private func updateStartButtonState() {
        if isFocusRunning {
            startButton.setTitle("Завершить фокус")
            startButton.isEnabled = true
            parametersView.setPlaylistSelectionEnabled(false)
            return
        }

        parametersView.setPlaylistSelectionEnabled(true)

        if currentTasks.isEmpty {
            startButton.setTitle("Нет задач")
            startButton.isEnabled = false
            return
        }

        if selectedTask == nil {
            startButton.setTitle("Выберите задачу")
            startButton.isEnabled = false
            return
        }

        startButton.setTitle("Начать")
        startButton.isEnabled = true
    }

    private func startFocusTimer() {
        focusTimer?.invalidate()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimerLabels()
        }
        focusTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func updateTimerLabels() {
        guard let focusEndDate else {
            timerCard.setCountdown("00:00")
            return
        }

        timerCard.setCountdown(remainingString(until: focusEndDate))
        if focusEndDate.timeIntervalSinceNow <= 0 {
            finishFocusSession()
        }
    }

    @objc private func liveActivityTaskCompleted(_ notification: Notification) {
        guard let taskID = notification.userInfo?[FocusLiveActivityNotificationKey.taskID] as? UUID else { return }

        if isFocusRunning, selectedTaskID == taskID {
            finishFocusSession(shouldCompleteTask: false)
        } else {
            viewModel.refresh()
        }
    }

    private func finishFocusSession(shouldCompleteTask: Bool = true) {
        guard isFocusRunning else { return }
        let taskIDToComplete = selectedTaskID
        let startedAt = focusStartDate
        let endedAt = Date()
        focusTimer?.invalidate()
        focusTimer = nil
        focusStartDate = nil
        focusEndDate = nil
        isFocusRunning = false
        timerCard.isHidden = true
        setTaskSelectionEnabled(true)
        FocusLiveActivityManager.shared.end()
        viewModel.stopMusic()
        viewModel.recordFocusSession(taskID: taskIDToComplete, startedAt: startedAt, endedAt: endedAt)
        if shouldCompleteTask {
            completeFocusedTaskIfNeeded(taskIDToComplete)
        } else {
            completedFocusTaskID = taskIDToComplete
            viewModel.refresh()
        }
        updateStartButtonState()
    }

    private func completeFocusedTaskIfNeeded(_ taskID: UUID?) {
        guard let taskID, completedFocusTaskID != taskID else { return }
        completedFocusTaskID = taskID
        viewModel.completeTask(id: taskID)
    }

    private func remainingString(until endDate: Date) -> String {
        let seconds = max(0, Int(ceil(endDate.timeIntervalSinceNow)))
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%02d:%02d", minutes, secs)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}
