//
//  TaskStatsView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class TaskStatsView: UIView {


    private struct DaySummary {
        let date: String
        let completed: Int
        let total: Int
        let tasks: [TaskDayDetailViewController.TaskItem]
    }

    private let days: [DaySummary] = [
        DaySummary(date: "30 марта", completed: 3, total: 5, tasks: [
            .init(title: "Утренняя зарядка",    isCompleted: true),
            .init(title: "Прочитать 20 страниц", isCompleted: true),
            .init(title: "Медитация",            isCompleted: true),
            .init(title: "Вечерняя пробежка",    isCompleted: false),
            .init(title: "Написать дневник",     isCompleted: false)
        ]),
        DaySummary(date: "29 марта", completed: 5, total: 5, tasks: [
            .init(title: "Утренняя зарядка",    isCompleted: true),
            .init(title: "Прочитать 20 страниц", isCompleted: true),
            .init(title: "Медитация",            isCompleted: true),
            .init(title: "Вечерняя пробежка",    isCompleted: true),
            .init(title: "Написать дневник",     isCompleted: true)
        ]),
        DaySummary(date: "28 марта", completed: 2, total: 4, tasks: [
            .init(title: "Утренняя зарядка",    isCompleted: true),
            .init(title: "Прочитать 20 страниц", isCompleted: false),
            .init(title: "Медитация",            isCompleted: true),
            .init(title: "Вечерняя пробежка",    isCompleted: false)
        ]),
        DaySummary(date: "27 марта", completed: 4, total: 6, tasks: [
            .init(title: "Утренняя зарядка",    isCompleted: true),
            .init(title: "Прочитать 20 страниц", isCompleted: true),
            .init(title: "Медитация",            isCompleted: true),
            .init(title: "Вечерняя пробежка",    isCompleted: false),
            .init(title: "Написать дневник",     isCompleted: true),
            .init(title: "Витамины",             isCompleted: false)
        ]),
    ]


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

    weak var presentingViewController: UIViewController?


    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
        buildRows()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    private func setupLayout() {
        addSubview(scrollView)
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
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    private func buildRows() {
        for (i, day) in days.enumerated() {
            let row = makeRow(day, index: i)
            stack.addArrangedSubview(row)
        }
    }

    private func makeRow(_ day: DaySummary, index: Int) -> UIView {
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
        dateLabel.text = day.date
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
        let detail = TaskDayDetailViewController(date: day.date, tasks: day.tasks)
        if let presenter = detail.sheetPresentationController {
            let height = CGFloat(min(day.tasks.count, 6)) * 62 + 100
            presenter.detents = [.custom { _ in height }]
            presenter.prefersGrabberVisible = false
            presenter.preferredCornerRadius = 24
        }
        presentingViewController?.present(detail, animated: true)
    }
}
