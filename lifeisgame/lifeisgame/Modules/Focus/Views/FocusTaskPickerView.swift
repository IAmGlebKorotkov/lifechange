//
//  FocusTaskPickerView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class FocusTaskPickerView: CardContainerView {

    var onTaskSelected: ((UUID) -> Void)?

    private var selectedTaskID: UUID?
    private var taskViewsByID: [UUID: TaskDayView] = [:]
    private var taskIDsByViewID: [ObjectIdentifier: UUID] = [:]
    private var isSelectionEnabled = true

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Выберите задачу"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "На сегодня нет невыполненных задач"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .systemGray2
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(cornerRadius: CGFloat = 16) {
        super.init(cornerRadius: cornerRadius)
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(tasks: [FocusTaskItem], selectedTaskID: UUID?) {
        self.selectedTaskID = selectedTaskID
        taskViewsByID.removeAll()
        taskIDsByViewID.removeAll()
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        emptyLabel.isHidden = !tasks.isEmpty

        for task in tasks {
            let taskView = makeTaskView(for: task)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(taskCardTapped(_:)))
            tapGesture.cancelsTouchesInView = false
            taskView.addGestureRecognizer(tapGesture)
            taskView.isUserInteractionEnabled = true
            taskIDsByViewID[ObjectIdentifier(taskView)] = task.id
            taskViewsByID[task.id] = taskView
            stackView.addArrangedSubview(taskView)
        }

        refreshSelectionStyles()
        setSelectionEnabled(isSelectionEnabled)
    }

    func setSelectedTaskID(_ taskID: UUID?) {
        selectedTaskID = taskID
        refreshSelectionStyles()
    }

    func setSelectionEnabled(_ isEnabled: Bool) {
        isSelectionEnabled = isEnabled
        taskViewsByID.values.forEach { $0.alpha = isEnabled ? 1.0 : 0.75 }
    }

    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    private func makeTaskView(for task: FocusTaskItem) -> TaskDayView {
        if let mainTaskName = task.mainTaskName {
            return TaskDayView(
                mainTaskName: mainTaskName,
                subtaskName: task.typeTitle,
                taskTitle: task.title,
                time: scheduleString(for: task),
                timeSpent: "",
                priority: priority(for: task.importance),
                showsCompletionButton: false
            )
        }

        return TaskDayView(
            subtaskName: task.typeTitle,
            taskTitle: task.title,
            time: scheduleString(for: task),
            timeSpent: "",
            priority: priority(for: task.importance),
            showsCompletionButton: false
        )
    }

    @objc private func taskCardTapped(_ gesture: UITapGestureRecognizer) {
        guard isSelectionEnabled,
              gesture.state == .ended,
              let view = gesture.view,
              let taskID = taskIDsByViewID[ObjectIdentifier(view)] else { return }
        onTaskSelected?(taskID)
    }

    private func refreshSelectionStyles() {
        for (taskID, view) in taskViewsByID {
            let isSelected = taskID == selectedTaskID
            view.layer.borderWidth = isSelected ? 2 : 0
            view.layer.borderColor = isSelected ? UIColor.main.cgColor : UIColor.clear.cgColor
            view.backgroundColor = isSelected ? UIColor.main.withAlphaComponent(0.06) : .white
        }
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
        let hours = mins / 60
        let minutes = mins % 60
        return minutes == 0 ? "\(hours) ч" : "\(hours) ч \(minutes) мин"
    }

    private func priority(for importance: Int) -> TaskDayView.Priority {
        switch importance {
        case 1...3: return .low
        case 8...10: return .high
        default: return .medium
        }
    }
}
