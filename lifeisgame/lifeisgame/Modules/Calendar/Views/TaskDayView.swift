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
            case .low:    return .appSuccess
            case .medium: return .appWarning
            case .high:   return .appDanger
            }
        }
    }

    private struct CategoryStyle {
        let sfSymbol: String
        let tileColor: UIColor
        let tintColor: UIColor
        let chipText: String?
    }

    private(set) var isTaskCompleted: Bool = false
    var onCompletionChanged: ((Bool) -> Void)?
    var onTap: (() -> Void)?
    var onEditTapped: (() -> Void)?
    private var showsCompletionButton = true
    private var showsEditButton = false
    private var taskTitleText = ""

    private let iconTile: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 11
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private let priorityDot: UIView = {
        let view = UIView()
        view.backgroundColor = .appWarning
        view.layer.cornerRadius = 3.5
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let chipLabel: PaddedChipLabel = {
        let label = PaddedChipLabel()
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.isHidden = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(rgb: 0x3C3C43, alpha: 0.5)
        label.numberOfLines = 1
        return label
    }()

    private let completeButton: UIButton = {
        let button = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        button.setImage(UIImage(systemName: "circle", withConfiguration: cfg), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: cfg), for: .selected)
        button.tintColor = UIColor(rgb: 0x3C3C43, alpha: 0.25)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()

    init(subtaskName: String,
         taskTitle: String,
         time: String,
         timeSpent: String,
         priority: Priority,
         isCompleted: Bool = false,
         showsCompletionButton: Bool = true,
         showsEditButton: Bool = false) {
        super.init(frame: .zero)
        self.showsCompletionButton = showsCompletionButton
        self.showsEditButton = showsEditButton
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
         isCompleted: Bool = false,
         showsCompletionButton: Bool = true,
         showsEditButton: Bool = false) {
        super.init(frame: .zero)
        self.showsCompletionButton = showsCompletionButton
        self.showsEditButton = showsEditButton
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
        taskTitleText = taskTitle
        titleLabel.text = taskTitle
        priorityDot.isHidden = priority != .high

        var subtitleParts: [String] = []
        if case .hard(let name) = type, !name.isEmpty {
            subtitleParts.append("из «\(name)»")
        }
        if !time.isEmpty { subtitleParts.append(time) }
        if !timeSpent.isEmpty { subtitleParts.append(timeSpent) }
        subtitleLabel.text = subtitleParts.joined(separator: " · ")

        let style = categoryStyle(for: subtaskName)
        iconTile.backgroundColor = style.tileColor
        let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        iconView.image = UIImage(systemName: style.sfSymbol, withConfiguration: cfg)
        iconView.tintColor = style.tintColor

        if let chipText = style.chipText {
            chipLabel.text = chipText
            chipLabel.textColor = style.tintColor
            chipLabel.backgroundColor = style.tileColor
            chipLabel.isHidden = false
        }
    }

    private func categoryStyle(for typeTitle: String) -> CategoryStyle {
        switch typeTitle.lowercased() {
        case "событие":
            return CategoryStyle(
                sfSymbol: "calendar",
                tileColor: UIColor(rgb: 0xDCEBFF),
                tintColor: .appInfo,
                chipText: "событие"
            )
        case "подзадача":
            return CategoryStyle(
                sfSymbol: "list.bullet",
                tileColor: UIColor(rgb: 0xD8F5E3),
                tintColor: UIColor(rgb: 0x0A7D4D),
                chipText: "подзадача"
            )
        case "сложная задача":
            return CategoryStyle(
                sfSymbol: "square.stack.3d.up.fill",
                tileColor: UIColor(rgb: 0xEAE2FF),
                tintColor: .appSleepPurple,
                chipText: nil
            )
        default:
            return CategoryStyle(
                sfSymbol: "doc.text",
                tileColor: .lightMain,
                tintColor: .main,
                chipText: nil
            )
        }
    }

    private func buildLayout() {
        backgroundColor = .white
        layer.cornerRadius = 18
        applyCardShadow()
        translatesAutoresizingMaskIntoConstraints = false

        iconTile.addSubview(iconView)

        let titleRow = UIStackView(arrangedSubviews: [titleLabel, priorityDot, chipLabel, UIView()])
        titleRow.axis = .horizontal
        titleRow.spacing = 6
        titleRow.alignment = .center

        let textStack = UIStackView(arrangedSubviews: [titleRow, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let mainStack = UIStackView(arrangedSubviews: [iconTile, textStack, completeButton])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        mainStack.isUserInteractionEnabled = true
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)

        NSLayoutConstraint.activate([
            iconTile.widthAnchor.constraint(equalToConstant: 38),
            iconTile.heightAnchor.constraint(equalToConstant: 38),

            iconView.centerXAnchor.constraint(equalTo: iconTile.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconTile.centerYAnchor),

            priorityDot.widthAnchor.constraint(equalToConstant: 7),
            priorityDot.heightAnchor.constraint(equalToConstant: 7),

            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -13)
        ])

        completeButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)
        addTarget(self, action: #selector(cardTapped), for: .touchUpInside)
        completeButton.enablePressScale()
        completeButton.isHidden = !showsCompletionButton
    }

    @objc private func cardTapped() {
        onTap?()
    }

    @objc private func completeTapped() {
        isTaskCompleted.toggle()
        animateCompletionToggle()
        onCompletionChanged?(isTaskCompleted)
    }

    private func animateCompletionToggle() {
        UIView.animate(withDuration: 0.2) {
            self.applyCompletionAppearance()
        }
    }

    private func silentlyMarkCompleted() {
        isTaskCompleted = true
        applyCompletionAppearance()
    }

    private func applyCompletionAppearance() {
        completeButton.isSelected = isTaskCompleted
        completeButton.tintColor = isTaskCompleted ? .appSuccess : UIColor(rgb: 0x3C3C43, alpha: 0.25)
        alpha = isTaskCompleted ? 0.62 : 1.0

        if isTaskCompleted {
            titleLabel.attributedText = NSAttributedString(
                string: taskTitleText,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = taskTitleText
        }
    }
}

private final class PaddedChipLabel: UILabel {

    private let insets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}
