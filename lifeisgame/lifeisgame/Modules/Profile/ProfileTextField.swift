//
//  ProfileTextField.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class ProfileTextField: UIView {


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .secondaryLabel
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()


    init(title: String, value: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        valueLabel.text = value

        backgroundColor = .white
        layer.cornerRadius = 14

        addSubview(titleLabel)
        addSubview(divider)
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 72),

            divider.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            divider.centerYAnchor.constraint(equalTo: centerYAnchor),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 22),

            valueLabel.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 12),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
