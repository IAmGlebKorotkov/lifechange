//
//  TaskDayView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class TaskDayView: UIControl {


    enum TaskType {
        case light
        case hard(mainTaskName: String)
    }

    enum Priority {
        case low, medium, high

        var title: String {
            switch self {
            case .low:    return "Низкий"
            case .medium: return "Средний"
            case .high:   return "Высокий"
            }
        }
        var color: UIColor {
            switch self {
            case .low:    return .systemGreen
            case .medium: return .systemOrange
            case .high:   return .systemRed
            }
        }
    }


    private(set) var isTaskCompleted: Bool = false
    var onCompletionChanged: ((Bool) -> Void)?


    private let subtaskLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .systemGray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let mainTaskLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = UIColor.main.withAlphaComponent(0.7)
        l.textAlignment = .center
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let block1: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()


    private let timeIconView: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        let iv = UIImageView(image: UIImage(named: "Time Circle"))
        iv.tintColor = UIColor.main
        iv.contentMode = .scaleAspectFit
        iv.setContentHuggingPriority(.required, for: .horizontal)
        return iv
    }()

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor.main
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.82
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return l
    }()

    private lazy var timeStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [timeIconView, timeLabel])
        s.axis = .horizontal
        s.spacing = 4
        s.alignment = .center
        s.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return s
    }()

    private let timeSpentLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor.main
        l.setContentHuggingPriority(.required, for: .horizontal)
        return l
    }()

    private let priorityBadge: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 6
        v.setContentHuggingPriority(.required, for: .horizontal)
        return v
    }()

    private let priorityLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let completeButton: UIButton = {
        let b = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        b.setImage(UIImage(systemName: "circle",              withConfiguration: cfg), for: .normal)
        b.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: cfg), for: .selected)
        b.tintColor = .systemGray3
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setContentHuggingPriority(.required, for: .horizontal)
        return b
    }()

    private lazy var block3: UIStackView = {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let s = UIStackView(arrangedSubviews: [timeStack, timeSpentLabel, priorityBadge, spacer, completeButton])
        s.axis = .horizontal
        s.spacing = 8
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()


    private lazy var mainStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [block1, titleLabel, block3])
        s.axis = .vertical
        s.spacing = 10
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()


    init(subtaskName: String,
         taskTitle: String,
         time: String,
         timeSpent: String,
         priority: Priority,
         isCompleted: Bool = false) {
        super.init(frame: .zero)
        applyContent(type: .light,
                     subtaskName: subtaskName,
                     taskTitle: taskTitle,
                     time: time,
                     timeSpent: timeSpent,
                     priority: priority)
        buildLayout()
        if isCompleted { silentlyMarkCompleted() }
    }


    init(mainTaskName: String,
         subtaskName: String,
         taskTitle: String,
         time: String,
         timeSpent: String,
         priority: Priority,
         isCompleted: Bool = false) {
        super.init(frame: .zero)
        applyContent(type: .hard(mainTaskName: mainTaskName),
                     subtaskName: subtaskName,
                     taskTitle: taskTitle,
                     time: time,
                     timeSpent: timeSpent,
                     priority: priority)
        buildLayout()
        if isCompleted { silentlyMarkCompleted() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func applyContent(type: TaskType,
                               subtaskName: String,
                               taskTitle: String,
                               time: String,
                               timeSpent: String,
                               priority: Priority) {
        subtaskLabel.text = subtaskName
        titleLabel.text = taskTitle
        timeLabel.text = time
        timeSpentLabel.text = timeSpent
        timeSpentLabel.isHidden = timeSpent.isEmpty

        priorityLabel.text = priority.title
        priorityLabel.textColor = priority.color
        priorityBadge.backgroundColor = priority.color.withAlphaComponent(0.12)

        if case .hard(let name) = type {
            mainTaskLabel.text = name
            mainTaskLabel.isHidden = false
        }
    }


    private func buildLayout() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.07
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        translatesAutoresizingMaskIntoConstraints = false

        priorityBadge.addSubview(priorityLabel)
        priorityLabel.translatesAutoresizingMaskIntoConstraints = true
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priorityLabel.topAnchor.constraint(equalTo: priorityBadge.topAnchor, constant: 3),
            priorityLabel.bottomAnchor.constraint(equalTo: priorityBadge.bottomAnchor, constant: -3),
            priorityLabel.leadingAnchor.constraint(equalTo: priorityBadge.leadingAnchor, constant: 8),
            priorityLabel.trailingAnchor.constraint(equalTo: priorityBadge.trailingAnchor, constant: -8)
        ])

        block1.addSubview(subtaskLabel)
        block1.addSubview(mainTaskLabel)

        NSLayoutConstraint.activate([
            block1.heightAnchor.constraint(greaterThanOrEqualToConstant: 18),

            subtaskLabel.leadingAnchor.constraint(equalTo: block1.leadingAnchor),
            subtaskLabel.topAnchor.constraint(equalTo: block1.topAnchor),
            subtaskLabel.bottomAnchor.constraint(equalTo: block1.bottomAnchor),

            mainTaskLabel.centerXAnchor.constraint(equalTo: block1.centerXAnchor),
            mainTaskLabel.centerYAnchor.constraint(equalTo: block1.centerYAnchor)
        ])

        addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])

        completeButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)
        completeButton.enablePressScale()
    }


    @objc private func completeTapped() {
        isTaskCompleted.toggle()
        animateCompletionToggle()
        onCompletionChanged?(isTaskCompleted)
    }

    private func animateCompletionToggle() {
        UIView.animate(withDuration: 0.2) {
            self.completeButton.isSelected = self.isTaskCompleted
            self.completeButton.tintColor = self.isTaskCompleted ? UIColor.main : .systemGray3
            self.titleLabel.alpha = self.isTaskCompleted ? 0.4 : 1.0
            self.alpha = self.isTaskCompleted ? 0.75 : 1.0
        }
    }

    private func silentlyMarkCompleted() {
        isTaskCompleted = true
        completeButton.isSelected = true
        completeButton.tintColor = UIColor.main
        titleLabel.alpha = 0.4
        alpha = 0.75
    }
}
