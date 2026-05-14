//
//  GeneratePlanLoadingViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 09.04.2026.
//

import UIKit

final class GeneratePlanLoadingViewController: UIViewController {

    var onCompleted: (() -> Void)?

    private let tasks: [TaskItem]
    private let isEvent: Bool

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = .label
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let startTitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let startDateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .semibold)
        l.textColor = UIColor.main
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 118
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let doneButton = CustomButton(title: "Перейти в календарь", type: .main)

    init(tasks: [TaskItem], isEvent: Bool = false) {
        self.tasks = tasks.sorted { $0.startDate < $1.startDate }
        self.isEvent = isEvent
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(task: TaskItem) {
        self.init(tasks: [task])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        configureHeader()
        setupTable()
        setupLayout()
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }

    private func configureHeader() {
        let firstDate = tasks.first?.startDate ?? Date()
        titleLabel.text = isEvent ? "Событие создано" : "План готов"
        startTitleLabel.text = isEvent
            ? "Время события"
            : (tasks.count > 1 ? "Задача разделена на части" : "Начать выполнение")
        startDateLabel.text = tasks.count > 1 ? "Первая часть: \(fullDateString(firstDate))" : fullDateString(firstDate)
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(GeneratedTaskCell.self, forCellReuseIdentifier: GeneratedTaskCell.reuseIdentifier)
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(startTitleLabel)
        view.addSubview(startDateLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            startTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            startTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            startTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            startDateLabel.topAnchor.constraint(equalTo: startTitleLabel.bottomAnchor, constant: 8),
            startDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            startDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            tableView.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -20),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])
    }

    @objc private func doneTapped() {
        onCompleted?()
    }

    private func fullDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM, HH:mm"
        return formatter.string(from: date)
    }
}

extension GeneratePlanLoadingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: GeneratedTaskCell.reuseIdentifier,
            for: indexPath
        ) as? GeneratedTaskCell else {
            return UITableViewCell()
        }
        cell.configure(with: tasks[indexPath.row], kindTitle: isEvent ? "Событие" : nil)
        return cell
    }
}

private final class GeneratedTaskCell: UITableViewCell {

    static let reuseIdentifier = "GeneratedTaskCell"

    private var hostedTaskView: TaskDayView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hostedTaskView?.removeFromSuperview()
        hostedTaskView = nil
    }

    func configure(with task: TaskItem, kindTitle: String? = nil) {
        hostedTaskView?.removeFromSuperview()
        let taskView = TaskDayView(
            subtaskName: kindTitle ?? (task.isHardTask ? "Сложная задача" : "Задача"),
            taskTitle: task.name,
            time: scheduleString(task.startDate, task.deadlineDate),
            timeSpent: "",
            priority: priority(for: task.importance),
            isCompleted: task.isCompleted
        )
        hostedTaskView = taskView
        contentView.addSubview(taskView)

        NSLayoutConstraint.activate([
            taskView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            taskView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            taskView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            taskView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
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
        let minutes = max(0, Int(end.timeIntervalSince(start) / 60))
        if minutes < 60 { return "\(minutes) мин" }
        let hours = minutes / 60
        let rest = minutes % 60
        return rest == 0 ? "\(hours) ч" : "\(hours) ч \(rest) мин"
    }

    private func priority(for importance: Int) -> TaskDayView.Priority {
        switch importance {
        case 1...3: return .low
        case 8...10: return .high
        default: return .medium
        }
    }
}
