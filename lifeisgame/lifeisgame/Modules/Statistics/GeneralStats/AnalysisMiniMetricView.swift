//
//  AnalysisMiniMetricView.swift
//  lifeisgame
//

import UIKit

final class AnalysisMiniMetricView: UIView {

    private let ringView: ProgressRingView

    private let valueLabel: UILabel = {
        let label = UILabel()
        let baseFont = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.font = UIFontMetrics(forTextStyle: .callout).scaledFont(
            for: baseFont,
            maximumPointSize: 20
        )
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let metricTitle: String

    init(title: String, color: UIColor) {
        metricTitle = title
        ringView = ProgressRingView(
            size: 52,
            lineWidth: 4,
            trackColor: UIColor(rgb: 0x3C3C43, alpha: 0.1),
            progressColor: color
        )
        super.init(frame: .zero)
        setupLayout()
        titleLabel.text = title
        configure(value: nil, status: "считаем", color: color, animated: false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(
        value: Int?,
        status: String,
        color: UIColor,
        animated: Bool = true
    ) {
        let clampedValue = value.map { max(0, min(100, $0)) }
        valueLabel.text = clampedValue.map(String.init) ?? "--"
        statusLabel.text = status
        ringView.setProgressColor(color)
        ringView.setProgress(
            clampedValue.map { CGFloat($0) / 100 } ?? 0,
            animated: animated
        )

        isAccessibilityElement = true
        accessibilityLabel = metricTitle.capitalized
        accessibilityValue = clampedValue.map { "\($0) из 100, \(status)" } ?? status
    }

    private func setupLayout() {
        ringView.addSubview(valueLabel)

        let labelsStack = UIStackView(arrangedSubviews: [titleLabel, statusLabel])
        labelsStack.axis = .vertical
        labelsStack.alignment = .center
        labelsStack.spacing = 0

        let stack = UIStackView(arrangedSubviews: [ringView, labelsStack])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: ringView.centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: ringView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: ringView.leadingAnchor, constant: 6),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: ringView.trailingAnchor, constant: -6),

            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
