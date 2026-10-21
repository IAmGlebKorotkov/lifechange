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

    private let selectionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let chevronView: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        let iv = UIImageView(image: UIImage(systemName: "chevron.down", withConfiguration: cfg))
        iv.tintColor = UIColor(rgb: 0x3C3C43, alpha: 0.4)
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
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 12
        applyCardShadow(strength: 0.8)
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    func update(icon: UIImage?, selectionText: String, menu: UIMenu) {
        iconImageView.image = icon
        selectionLabel.text = selectionText
        menuButton.menu = menu
    }


    private func setupLayout() {
        let row = UIStackView(arrangedSubviews: [iconImageView, selectionLabel, chevronView])
        row.axis = .horizontal
        row.spacing = 6
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        addSubview(row)
        addSubview(menuButton)
        menuButton.enablePressScale(to: 0.97)

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            row.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            menuButton.topAnchor.constraint(equalTo: topAnchor),
            menuButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            menuButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            menuButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
