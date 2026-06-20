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
        for day in days {
            let row = TaskStatsDayRowView(day: day)
            row.addTarget(self, action: #selector(rowTapped(_:)), for: .primaryActionTriggered)
            stack.addArrangedSubview(row)
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
        return TaskStatsSummaryCardView(completed: completed, total: total, dayCount: days.count)
    }

    @objc private func rowTapped(_ sender: UIControl) {
        guard let sender = sender as? TaskStatsDayRowView else { return }
        let day = sender.day
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
