//
//  DiaryIntensityView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class DiaryIntensityView: UIView {

    var value: Int { Int(slider.value.rounded()) }


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Интенсивность"
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = UIColor.main
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.text = "5"
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = UIColor.main
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let slider: UISlider = {
        let s = UISlider()
        s.minimumValue = 1
        s.maximumValue = 10
        s.value = 5
        s.minimumTrackTintColor = UIColor.main
        s.maximumTrackTintColor = UIColor.main.withAlphaComponent(0.15)
        s.thumbTintColor = UIColor.main
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let minLabel: UILabel = {
        let l = UILabel()
        l.text = "1"
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let maxLabel: UILabel = {
        let l = UILabel()
        l.text = "10"
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 14

        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(slider)
        addSubview(minLabel)
        addSubview(maxLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            valueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            slider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            minLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 6),
            minLabel.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
            minLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),

            maxLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 6),
            maxLabel.trailingAnchor.constraint(equalTo: slider.trailingAnchor),
            maxLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])

        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func reset() {
        slider.setValue(5, animated: false)
        valueLabel.text = "5"
    }


    @objc private func sliderChanged() {
        valueLabel.text = "\(Int(slider.value.rounded()))"
    }
}
