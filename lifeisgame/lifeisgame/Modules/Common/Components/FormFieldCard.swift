//
//  FormFieldCard.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class FormFieldCard: CardContainerView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(title: String, field: UIView) {
        super.init(cornerRadius: 14)
        titleLabel.text = title
        setupLayout(field: field)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout(field: UIView) {
        addSubview(titleLabel)
        addSubview(field)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            field.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            field.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            field.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            field.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}
