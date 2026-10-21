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
        label.text = "Сегодня"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textSecondaryToken
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let ringView = ProgressRingView(size: 44, lineWidth: 4)

    private let ringLabel: UILabel = {
        let label = UILabel()
        label.text = "0/0"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bellButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "notification")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .main
        button.backgroundColor = UIColor.main.withAlphaComponent(0.10)
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 1
        textStack.alignment = .leading
        textStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(textStack)
        addSubview(bellButton)
        addSubview(ringView)
        ringView.addSubview(ringLabel)

        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            textStack.topAnchor.constraint(equalTo: topAnchor),
            textStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: bellButton.leadingAnchor, constant: -8),

            ringView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ringView.centerYAnchor.constraint(equalTo: centerYAnchor),

            ringLabel.centerXAnchor.constraint(equalTo: ringView.centerXAnchor),
            ringLabel.centerYAnchor.constraint(equalTo: ringView.centerYAnchor),
            ringLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 34),

            bellButton.trailingAnchor.constraint(equalTo: ringView.leadingAnchor, constant: -14),
            bellButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            bellButton.widthAnchor.constraint(equalToConstant: 36),
            bellButton.heightAnchor.constraint(equalToConstant: 36)
        ])

        bellButton.addTarget(self, action: #selector(bellTapped), for: .touchUpInside)
        bellButton.enablePressScale()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    func setProgress(completed: Int, total: Int) {
        ringLabel.text = "\(completed)/\(total)"
        ringView.setProgress(total > 0 ? CGFloat(completed) / CGFloat(total) : 0)
    }

    @objc private func bellTapped() {
        onBellTapped?()
    }
}
