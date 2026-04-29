//
//  DiaryPickerView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class DiaryPickerView: UIView {


    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let sectionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .systemGray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let selectionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let chevronView: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let iv = UIImageView(image: UIImage(systemName: "chevron.down", withConfiguration: cfg))
        iv.tintColor = .label
        iv.contentMode = .scaleAspectFit
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let menuButton: UIButton = {
        let b = UIButton(type: .custom)
        b.showsMenuAsPrimaryAction = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()


    init(sectionTitle: String) {
        super.init(frame: .zero)
        sectionLabel.text = sectionTitle
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 14
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    func update(icon: UIImage?, selectionText: String, menu: UIMenu) {
        iconImageView.image = icon
        selectionLabel.text = selectionText
        menuButton.menu = menu
    }


    private func setupLayout() {
        let selectionRow = UIStackView(arrangedSubviews: [selectionLabel, chevronView])
        selectionRow.axis = .horizontal
        selectionRow.spacing = 6
        selectionRow.alignment = .center
        selectionRow.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [sectionLabel, selectionRow])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconImageView)
        addSubview(textStack)
        addSubview(menuButton)
        menuButton.enablePressScale(to: 0.97)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 36),
            iconImageView.heightAnchor.constraint(equalToConstant: 36),

            textStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 14),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            menuButton.topAnchor.constraint(equalTo: topAnchor),
            menuButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            menuButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            menuButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
