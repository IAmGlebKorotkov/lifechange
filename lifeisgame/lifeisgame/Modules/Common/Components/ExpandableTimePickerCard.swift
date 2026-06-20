//
//  ExpandableTimePickerCard.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class ExpandableTimePickerCard: CardContainerView {

    let picker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .countDownTimer
        picker.countDownDuration = 3600
        picker.locale = Locale(identifier: "ru_RU")
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    var onValueChanged: (() -> Void)?

    var countDownDuration: TimeInterval {
        get { picker.countDownDuration }
        set {
            picker.countDownDuration = newValue
            updateValueLabel()
        }
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let chevronView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down", withConfiguration: config))
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let pickerContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var pickerHeightConstraint: NSLayoutConstraint!
    private var isExpanded = false

    init(title: String = "Время", iconSystemName: String = "clock") {
        super.init(cornerRadius: 14)
        clipsToBounds = true
        titleLabel.text = title
        setupLayout(iconSystemName: iconSystemName)
        updateValueLabel()
        picker.addTarget(self, action: #selector(pickerChanged), for: .valueChanged)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped)))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout(iconSystemName: String) {
        let iconBadge = IconBadgeView(systemName: iconSystemName, pointSize: 18, badgeSize: 40, iconSize: 20)

        pickerContainer.addSubview(picker)
        addSubview(iconBadge)
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(chevronView)
        addSubview(pickerContainer)

        pickerHeightConstraint = pickerContainer.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            iconBadge.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconBadge.topAnchor.constraint(equalTo: topAnchor, constant: 12),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: iconBadge.trailingAnchor, constant: 12),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronView.leadingAnchor, constant: -12),

            chevronView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chevronView.centerYAnchor.constraint(equalTo: iconBadge.centerYAnchor),

            pickerContainer.topAnchor.constraint(equalTo: iconBadge.bottomAnchor, constant: 8),
            pickerContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            pickerContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            pickerContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            pickerHeightConstraint,

            picker.topAnchor.constraint(equalTo: pickerContainer.topAnchor),
            picker.leadingAnchor.constraint(equalTo: pickerContainer.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: pickerContainer.trailingAnchor)
        ])
    }

    @objc private func pickerChanged() {
        updateValueLabel()
        onValueChanged?()
    }

    @objc private func cardTapped() {
        isExpanded.toggle()
        pickerHeightConstraint.constant = isExpanded ? 200 : 0

        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            self.chevronView.transform = self.isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
            self.superview?.layoutIfNeeded()
        }
    }

    private func updateValueLabel() {
        let total = Int(picker.countDownDuration)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        valueLabel.text = "\(hours) часов \(minutes) минут"
    }
}
