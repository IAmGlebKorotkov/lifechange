//
//  CalendarHeaderView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class CalendarHeaderView: UIView {

    var onBellTapped: (() -> Void)?


    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Календарь"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bellButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(named: "notification")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(bellButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            bellButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            bellButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            bellButton.widthAnchor.constraint(equalToConstant: 36),
            bellButton.heightAnchor.constraint(equalToConstant: 36)
        ])

        bellButton.addTarget(self, action: #selector(bellTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    @objc private func bellTapped() {
        onBellTapped?()
    }
}
