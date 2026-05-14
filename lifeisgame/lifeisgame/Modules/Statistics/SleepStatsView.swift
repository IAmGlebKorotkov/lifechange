//
//  SleepStatsView.swift
//  lifeisgame
//
//  Created by Codex on 08.05.2026.
//

import UIKit

final class SleepStatsView: UIView {

    private var entries: [SleepDiaryEntry] = []

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter
    }()

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

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


    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
        buildRows()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    func configure(entries: [SleepDiaryEntry]) {
        self.entries = entries
        buildRows()
    }

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
        stack.arrangedSubviews.forEach { view in
            stack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard !entries.isEmpty else {
            stack.addArrangedSubview(makeEmptyState())
            return
        }

        for entry in entries {
            stack.addArrangedSubview(makeRow(entry))
        }
    }

    private func makeRow(_ entry: SleepDiaryEntry) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.translatesAutoresizingMaskIntoConstraints = false

        let iconBg = UIView()
        iconBg.backgroundColor = UIColor.main.withAlphaComponent(0.1)
        iconBg.layer.cornerRadius = 22
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: "moon.zzz.fill", withConfiguration: cfg))
        iconView.tintColor = UIColor.main
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconView)

        let dateLabel = UILabel()
        dateLabel.text = dateFormatter.string(from: entry.dayDate)
        dateLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        dateLabel.textColor = .label

        let timeLabel = UILabel()
        timeLabel.text = "\(timeFormatter.string(from: entry.bedtime)) - \(timeFormatter.string(from: entry.wakeTime))"
        timeLabel.font = .systemFont(ofSize: 12, weight: .regular)
        timeLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [dateLabel, timeLabel])
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let durationLabel = UILabel()
        durationLabel.text = durationText(entry.durationMinutes)
        durationLabel.font = .systemFont(ofSize: 14, weight: .bold)
        durationLabel.textColor = UIColor.main
        durationLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconBg)
        card.addSubview(textStack)
        card.addSubview(durationLabel)

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
            textStack.topAnchor.constraint(greaterThanOrEqualTo: card.topAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: durationLabel.leadingAnchor, constant: -12),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12),

            durationLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            durationLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            card.heightAnchor.constraint(equalToConstant: 68)
        ])

        return card
    }

    private func makeEmptyState() -> UIView {
        let label = UILabel()
        label.text = "Сон пока не добавлен"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.backgroundColor = .white
        label.layer.cornerRadius = 14
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 64).isActive = true
        return label
    }

    private func durationText(_ minutes: Int) -> String {
        "\(minutes / 60)ч \(minutes % 60)м"
    }
}
