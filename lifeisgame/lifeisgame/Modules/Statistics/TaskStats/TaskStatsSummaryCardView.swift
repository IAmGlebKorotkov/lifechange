//
//  TaskStatsSummaryCardView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class TaskStatsSummaryCardView: CardContainerView {

    init(completed: Int, total: Int, dayCount: Int) {
        super.init(cornerRadius: 14)
        setupLayout(completed: completed, total: total, dayCount: dayCount)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout(completed: Int, total: Int, dayCount: Int) {
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
        subtitleLabel.text = "Дней с задачами: \(dayCount)"
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

        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(subtitleLabel)
        addSubview(progressBg)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

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
            progressBg.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            progressFill.leadingAnchor.constraint(equalTo: progressBg.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressBg.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressBg.bottomAnchor),
            progressFill.widthAnchor.constraint(equalTo: progressBg.widthAnchor, multiplier: ratio)
        ])
    }
}
