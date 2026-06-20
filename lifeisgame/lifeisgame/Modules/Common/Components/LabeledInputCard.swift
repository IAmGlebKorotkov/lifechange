//
//  LabeledInputCard.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class LabeledInputCard: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let fieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(title: String, field: UIView) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title

        addSubview(titleLabel)
        addSubview(fieldContainer)
        fieldContainer.addSubview(field)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            fieldContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            fieldContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            fieldContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            fieldContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            fieldContainer.heightAnchor.constraint(equalToConstant: 52),

            field.topAnchor.constraint(equalTo: fieldContainer.topAnchor),
            field.bottomAnchor.constraint(equalTo: fieldContainer.bottomAnchor),
            field.leadingAnchor.constraint(equalTo: fieldContainer.leadingAnchor, constant: 16),
            field.trailingAnchor.constraint(equalTo: fieldContainer.trailingAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
