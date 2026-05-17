//
//  TaskStatsView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

struct TaskStatsDaySummary {
    let date: Date
    let title: String
    let completed: Int
    let total: Int
    let tasks: [TaskDayDetailViewController.TaskItem]
}

final class TaskStatsView: UIView {

    private var days: [TaskStatsDaySummary] = []

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

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "Пока нет задач для статистики"
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .systemGray2
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    weak var presentingViewController: UIViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(days: [TaskStatsDaySummary]) {
        self.days = days
        buildRows()
    }

    private func setupLayout() {
        addSubview(scrollView)
        addSubview(emptyLabel)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),

            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40)
        ])
    }

    private func buildRows() {
        stack.arrangedSubviews.forEach {
            stack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        emptyLabel.isHidden = !days.isEmpty
        scrollView.isHidden = days.isEmpty
        guard !days.isEmpty else { return }

        stack.addArrangedSubview(makeSummaryCard())
        for (i, day) in days.enumerated() {
            stack.addArrangedSubview(makeRow(day, index: i))
        }
        stack.addArrangedSubview(makeBottomSpacer())
    }

    private func makeBottomSpacer() -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 120).isActive = true
        return spacer
    }

    private func makeSummaryCard() -> UIView {
        let total = days.reduce(0) { $0 + $1.total }
        let completed = days.reduce(0) { $0 + $1.completed }

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Всего выполнено"
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = "\(completed) из \(total)"
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = UIColor.main
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Дней с задачами: \(days.count)"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let progressBg = UIView()
        progressBg.backgroundColor = UIColor.systemGray5
        progressBg.layer.cornerRadius = 4
        progressBg.translatesAutoresizingMaskIntoConstraints = false

        let progressFill = UIView()
        let ratio = CGFloat(completed) / CGFloat(max(total, 1))
        progressFill.backgroundColor = UIColor.main
        progressFill.layer.cornerRadius = 4
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressBg.addSubview(progressFill)

        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        card.addSubview(subtitleLabel)
        card.addSubview(progressBg)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            progressBg.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            progressBg.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progressBg.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            progressBg.heightAnchor.constraint(equalToConstant: 8),
            progressBg.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),

            progressFill.leadingAnchor.constraint(equalTo: progressBg.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressBg.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressBg.bottomAnchor),
            progressFill.widthAnchor.constraint(equalTo: progressBg.widthAnchor, multiplier: ratio)
        ])

        return card
    }

    private func makeRow(_ day: TaskStatsDaySummary, index: Int) -> UIView {
        let card = UIControl()
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.translatesAutoresizingMaskIntoConstraints = false
        card.tag = index
        card.addTarget(self, action: #selector(rowTapped(_:)), for: .touchUpInside)
        card.enablePressScale(to: 0.97)

        let iconBg = UIView()
        iconBg.backgroundColor = UIColor.main.withAlphaComponent(0.1)
        iconBg.layer.cornerRadius = 22
        iconBg.isUserInteractionEnabled = false
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let iconView = UIImageView(image: UIImage(named: "Calendar") ??
                                   UIImage(systemName: "calendar", withConfiguration: cfg))
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor.main
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconView)

        let dateLabel = UILabel()
        dateLabel.text = day.title
        dateLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        dateLabel.textColor = .label

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Выполнено \(day.completed) из \(day.total)"
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [dateLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.isUserInteractionEnabled = false
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let progressBg = UIView()
        progressBg.backgroundColor = UIColor.systemGray5
        progressBg.layer.cornerRadius = 3
        progressBg.isUserInteractionEnabled = false
        progressBg.translatesAutoresizingMaskIntoConstraints = false

        let progressFill = UIView()
        let ratio = CGFloat(day.completed) / CGFloat(max(day.total, 1))
        progressFill.backgroundColor = UIColor.main
        progressFill.layer.cornerRadius = 3
        progressFill.isUserInteractionEnabled = false
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressBg.addSubview(progressFill)

        let chevronCfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: chevronCfg))
        chevron.tintColor = .systemGray3
        chevron.isUserInteractionEnabled = false
        chevron.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconBg)
        card.addSubview(textStack)
        card.addSubview(progressBg)
        card.addSubview(chevron)

        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            iconBg.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 44),
            iconBg.heightAnchor.constraint(equalToConstant: 44),

            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            textStack.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: -6),

            progressBg.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
            progressBg.topAnchor.constraint(equalTo: textStack.bottomAnchor, constant: 6),
            progressBg.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -12),
            progressBg.heightAnchor.constraint(equalToConstant: 6),

            progressFill.leadingAnchor.constraint(equalTo: progressBg.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressBg.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressBg.bottomAnchor),
            progressFill.widthAnchor.constraint(equalTo: progressBg.widthAnchor, multiplier: ratio),

            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            card.heightAnchor.constraint(equalToConstant: 80)
        ])

        return card
    }

    @objc private func rowTapped(_ sender: UIControl) {
        let day = days[sender.tag]
        let detail = TaskDayDetailViewController(
            date: day.title,
            completed: day.completed,
            total: day.total,
            tasks: day.tasks
        )
        if let presenter = detail.sheetPresentationController {
            let availableHeight = presentingViewController?.view.bounds.height ?? bounds.height
            let height = min(CGFloat(day.tasks.count) * 106 + 154, max(320, availableHeight * 0.82))
            presenter.detents = [.custom { _ in height }]
            presenter.prefersGrabberVisible = false
            presenter.preferredCornerRadius = 24
        }
        presentingViewController?.present(detail, animated: true)
    }
}
