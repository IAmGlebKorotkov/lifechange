//
//  EmotionStatsView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class EmotionStatsView: UIView {


    private struct EmotionEntry {
        let date: String
        let emotionName: String
        let sfSymbol: String
        let intensity: Int
    }

    private let entries: [EmotionEntry] = [
        EmotionEntry(date: "30 марта",   emotionName: "Радость",    sfSymbol: "face.smiling",           intensity: 8),
        EmotionEntry(date: "29 марта",   emotionName: "Спокойствие",sfSymbol: "leaf",                   intensity: 5),
        EmotionEntry(date: "28 марта",   emotionName: "Тревога",    sfSymbol: "exclamationmark.circle",  intensity: 7),
        EmotionEntry(date: "27 марта",   emotionName: "Грусть",     sfSymbol: "cloud.rain",              intensity: 6),
        EmotionEntry(date: "26 марта",   emotionName: "Злость",     sfSymbol: "flame",                   intensity: 9),
        EmotionEntry(date: "25 марта",   emotionName: "Радость",    sfSymbol: "face.smiling",           intensity: 7),
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
        for entry in entries {
            stack.addArrangedSubview(makeRow(entry))
        }
    }

    private func makeRow(_ entry: EmotionEntry) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 14
        card.translatesAutoresizingMaskIntoConstraints = false

        let iconBg = UIView()
        iconBg.backgroundColor = UIColor.main.withAlphaComponent(0.1)
        iconBg.layer.cornerRadius = 22
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: entry.sfSymbol, withConfiguration: cfg))
        iconView.tintColor = UIColor.main
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconView)

        let nameLabel = UILabel()
        nameLabel.text = entry.emotionName
        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = .label

        let dateLabel = UILabel()
        dateLabel.text = entry.date
        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [nameLabel, dateLabel])
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let intensityLabel = UILabel()
        intensityLabel.text = "\(entry.intensity)/10"
        intensityLabel.font = .systemFont(ofSize: 14, weight: .bold)
        intensityLabel.textColor = UIColor.main
        intensityLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconBg)
        card.addSubview(textStack)
        card.addSubview(intensityLabel)

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
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            intensityLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            intensityLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            card.heightAnchor.constraint(equalToConstant: 68)
        ])

        return card
    }
}
