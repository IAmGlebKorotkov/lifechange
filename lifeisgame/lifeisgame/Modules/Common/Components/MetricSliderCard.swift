//
//  MetricSliderCard.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class MetricSliderCard: CardContainerView {

    var onValueChanged: ((Int) -> Void)?

    var value: Int {
        get { Int(roundf(slider.value)) }
        set {
            let boundedValue = min(max(newValue, minimumValue), maximumValue)
            slider.value = Float(boundedValue)
            valueLabel.text = "\(boundedValue)"
        }
    }

    private let minimumValue: Int
    private let maximumValue: Int

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.main
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let slider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = UIColor.main
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    init(title: String, value: Int = 5, minimumValue: Int = 1, maximumValue: Int = 10) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        super.init(cornerRadius: 14)
        titleLabel.text = title
        slider.minimumValue = Float(minimumValue)
        slider.maximumValue = Float(maximumValue)
        setupLayout()
        self.value = value
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(slider)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            valueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            slider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    @objc private func sliderChanged() {
        value = Int(roundf(slider.value))
        onValueChanged?(value)
    }
}
