//
//  AddTaskUIHelpers.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 31.03.2026.
//

import UIKit

func styleCard(_ card: UIView) {
    card.backgroundColor = .white
    card.layer.cornerRadius = 14
    card.layer.shadowColor = UIColor.black.cgColor
    card.layer.shadowOpacity = 0.06
    card.layer.shadowOffset = CGSize(width: 0, height: 2)
    card.layer.shadowRadius = 8
    card.translatesAutoresizingMaskIntoConstraints = false
}

func makeTaskSectionHeader(_ text: String) -> UILabel {
    let l = UILabel()
    l.text = text
    l.font = .systemFont(ofSize: 12, weight: .medium)
    l.textColor = .secondaryLabel
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
}

func makeFieldBlock(header: UILabel, field: UIView) -> UIView {
    let card = UIView()
    styleCard(card)
    card.addSubview(header)
    card.addSubview(field)

    NSLayoutConstraint.activate([
        header.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
        header.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
        header.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

        field.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 4),
        field.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
        field.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        field.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10)
    ])

    return card
}

func makeDateCard(icon iconName: String, title: String, picker: UIDatePicker) -> UIView {
    let card = UIView()
    styleCard(card)

    let iconBg = UIView()
    iconBg.backgroundColor = UIColor.main.withAlphaComponent(0.1)
    iconBg.layer.cornerRadius = 20
    iconBg.translatesAutoresizingMaskIntoConstraints = false

    let iconView = UIImageView()
    if let asset = UIImage(named: iconName) {
        iconView.image = asset.withRenderingMode(.alwaysTemplate)
    } else {
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        iconView.image = UIImage(systemName: "calendar", withConfiguration: cfg)
    }
    iconView.tintColor = UIColor.main
    iconView.contentMode = .scaleAspectFit
    iconView.translatesAutoresizingMaskIntoConstraints = false

    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
    titleLabel.textColor = .label
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    card.addSubview(iconBg)
    iconBg.addSubview(iconView)
    card.addSubview(titleLabel)
    card.addSubview(picker)

    NSLayoutConstraint.activate([
        iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
        iconBg.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        iconBg.widthAnchor.constraint(equalToConstant: 40),
        iconBg.heightAnchor.constraint(equalToConstant: 40),

        iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
        iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
        iconView.widthAnchor.constraint(equalToConstant: 20),
        iconView.heightAnchor.constraint(equalToConstant: 20),

        titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),
        titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),

        picker.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        picker.centerYAnchor.constraint(equalTo: card.centerYAnchor),

        card.heightAnchor.constraint(equalToConstant: 64)
    ])

    return card
}

func makeSliderBlock(header: UILabel, valueLabel: UILabel, slider: UISlider) -> UIView {
    let card = UIView()
    styleCard(card)
    card.addSubview(header)
    card.addSubview(valueLabel)
    card.addSubview(slider)

    NSLayoutConstraint.activate([
        header.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
        header.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

        valueLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
        valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

        slider.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
        slider.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
        slider.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        slider.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
    ])

    return card
}
