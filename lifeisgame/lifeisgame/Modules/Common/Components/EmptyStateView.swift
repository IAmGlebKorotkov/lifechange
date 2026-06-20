//
//  EmptyStateView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class EmptyStateView: UIStackView {

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor.main.withAlphaComponent(0.65)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(iconSystemName: String? = nil, title: String, subtitle: String? = nil) {
        super.init(frame: .zero)
        axis = .vertical
        alignment = .center
        spacing = 12
        translatesAutoresizingMaskIntoConstraints = false

        addArrangedSubview(iconView)
        addArrangedSubview(titleLabel)
        addArrangedSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48)
        ])

        configure(title: title, subtitle: subtitle, iconSystemName: iconSystemName)
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, subtitle: String? = nil, iconSystemName: String? = nil) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil

        if let iconSystemName {
            let config = UIImage.SymbolConfiguration(pointSize: 38, weight: .regular)
            iconView.image = UIImage(systemName: iconSystemName, withConfiguration: config)
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }
    }
}
