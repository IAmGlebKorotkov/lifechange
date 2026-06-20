//
//  TaskStatsDayRowView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class TaskStatsDayRowView: UIControl {

    let day: TaskStatsDaySummary

    init(day: TaskStatsDaySummary) {
        self.day = day
        super.init(frame: .zero)
        setupLayout()
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        enablePressScale(to: 0.97)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        backgroundColor = .white
        layer.cornerRadius = 14
        translatesAutoresizingMaskIntoConstraints = false

        let iconBg = UIView()
        iconBg.backgroundColor = UIColor.main.withAlphaComponent(0.1)
        iconBg.layer.cornerRadius = 22
        iconBg.isUserInteractionEnabled = false
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let iconView = UIImageView(image: UIImage(named: "Calendar") ??
                                   UIImage(systemName: "calendar", withConfiguration: config))
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

        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: chevronConfig))
        chevron.tintColor = .systemGray3
        chevron.isUserInteractionEnabled = false
        chevron.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconBg)
        addSubview(textStack)
        addSubview(progressBg)
        addSubview(chevron)

        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            iconBg.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 44),
            iconBg.heightAnchor.constraint(equalToConstant: 44),

            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            textStack.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -6),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -12),

            progressBg.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
            progressBg.topAnchor.constraint(equalTo: textStack.bottomAnchor, constant: 6),
            progressBg.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -12),
            progressBg.heightAnchor.constraint(equalToConstant: 6),

            progressFill.leadingAnchor.constraint(equalTo: progressBg.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressBg.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressBg.bottomAnchor),
            progressFill.widthAnchor.constraint(equalTo: progressBg.widthAnchor, multiplier: ratio),

            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),

            heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    @objc private func touchUpInside() {
        sendActions(for: .primaryActionTriggered)
    }
}
