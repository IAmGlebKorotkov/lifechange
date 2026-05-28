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
    private var taskViewsByID: [UUID: TaskDayView] = [:]
    private var taskIDsByViewID: [ObjectIdentifier: UUID] = [:]
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

    private let tasksCard: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let tasksTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Выберите задачу"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let tasksScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = true
        sv.alwaysBounceVertical = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let tasksStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 12
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let emptyTasksLabel: UILabel = {
        let l = UILabel()
        l.text = "На сегодня нет невыполненных задач"
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .systemGray2
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let timerCard: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let timerTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Таймер фокуса"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let timerTaskLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let timerCountdownLabel: UILabel = {
        let l = UILabel()
        l.font = .monospacedDigitSystemFont(ofSize: 34, weight: .bold)
        l.textColor = UIColor.main
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let parametersCard: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let parametersTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Параметры фокуса"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var playlistButton = makeOptionButton(title: selectedPlaylistTitle)
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

        contentStack.addArrangedSubview(tasksCard)
        contentStack.addArrangedSubview(timerCard)
        contentStack.addArrangedSubview(parametersCard)

        setupTasksCard()
        setupTimerCard()
        setupParametersCard()
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

            tasksCard.heightAnchor.constraint(equalToConstant: 400),

            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18)
        ])
    }

    private func setupTasksCard() {
        tasksCard.addSubview(tasksTitleLabel)
        tasksCard.addSubview(tasksScrollView)
        tasksScrollView.addSubview(tasksStack)
        tasksScrollView.addSubview(emptyTasksLabel)

        NSLayoutConstraint.activate([
            tasksTitleLabel.topAnchor.constraint(equalTo: tasksCard.topAnchor, constant: 18),
            tasksTitleLabel.leadingAnchor.constraint(equalTo: tasksCard.leadingAnchor, constant: 16),
            tasksTitleLabel.trailingAnchor.constraint(equalTo: tasksCard.trailingAnchor, constant: -16),

            tasksScrollView.topAnchor.constraint(equalTo: tasksTitleLabel.bottomAnchor, constant: 14),
            tasksScrollView.leadingAnchor.constraint(equalTo: tasksCard.leadingAnchor, constant: 16),
            tasksScrollView.trailingAnchor.constraint(equalTo: tasksCard.trailingAnchor, constant: -16),
            tasksScrollView.bottomAnchor.constraint(equalTo: tasksCard.bottomAnchor, constant: -16),

            tasksStack.topAnchor.constraint(equalTo: tasksScrollView.contentLayoutGuide.topAnchor),
            tasksStack.leadingAnchor.constraint(equalTo: tasksScrollView.contentLayoutGuide.leadingAnchor),
            tasksStack.trailingAnchor.constraint(equalTo: tasksScrollView.contentLayoutGuide.trailingAnchor),
            tasksStack.bottomAnchor.constraint(equalTo: tasksScrollView.contentLayoutGuide.bottomAnchor),
            tasksStack.widthAnchor.constraint(equalTo: tasksScrollView.frameLayoutGuide.widthAnchor),

            emptyTasksLabel.centerXAnchor.constraint(equalTo: tasksScrollView.frameLayoutGuide.centerXAnchor),
            emptyTasksLabel.centerYAnchor.constraint(equalTo: tasksScrollView.frameLayoutGuide.centerYAnchor),
            emptyTasksLabel.leadingAnchor.constraint(greaterThanOrEqualTo: tasksScrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            emptyTasksLabel.trailingAnchor.constraint(lessThanOrEqualTo: tasksScrollView.frameLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    private func setupTimerCard() {
        timerCard.addSubview(timerTitleLabel)
        timerCard.addSubview(timerTaskLabel)
        timerCard.addSubview(timerCountdownLabel)

        NSLayoutConstraint.activate([
            timerTitleLabel.topAnchor.constraint(equalTo: timerCard.topAnchor, constant: 18),
            timerTitleLabel.leadingAnchor.constraint(equalTo: timerCard.leadingAnchor, constant: 16),
            timerTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timerCountdownLabel.leadingAnchor, constant: -12),

            timerTaskLabel.topAnchor.constraint(equalTo: timerTitleLabel.bottomAnchor, constant: 8),
            timerTaskLabel.leadingAnchor.constraint(equalTo: timerTitleLabel.leadingAnchor),
            timerTaskLabel.trailingAnchor.constraint(equalTo: timerCountdownLabel.leadingAnchor, constant: -12),
            timerTaskLabel.bottomAnchor.constraint(lessThanOrEqualTo: timerCard.bottomAnchor, constant: -18),

            timerCountdownLabel.centerYAnchor.constraint(equalTo: timerCard.centerYAnchor),
            timerCountdownLabel.trailingAnchor.constraint(equalTo: timerCard.trailingAnchor, constant: -16),
            timerCountdownLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 118),

            timerCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 112)
        ])
    }

    private func setupParametersCard() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        parametersCard.addSubview(parametersTitleLabel)
        parametersCard.addSubview(stack)

        stack.addArrangedSubview(makeOptionBlock(
            title: "Выбор музыки",
            subtitle: "Плейлист",
            button: playlistButton
        ))

        NSLayoutConstraint.activate([
            parametersTitleLabel.topAnchor.constraint(equalTo: parametersCard.topAnchor, constant: 18),
            parametersTitleLabel.leadingAnchor.constraint(equalTo: parametersCard.leadingAnchor, constant: 16),
            parametersTitleLabel.trailingAnchor.constraint(equalTo: parametersCard.trailingAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: parametersTitleLabel.bottomAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: parametersCard.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: parametersCard.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: parametersCard.bottomAnchor, constant: -16)
        ])
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.enablePressScale(to: 0.90)
        playlistButton.addTarget(self, action: #selector(selectPlaylist), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startFocus), for: .touchUpInside)
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
        playlistButton.setTitle(selectedPlaylistTitle, for: .normal)
    }

    private func configureTasks(_ tasks: [FocusTaskItem]) {
        currentTasks = tasks
        taskViewsByID.removeAll()
        taskIDsByViewID.removeAll()
        if let selectedTaskID, !tasks.contains(where: { $0.id == selectedTaskID }) {
            self.selectedTaskID = nil
        }

        tasksStack.arrangedSubviews.forEach { view in
            tasksStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        emptyTasksLabel.isHidden = !tasks.isEmpty

        for task in tasks {
            let view: TaskDayView
            if let mainTaskName = task.mainTaskName {
                view = TaskDayView(
                    mainTaskName: mainTaskName,
                    subtaskName: task.typeTitle,
                    taskTitle: task.title,
                    time: scheduleString(for: task),
                    timeSpent: "",
                    priority: priority(for: task.importance),
                    showsCompletionButton: false
                )
            } else {
                view = TaskDayView(
                    subtaskName: task.typeTitle,
                    taskTitle: task.title,
                    time: scheduleString(for: task),
                    timeSpent: "",
                    priority: priority(for: task.importance),
                    showsCompletionButton: false
                )
            }
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(taskCardTapped(_:)))
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)
            view.isUserInteractionEnabled = true
            taskIDsByViewID[ObjectIdentifier(view)] = task.id
            taskViewsByID[task.id] = view
            tasksStack.addArrangedSubview(view)
        }

        refreshTaskSelectionStyles()
        updateStartButtonState()
    }

    @objc private func taskCardTapped(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended,
              let view = gesture.view,
              let taskID = taskIDsByViewID[ObjectIdentifier(view)] else { return }
        selectTask(taskID)
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
        refreshTaskSelectionStyles()
        updateStartButtonState()
    }

    private func refreshTaskSelectionStyles() {
        for (taskID, view) in taskViewsByID {
            let isSelected = taskID == selectedTaskID
            view.layer.borderWidth = isSelected ? 2 : 0
            view.layer.borderColor = isSelected ? UIColor.main.cgColor : UIColor.clear.cgColor
            view.backgroundColor = isSelected ? UIColor.main.withAlphaComponent(0.06) : .white
        }
    }

    private func setTaskSelectionEnabled(_ isEnabled: Bool) {
        taskViewsByID.values.forEach { $0.alpha = isEnabled ? 1.0 : 0.75 }
    }

    private func makeOptionBlock(title: String, subtitle: String, button: UIButton) -> UIView {
        let block = UIView()
        block.backgroundColor = UIColor.main.withAlphaComponent(0.06)
        block.layer.cornerRadius = 14
        block.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        block.addSubview(titleLabel)
        block.addSubview(subtitleLabel)
        block.addSubview(button)

        NSLayoutConstraint.activate([
            block.heightAnchor.constraint(greaterThanOrEqualToConstant: 76),

            titleLabel.topAnchor.constraint(equalTo: block.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: block.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: button.leadingAnchor, constant: -12),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: button.leadingAnchor, constant: -12),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: block.bottomAnchor, constant: -14),

            button.centerYAnchor.constraint(equalTo: block.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: block.trailingAnchor, constant: -14),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 108),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])

        return block
    }

    private func makeOptionButton(title: String) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        b.tintColor = UIColor.main
        b.backgroundColor = .white
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
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
                self?.playlistButton.setTitle(playlist.title, for: .normal)
            })
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.popoverPresentationController?.sourceView = playlistButton
        alert.popoverPresentationController?.sourceRect = playlistButton.bounds
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
        timerTaskLabel.text = selectedTask.displayTitle
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
            playlistButton.isEnabled = false
            playlistButton.alpha = 0.65
            return
        }

        playlistButton.isEnabled = true
        playlistButton.alpha = 1.0

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
            timerCountdownLabel.text = "00:00"
            return
        }

        timerCountdownLabel.text = remainingString(until: focusEndDate)
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

    private func scheduleString(for task: FocusTaskItem) -> String {
        "\(timeString(task.startDate)) - \(timeString(task.deadlineDate)) (\(durationString(task.focusDuration)))"
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func durationString(_ duration: TimeInterval) -> String {
        let mins = max(1, Int(ceil(duration / 60)))
        if mins < 60 { return "\(mins) мин" }
        let h = mins / 60
        let m = mins % 60
        return m == 0 ? "\(h) ч" : "\(h) ч \(m) мин"
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

    private func priority(for importance: Int) -> TaskDayView.Priority {
        switch importance {
        case 1...3: return .low
        case 8...10: return .high
        default: return .medium
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}
