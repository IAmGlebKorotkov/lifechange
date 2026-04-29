//
//  WeeklyStatCardView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

enum WeeklyStatCardStyle {
    case taskCount(title: String, completed: Int, total: Int)
    case percentage(title: String, value: Double)
}

final class WeeklyStatCardView: UIView {


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .secondaryLabel
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let progressTrack: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray5
        v.layer.cornerRadius = 4
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let progressFill = UIView()


    private var fillFraction: CGFloat = 0


    init(style: WeeklyStatCardStyle) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupAppearance()
        setupLayout()
        apply(style: style)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    private func setupAppearance() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
    }


    private func setupLayout() {
        progressFill.backgroundColor = UIColor.main
        progressFill.layer.cornerRadius = 4
        progressTrack.addSubview(progressFill)

        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(progressTrack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            progressTrack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            progressTrack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            progressTrack.heightAnchor.constraint(equalToConstant: 8),

            valueLabel.leadingAnchor.constraint(equalTo: progressTrack.trailingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: progressTrack.centerYAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }


    private func apply(style: WeeklyStatCardStyle) {
        switch style {
        case .taskCount(let title, let completed, let total):
            titleLabel.text = title
            valueLabel.text = "\(completed) из \(total)"
            fillFraction = total > 0 ? CGFloat(completed) / CGFloat(total) : 0
        case .percentage(let title, let value):
            titleLabel.text = title
            valueLabel.text = "\(Int(value * 100))%"
            fillFraction = CGFloat(max(0, min(1, value)))
        }
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        progressFill.frame = CGRect(
            x: 0, y: 0,
            width: progressTrack.bounds.width * fillFraction,
            height: progressTrack.bounds.height
        )
    }
}
