//
//  CalendarTaskListView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class CalendarTaskListView: UIView {

    var onAddTapped: (() -> Void)?
    var onTaskToggled: ((UUID) -> Void)?


    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let taskStackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 12
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let addButton: UIButton = {
        let b = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        b.setImage(UIImage(systemName: "plus", withConfiguration: cfg), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.main.withAlphaComponent(0.75)
        b.layer.cornerRadius = 28
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()


    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "Нет задач на этот день"
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .systemGray2
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setupLayout() {
        addSubview(scrollView)
        scrollView.addSubview(taskStackView)
        addSubview(addButton)

        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            taskStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 4),
            taskStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            taskStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            taskStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            taskStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),

            addButton.widthAnchor.constraint(equalToConstant: 56),
            addButton.heightAnchor.constraint(equalToConstant: 56),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            addButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -96)
        ])

        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.enablePressScale()
    }

    @objc private func addTapped() {
        onAddTapped?()
    }

    func configure(with tasks: [TaskItem]) {
        taskStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emptyLabel.removeFromSuperview()

        if tasks.isEmpty {
            addSubview(emptyLabel)
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                emptyLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40)
            ])
            return
        }

        for task in tasks {
            let views = makeTaskViews(for: task)
            for view in views {
                taskStackView.addArrangedSubview(view)
            }
        }
    }

    private func makeTaskViews(for task: TaskItem) -> [TaskDayView] {
        if task.isHardTask && !task.subtasks.isEmpty {
            return task.subtasks.map { subtask in
                let view = TaskDayView(
                    mainTaskName: task.name,
                    subtaskName: "Подзадача",
                    taskTitle: subtask.name,
                    time: timeString(subtask.startDate),
                    timeSpent: durationString(subtask.startDate, subtask.deadlineDate),
                    priority: .medium,
                    isCompleted: subtask.isCompleted
                )
                let id = subtask.id
                view.onCompletionChanged = { [weak self, weak view] isCompleted in
                    guard let self, let view else { return }
                    if isCompleted { self.moveCompletedTaskToBottom(view) }
                    self.onTaskToggled?(id)
                }
                return view
            }
        } else {
            let subtaskLabel = task.source == .calendar ? "Событие" : (task.isHardTask ? "Сложная задача" : "Задача")
            let view = TaskDayView(
                subtaskName: subtaskLabel,
                taskTitle: task.name,
                time: timeString(task.startDate),
                timeSpent: durationString(task.startDate, task.deadlineDate),
                priority: .medium,
                isCompleted: task.isCompleted
            )
            if task.source == .app {
                let id = task.id
                view.onCompletionChanged = { [weak self, weak view] isCompleted in
                    guard let self, let view else { return }
                    if isCompleted { self.moveCompletedTaskToBottom(view) }
                    self.onTaskToggled?(id)
                }
            }
            return [view]
        }
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    private func durationString(_ start: Date, _ end: Date) -> String {
        let mins = Int(end.timeIntervalSince(start) / 60)
        if mins < 60 { return "\(mins) мин" }
        let h = mins / 60; let m = mins % 60
        return m == 0 ? "\(h) ч" : "\(h) ч \(m) мин"
    }


    private func moveCompletedTaskToBottom(_ taskView: TaskDayView) {
        let originalFrame = taskView.convert(taskView.bounds, to: scrollView)

        taskStackView.removeArrangedSubview(taskView)
        taskView.removeFromSuperview()
        taskStackView.addArrangedSubview(taskView)

        taskStackView.layoutIfNeeded()
        let newFrame = taskView.convert(taskView.bounds, to: scrollView)

        let delta = originalFrame.minY - newFrame.minY
        taskView.transform = CGAffineTransform(translationX: 0, y: delta)

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: .curveEaseInOut
        ) {
            taskView.transform = .identity
        }
    }
}
