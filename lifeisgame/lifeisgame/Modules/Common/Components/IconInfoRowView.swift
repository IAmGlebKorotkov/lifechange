//
//  IconInfoRowView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class IconInfoRowView: UIView {

    private let iconBadgeView: IconBadgeView

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private let footnoteLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .tertiaryLabel
        return label
    }()

    private let trailingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor.main
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var textTrailingConstraint: NSLayoutConstraint?
    private var trailingLabelWidthConstraint: NSLayoutConstraint?

    init(
        iconSystemName: String,
        title: String,
        subtitle: String?,
        footnote: String? = nil,
        trailingText: String? = nil
    ) {
        iconBadgeView = IconBadgeView(systemName: iconSystemName)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 14

        titleLabel.text = title
        subtitleLabel.text = subtitle
        footnoteLabel.text = footnote
        trailingLabel.text = trailingText

        subtitleLabel.isHidden = subtitle == nil
        footnoteLabel.isHidden = footnote == nil
        trailingLabel.isHidden = trailingText == nil

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, footnoteLabel])
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconBadgeView)
        addSubview(textStack)
        addSubview(trailingLabel)

        textTrailingConstraint = trailingText == nil
            ? textStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
            : textStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingLabel.leadingAnchor, constant: -12)
        trailingLabelWidthConstraint = trailingLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 44)
        trailingLabelWidthConstraint?.isActive = trailingText != nil

        NSLayoutConstraint.activate([
            iconBadgeView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            iconBadgeView.centerYAnchor.constraint(equalTo: centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: iconBadgeView.trailingAnchor, constant: 12),
            textStack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12),
            textTrailingConstraint!,

            trailingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            trailingLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            heightAnchor.constraint(greaterThanOrEqualToConstant: 68)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
