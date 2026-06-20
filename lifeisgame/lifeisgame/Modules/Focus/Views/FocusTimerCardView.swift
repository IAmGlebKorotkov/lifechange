//
//  FocusTimerCardView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class FocusTimerCardView: CardContainerView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Таймер фокуса"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let taskLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let countdownLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor.main
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(cornerRadius: CGFloat = 16) {
        super.init(cornerRadius: cornerRadius)
        setupLayout()
        configure(taskTitle: "", countdown: "00:00")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(taskTitle: String, countdown: String) {
        taskLabel.text = taskTitle
        countdownLabel.text = countdown
    }

    func setCountdown(_ countdown: String) {
        countdownLabel.text = countdown
    }

    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(taskLabel)
        addSubview(countdownLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: countdownLabel.leadingAnchor, constant: -12),

            taskLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            taskLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            taskLabel.trailingAnchor.constraint(equalTo: countdownLabel.leadingAnchor, constant: -12),
            taskLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -18),

            countdownLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            countdownLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            countdownLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 118),

            heightAnchor.constraint(greaterThanOrEqualToConstant: 112)
        ])
    }
}
