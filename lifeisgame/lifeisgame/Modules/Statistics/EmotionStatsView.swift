//
//  EmotionStatsView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class EmotionStatsView: UIView {


    private var entries: [EmotionDiaryEntry] = []
    var onVerticalScroll: ((CGFloat) -> Void)?

    var verticalScrollOffset: CGFloat {
        max(0, scrollView.contentOffset.y + scrollView.adjustedContentInset.top)
    }


    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.clipsToBounds = true
        sv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
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
        scrollView.delegate = self
        buildContent()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    func configure(entries: [EmotionDiaryEntry]) {
        self.entries = entries
        buildContent()
    }

    func applyHeaderCompensation(_ offset: CGFloat) {
        stack.transform = CGAffineTransform(translationX: 0, y: offset)
    }


    private func setupLayout() {
        addSubview(scrollView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }


    private func buildContent() {
        stack.arrangedSubviews.forEach { view in
            stack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let recentEntries = last30DaysEntries()

        guard !recentEntries.isEmpty else {
            stack.addArrangedSubview(makeEmptyState(text: "Эмоции пока не добавлены"))
            return
        }

        if let dominant = dominantCard(for: recentEntries) {
            stack.addArrangedSubview(dominant)
        }

        stack.addArrangedSubview(makeSectionLabel("Распределение"))
        stack.setCustomSpacing(10, after: stack.arrangedSubviews.last ?? UIView())
        stack.addArrangedSubview(makeDistributionCard(for: recentEntries))

        stack.addArrangedSubview(makeSectionLabel("Последние 7 дней"))
        stack.setCustomSpacing(10, after: stack.arrangedSubviews.last ?? UIView())
        stack.addArrangedSubview(makeWeekCard())

        stack.addArrangedSubview(makeSectionLabel("Записи"))
        stack.setCustomSpacing(10, after: stack.arrangedSubviews.last ?? UIView())
        for entry in entries.sorted(by: { $0.createdAt > $1.createdAt }).prefix(8) {
            stack.addArrangedSubview(makeRow(entry))
        }
    }

    private func last30DaysEntries() -> [EmotionDiaryEntry] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return entries.filter { $0.dayDate >= cutoff }
    }

    private func counts(for entries: [EmotionDiaryEntry]) -> [(style: EmotionStyle, total: Int)] {
        EmotionStyle.all
            .map { style in
                (style: style, total: entries.filter { $0.emotionName == style.name }.count)
            }
            .filter { $0.total > 0 }
            .sorted { $0.total > $1.total }
    }


    private func dominantCard(for recentEntries: [EmotionDiaryEntry]) -> UIView? {
        guard let top = counts(for: recentEntries).first else { return nil }

        let percent = Int((Double(top.total) / Double(recentEntries.count) * 100).rounded())
        let matching = recentEntries.filter { $0.emotionName == top.style.name }
        let avgIntensity = Double(matching.reduce(0) { $0 + $1.intensity }) / Double(max(1, matching.count))

        let card = makeCard(cornerRadius: 22)

        let tile = UIView()
        tile.backgroundColor = top.style.tileColor
        tile.layer.cornerRadius = 20
        tile.translatesAutoresizingMaskIntoConstraints = false

        let cfg = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
        let icon = UIImageView(image: UIImage(systemName: top.style.sfSymbol, withConfiguration: cfg))
        icon.tintColor = top.style.tintColor
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(icon)

        let captionLabel = UILabel()
        captionLabel.text = "Чаще всего"
        captionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        captionLabel.textColor = .textSecondaryToken

        let nameLabel = UILabel()
        nameLabel.text = top.style.name
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = .label

        let detailLabel = UILabel()
        detailLabel.text = "\(percent)% записей · средне \(String(format: "%.1f", avgIntensity))"
        detailLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        detailLabel.textColor = top.style.tintColor

        let textStack = UIStackView(arrangedSubviews: [captionLabel, nameLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(tile)
        card.addSubview(textStack)

        NSLayoutConstraint.activate([
            tile.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            tile.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            tile.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
            tile.widthAnchor.constraint(equalToConstant: 64),
            tile.heightAnchor.constraint(equalToConstant: 64),

            icon.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: tile.centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: tile.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -18),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        return card
    }


    private func makeDistributionCard(for recentEntries: [EmotionDiaryEntry]) -> UIView {
        let card = makeCard(cornerRadius: 20)

        let rowsStack = UIStackView()
        rowsStack.axis = .vertical
        rowsStack.spacing = 14
        rowsStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(rowsStack)

        let allCounts = counts(for: recentEntries)
        let maxCount = allCounts.first?.total ?? 1

        for item in allCounts {
            let percent = Int((Double(item.total) / Double(recentEntries.count) * 100).rounded())
            let fraction = CGFloat(item.total) / CGFloat(maxCount)
            rowsStack.addArrangedSubview(
                makeDistributionRow(style: item.style, fraction: fraction, percent: percent)
            )
        }

        NSLayoutConstraint.activate([
            rowsStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            rowsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            rowsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            rowsStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    private func makeDistributionRow(style: EmotionStyle, fraction: CGFloat, percent: Int) -> UIView {
        let dot = UIView()
        dot.backgroundColor = style.tintColor
        dot.layer.cornerRadius = 4.5
        dot.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = style.name
        nameLabel.font = .systemFont(ofSize: 14, weight: .regular)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let track = UIView()
        track.backgroundColor = UIColor(rgb: 0x787880, alpha: 0.14)
        track.layer.cornerRadius = 4
        track.clipsToBounds = true
        track.translatesAutoresizingMaskIntoConstraints = false

        let fill = UIView()
        fill.backgroundColor = style.tintColor
        fill.layer.cornerRadius = 4
        fill.translatesAutoresizingMaskIntoConstraints = false
        track.addSubview(fill)

        let percentLabel = UILabel()
        percentLabel.text = "\(percent)%"
        percentLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        percentLabel.textColor = UIColor(rgb: 0x3C3C43, alpha: 0.7)
        percentLabel.textAlignment = .right
        percentLabel.translatesAutoresizingMaskIntoConstraints = false

        let row = UIView()
        row.addSubview(dot)
        row.addSubview(nameLabel)
        row.addSubview(track)
        row.addSubview(percentLabel)

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 20),

            dot.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 9),
            dot.heightAnchor.constraint(equalToConstant: 9),

            nameLabel.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 11),
            nameLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: 68),

            track.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 11),
            track.trailingAnchor.constraint(equalTo: percentLabel.leadingAnchor, constant: -11),
            track.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            track.heightAnchor.constraint(equalToConstant: 8),

            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: max(0.02, min(1, fraction))),

            percentLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            percentLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            percentLabel.widthAnchor.constraint(equalToConstant: 38)
        ])

        return row
    }


    private func makeWeekCard() -> UIView {
        let card = makeCard(cornerRadius: 20)

        let daysStack = UIStackView()
        daysStack.axis = .horizontal
        daysStack.distribution = .fillEqually
        daysStack.spacing = 10
        daysStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(daysStack)

        let calendar = Calendar.current
        let weekdayNames = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]

        for offset in stride(from: 6, through: 0, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let dayEntries = entries.filter { calendar.isDate($0.dayDate, inSameDayAs: day) }
            let weekdayIndex = calendar.component(.weekday, from: day) - 1

            daysStack.addArrangedSubview(
                makeDayColumn(segments: daySegments(for: dayEntries), title: weekdayNames[weekdayIndex])
            )
        }

        NSLayoutConstraint.activate([
            daysStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            daysStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            daysStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            daysStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        return card
    }

    /// Доли эмоций за день: вес = сумма интенсивностей записей этой эмоции.
    private func daySegments(for dayEntries: [EmotionDiaryEntry]) -> [(color: UIColor, fraction: CGFloat)] {
        let weights = EmotionStyle.all.compactMap { style -> (UIColor, Int)? in
            let weight = dayEntries
                .filter { $0.emotionName == style.name }
                .reduce(0) { $0 + max(1, $1.intensity) }
            return weight > 0 ? (style.tintColor, weight) : nil
        }

        let totalWeight = weights.reduce(0) { $0 + $1.1 }
        guard totalWeight > 0 else { return [] }

        return weights
            .sorted { $0.1 > $1.1 }
            .map { (color: $0.0, fraction: CGFloat($0.1) / CGFloat(totalWeight)) }
    }

    private func makeDayColumn(segments: [(color: UIColor, fraction: CGFloat)], title: String) -> UIView {
        let bar = UIView()
        bar.layer.cornerRadius = 9
        bar.clipsToBounds = true
        bar.translatesAutoresizingMaskIntoConstraints = false

        if segments.isEmpty {
            bar.backgroundColor = UIColor(rgb: 0x787880, alpha: 0.14)
        } else {
            let segmentsStack = UIStackView()
            segmentsStack.axis = .vertical
            segmentsStack.spacing = 0
            segmentsStack.translatesAutoresizingMaskIntoConstraints = false
            bar.addSubview(segmentsStack)

            NSLayoutConstraint.activate([
                segmentsStack.topAnchor.constraint(equalTo: bar.topAnchor),
                segmentsStack.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
                segmentsStack.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
                segmentsStack.bottomAnchor.constraint(equalTo: bar.bottomAnchor)
            ])

            for (index, segment) in segments.enumerated() {
                let view = UIView()
                view.backgroundColor = segment.color
                segmentsStack.addArrangedSubview(view)

                // Последний сегмент добирает остаток высоты (без ошибок округления).
                if index < segments.count - 1 {
                    view.heightAnchor.constraint(
                        equalTo: bar.heightAnchor,
                        multiplier: segment.fraction
                    ).isActive = true
                }
            }
        }

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = UIColor(rgb: 0x3C3C43, alpha: 0.5)
        label.textAlignment = .center

        let column = UIStackView(arrangedSubviews: [bar, label])
        column.axis = .vertical
        column.spacing = 7
        column.alignment = .fill

        bar.heightAnchor.constraint(equalToConstant: 84).isActive = true

        return column
    }


    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor(rgb: 0x3C3C43, alpha: 0.5)
        let attributed = NSAttributedString(
            string: text.uppercased(),
            attributes: [.kern: 0.6]
        )
        label.attributedText = attributed
        return label
    }

    private func makeCard(cornerRadius: CGFloat) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = cornerRadius
        card.applyCardShadow(strength: 0.8)
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }

    private func makeRow(_ entry: EmotionDiaryEntry) -> UIView {
        let reason = entry.reason?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return IconInfoRowView(
            iconSystemName: entry.sfSymbol,
            title: entry.emotionName,
            subtitle: reason.isEmpty ? "Причина не указана" : reason,
            footnote: DateFormatter.appDateString(from: entry.dayDate),
            trailingText: "\(entry.intensity)/10"
        )
    }

    private func makeEmptyState(text: String) -> UIView {
        let label = UILabel()
        label.text = text
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
}

extension EmotionStatsView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onVerticalScroll?(verticalScrollOffset)
    }
}
