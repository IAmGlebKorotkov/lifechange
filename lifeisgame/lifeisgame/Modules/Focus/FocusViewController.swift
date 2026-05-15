//
//  FocusViewController.swift
//  lifeisgame
//
//  Created by Codex on 14.05.2026.
//

import UIKit
import SwiftUI

final class FocusViewController: UIViewController {

    private let viewModel: FocusViewModel
    private var selectedPlaylist = "Ничего"
    private var blockedApps = "Не выбрано"

    init(viewModel: FocusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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
        l.text = "Невыполненные задачи"
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

    private lazy var playlistButton = makeOptionButton(title: selectedPlaylist)
    private lazy var blockedAppsButton = makeOptionButton(title: "Выбрать")
    private let startButton = CustomButton(title: "Начать", type: .main)
    private weak var blockedAppsSubtitleLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupLayout()
        setupActions()
        bindViewModel()
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
        updateBlockedAppsSummary()
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(outerScrollView)
        view.addSubview(startButton)
        outerScrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(tasksCard)
        contentStack.addArrangedSubview(parametersCard)

        setupTasksCard()
        setupParametersCard()

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
        stack.addArrangedSubview(makeOptionBlock(
            title: "Заблокированные приложения",
            subtitle: blockedApps,
            button: blockedAppsButton
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
        blockedAppsButton.addTarget(self, action: #selector(selectBlockedApps), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startFocus), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.onTasksUpdated = { [weak self] tasks in
            self?.configureTasks(tasks)
        }
    }

    private func configureTasks(_ tasks: [FocusTaskItem]) {
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
                    time: scheduleString(task.startDate, task.deadlineDate),
                    timeSpent: "",
                    priority: priority(for: task.importance),
                    showsCompletionButton: false
                )
            } else {
                view = TaskDayView(
                    subtaskName: task.typeTitle,
                    taskTitle: task.title,
                    time: scheduleString(task.startDate, task.deadlineDate),
                    timeSpent: "",
                    priority: priority(for: task.importance),
                    showsCompletionButton: false
                )
            }
            tasksStack.addArrangedSubview(view)
        }
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
        if title == "Заблокированные приложения" {
            blockedAppsSubtitleLabel = subtitleLabel
        }

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
        dismiss(animated: true)
    }

    @objc private func selectPlaylist() {
        let alert = UIAlertController(title: "Выбор музыки", message: nil, preferredStyle: .actionSheet)
        ["Ничего", "Deep Focus", "Lo-fi", "Классика", "Белый шум"].forEach { playlist in
            alert.addAction(UIAlertAction(title: playlist, style: .default) { [weak self] _ in
                self?.selectedPlaylist = playlist
                self?.playlistButton.setTitle(playlist, for: .normal)
            })
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.popoverPresentationController?.sourceView = playlistButton
        alert.popoverPresentationController?.sourceRect = playlistButton.bounds
        present(alert, animated: true)
    }

    @objc private func selectBlockedApps() {
        let selectionView = BlockedAppsSelectionView(store: FocusBlockingSelectionStore.shared)
        let controller = UIHostingController(rootView: selectionView)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }

    @objc private func startFocus() {
        FocusBlockingSelectionStore.shared.applyShielding()
        startButton.setTitle("Фокус начат")
        startButton.isEnabled = false
    }

    private func updateBlockedAppsSummary() {
        let count = FocusBlockingSelectionStore.shared.selectedItemsCount
        blockedApps = count == 0 ? "Не выбрано" : "Выбрано: \(count)"
        blockedAppsSubtitleLabel?.text = blockedApps
        blockedAppsButton.setTitle(count == 0 ? "Выбрать" : "Изменить", for: .normal)
    }

    private func scheduleString(_ start: Date, _ end: Date) -> String {
        "\(timeString(start)) - \(timeString(end)) (\(durationString(start, end)))"
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func durationString(_ start: Date, _ end: Date) -> String {
        let mins = max(0, Int(end.timeIntervalSince(start) / 60))
        if mins < 60 { return "\(mins) мин" }
        let h = mins / 60
        let m = mins % 60
        return m == 0 ? "\(h) ч" : "\(h) ч \(m) мин"
    }

    private func priority(for importance: Int) -> TaskDayView.Priority {
        switch importance {
        case 1...3: return .low
        case 8...10: return .high
        default: return .medium
        }
    }
}
