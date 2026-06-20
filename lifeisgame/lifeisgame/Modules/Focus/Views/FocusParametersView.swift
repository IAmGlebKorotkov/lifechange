//
//  FocusParametersView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class FocusParametersView: CardContainerView {

    var onPlaylistTapped: (() -> Void)?

    var playlistButtonSourceView: UIView { playlistButton }
    var playlistButtonSourceRect: CGRect { playlistButton.bounds }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Параметры фокуса"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var playlistButton = makeOptionButton(title: "Без музыки")

    override init(cornerRadius: CGFloat = 16) {
        super.init(cornerRadius: cornerRadius)
        setupLayout()
        playlistButton.addTarget(self, action: #selector(playlistTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setPlaylistTitle(_ title: String) {
        playlistButton.setTitle(title, for: .normal)
    }

    func setPlaylistSelectionEnabled(_ isEnabled: Bool) {
        playlistButton.isEnabled = isEnabled
        playlistButton.alpha = isEnabled ? 1.0 : 0.65
    }

    private func setupLayout() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(stack)

        stack.addArrangedSubview(makeOptionBlock(
            title: "Выбор музыки",
            subtitle: "Плейлист",
            button: playlistButton
        ))

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    private func makeOptionBlock(title: String, subtitle: String, button: UIButton) -> UIView {
        let block = UIView()
        block.backgroundColor = UIColor.main.withAlphaComponent(0.06)
        block.layer.cornerRadius = 14
        block.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        block.addSubview(titleLabel)
        block.addSubview(subtitleLabel)
        block.addSubview(button)

        NSLayoutConstraint.activate([
            block.heightAnchor.constraint(greaterThanOrEqualToConstant: 76),

            titleLabel.topAnchor.constraint(equalTo: block.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: block.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: button.leadingAnchor, constant: -12),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: button.leadingAnchor, constant: -12),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: block.bottomAnchor, constant: -14),

            button.centerYAnchor.constraint(equalTo: block.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: block.trailingAnchor, constant: -14),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 108),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])

        return block
    }

    private func makeOptionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.tintColor = UIColor.main
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    @objc private func playlistTapped() {
        onPlaylistTapped?()
    }
}
