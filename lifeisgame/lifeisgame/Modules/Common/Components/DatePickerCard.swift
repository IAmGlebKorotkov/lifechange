//
//  DatePickerCard.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class DatePickerCard: CardContainerView {

    private weak var picker: UIDatePicker?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.main
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.78
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(title: String, picker: UIDatePicker, iconSystemName: String = "calendar") {
        self.picker = picker
        super.init(cornerRadius: 14)
        titleLabel.text = title
        setupLayout(picker: picker, iconSystemName: iconSystemName)
        updateValueLabel()
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateValueLabel()
    }

    private func setupLayout(picker: UIDatePicker, iconSystemName: String) {
        let iconBadge = IconBadgeView(systemName: iconSystemName, pointSize: 18, badgeSize: 40, iconSize: 20)
        picker.alpha = 0.02

        addSubview(iconBadge)
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(picker)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 64),

            iconBadge.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconBadge.centerYAnchor.constraint(equalTo: centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: iconBadge.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -12),

            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 132),

            picker.topAnchor.constraint(equalTo: topAnchor),
            picker.leadingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: trailingAnchor),
            picker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func dateChanged() {
        updateValueLabel()
    }

    private func updateValueLabel() {
        guard let picker else { return }
        if picker.datePickerMode == .dateAndTime {
            valueLabel.text = DateFormatter.appDateTimeString(from: picker.date)
        } else {
            valueLabel.text = DateFormatter.appDateString(from: picker.date)
        }
    }
}
