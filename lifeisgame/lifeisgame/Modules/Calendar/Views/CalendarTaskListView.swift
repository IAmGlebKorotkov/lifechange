//
//  CalendarTaskListView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

private struct CalendarTaskRow {
    let task: TaskItem
    let mainTaskName: String?
    let typeTitle: String

    var canEdit: Bool {
        task.source == .app
    }
}

final class CalendarTaskListView: UIView {

    var onAddTapped: (() -> Void)?
    var onTaskToggled: ((UUID) -> Void)?
    var onTaskSelected: ((TaskItem) -> Void)?
    var onTaskDeleteRequested: ((UUID) -> Void)?

    private var rows: [CalendarTaskRow] = []

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 108
        tv.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 100, right: 0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
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

    func configure(with tasks: [TaskItem]) {
        rows = tasks.flatMap(makeRows)
        emptyLabel.isHidden = !rows.isEmpty
        tableView.isHidden = rows.isEmpty
        tableView.reloadData()
    }

    private func setupLayout() {
        addSubview(tableView)
        addSubview(emptyLabel)
        addSubview(addButton)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CalendarTaskCell.self, forCellReuseIdentifier: CalendarTaskCell.reuseIdentifier)
        tableView.tableFooterView = makeBottomSpacer()

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40),

            addButton.widthAnchor.constraint(equalToConstant: 56),
            addButton.heightAnchor.constraint(equalToConstant: 56),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            addButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -96)
        ])

        emptyLabel.isHidden = true
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.enablePressScale()
    }

    private func makeBottomSpacer() -> UIView {
        UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 120))
    }

    @objc private func addTapped() {
        onAddTapped?()
    }

    private func makeRows(for task: TaskItem) -> [CalendarTaskRow] {
        if task.isHardTask && !task.subtasks.isEmpty {
            return task.subtasks.map {
                CalendarTaskRow(task: $0, mainTaskName: task.name, typeTitle: "Подзадача")
            }
        }

        let typeTitle = task.source == .calendar ? "Событие" : (task.isHardTask ? "Сложная задача" : "Задача")
        return [CalendarTaskRow(task: task, mainTaskName: nil, typeTitle: typeTitle)]
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
        let mins = Int(end.timeIntervalSince(start) / 60)
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

extension CalendarTaskListView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CalendarTaskCell.reuseIdentifier,
            for: indexPath
        ) as? CalendarTaskCell else {
            return UITableViewCell()
        }

        let row = rows[indexPath.row]
        cell.configure(
            row: row,
            time: scheduleString(row.task.startDate, row.task.deadlineDate),
            priority: priority(for: row.task.importance),
            onEdit: { [weak self] in
                self?.onTaskSelected?(row.task)
            },
            onToggle: { [weak self] in
                self?.onTaskToggled?(row.task.id)
            }
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rows[indexPath.row]
        guard row.canEdit else { return }
        onTaskSelected?(row.task)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let row = rows[indexPath.row]
        guard row.canEdit else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.onTaskDeleteRequested?(row.task.id)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

private final class CalendarTaskCell: UITableViewCell {

    static let reuseIdentifier = "CalendarTaskCell"

    private var taskView: TaskDayView?
    private var taskViewConstraints: [NSLayoutConstraint] = []

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
        removeTaskView()
    }

    func configure(
        row: CalendarTaskRow,
        time: String,
        priority: TaskDayView.Priority,
        onEdit: @escaping () -> Void,
        onToggle: @escaping () -> Void
    ) {
        removeTaskView()

        let view: TaskDayView
        if let mainTaskName = row.mainTaskName {
            view = TaskDayView(
                mainTaskName: mainTaskName,
                subtaskName: row.typeTitle,
                taskTitle: row.task.name,
                time: time,
                timeSpent: "",
                priority: priority,
                isCompleted: row.task.isCompleted,
                showsCompletionButton: row.canEdit,
                showsEditButton: row.canEdit
            )
        } else {
            view = TaskDayView(
                subtaskName: row.typeTitle,
                taskTitle: row.task.name,
                time: time,
                timeSpent: "",
                priority: priority,
                isCompleted: row.task.isCompleted,
                showsCompletionButton: row.canEdit,
                showsEditButton: row.canEdit
            )
        }

        view.onTap = row.canEdit ? onEdit : nil
        view.onEditTapped = row.canEdit ? onEdit : nil
        view.onCompletionChanged = row.canEdit ? { _ in onToggle() } : nil

        contentView.addSubview(view)
        taskView = view
        taskViewConstraints = [
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ]
        NSLayoutConstraint.activate(taskViewConstraints)
    }

    private func removeTaskView() {
        taskViewConstraints.forEach { $0.isActive = false }
        taskViewConstraints.removeAll()
        taskView?.removeFromSuperview()
        taskView = nil
    }
}
