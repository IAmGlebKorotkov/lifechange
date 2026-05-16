//
//  TaskDayDetailViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class TaskDayDetailViewController: UIViewController {

    struct TaskItem {
        let title: String
        let typeTitle: String
        let mainTaskName: String?
        let startDate: Date
        let deadlineDate: Date
        let importance: Int
        let isCompleted: Bool
    }

    private let date: String
    private let completed: Int
    private let total: Int
    private let tasks: [TaskItem]

    init(date: String, completed: Int, total: Int, tasks: [TaskItem]) {
        self.date = date
        self.completed = completed
        self.total = total
        self.tasks = tasks
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private let dragIndicator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.separator
        v.layer.cornerRadius = 2.5
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 12
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        titleLabel.text = date
        subtitleLabel.text = "Выполнено \(completed) из \(total)"
        setupLayout()
        buildRows()
    }

    private func setupLayout() {
        view.addSubview(dragIndicator)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            dragIndicator.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            dragIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dragIndicator.widthAnchor.constraint(equalToConstant: 40),
            dragIndicator.heightAnchor.constraint(equalToConstant: 5),

            titleLabel.topAnchor.constraint(equalTo: dragIndicator.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    private func buildRows() {
        for task in tasks {
            let view = makeRow(task)
            stack.addArrangedSubview(view)
        }
    }

    private func makeRow(_ task: TaskItem) -> UIView {
        let view: TaskDayView
        if let mainTaskName = task.mainTaskName {
            view = TaskDayView(
                mainTaskName: mainTaskName,
                subtaskName: task.typeTitle,
                taskTitle: task.title,
                time: scheduleString(task.startDate, task.deadlineDate),
                timeSpent: "",
                priority: priority(for: task.importance),
                isCompleted: task.isCompleted,
                showsCompletionButton: false
            )
        } else {
            view = TaskDayView(
                subtaskName: task.typeTitle,
                taskTitle: task.title,
                time: scheduleString(task.startDate, task.deadlineDate),
                timeSpent: "",
                priority: priority(for: task.importance),
                isCompleted: task.isCompleted,
                showsCompletionButton: false
            )
        }
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: 92).isActive = true
        return view
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
        let minutes = Int(end.timeIntervalSince(start) / 60)
        if minutes < 60 { return "\(minutes) мин" }
        let hours = minutes / 60
        let restMinutes = minutes % 60
        return restMinutes == 0 ? "\(hours) ч" : "\(hours) ч \(restMinutes) мин"
    }

    private func priority(for importance: Int) -> TaskDayView.Priority {
        switch importance {
        case 1...3: return .low
        case 8...10: return .high
        default: return .medium
        }
    }
}
