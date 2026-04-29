//
//  ProfileToggleRow.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class ProfileToggleRow: UIView {


    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor.main
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let toggle: UISwitch = {
        let s = UISwitch()
        s.onTintColor = UIColor.main
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()


    var isOn: Bool {
        get { toggle.isOn }
        set { toggle.setOn(newValue, animated: false) }
    }

    var onValueChanged: ((Bool) -> Void)?


    init(icon: String, title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        iconView.image = UIImage(systemName: icon, withConfiguration: cfg)
        titleLabel.text = title

        backgroundColor = .white
        layer.cornerRadius = 14

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(toggle)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56),

            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -12),

            toggle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            toggle.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        toggle.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    @objc private func switchChanged() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onValueChanged?(toggle.isOn)
    }
}
