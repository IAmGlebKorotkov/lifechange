//
//  SleepStatsView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 08.05.2026.
//

import UIKit

final class SleepStatsView: UIView {

    private var entries: [SleepDiaryEntry] = []

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
        IconInfoRowView(
            iconSystemName: "moon.zzz.fill",
            title: DateFormatter.appDateString(from: entry.dayDate),
            subtitle: "\(timeFormatter.string(from: entry.bedtime)) - \(timeFormatter.string(from: entry.wakeTime))",
            trailingText: durationText(entry.durationMinutes)
        )
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
