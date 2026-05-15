//
//  LogoutBottomSheetViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class LogoutBottomSheetViewController: UIViewController {

    var onLogout: (() -> Void)?


    private let dragIndicator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.separator
        v.layer.cornerRadius = 2.5
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Выйти из аккаунта"
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Вы уверены, что хотите выйти?"
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let logoutButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Выйти", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor.main
        b.layer.cornerRadius = 14
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupUI()
    }


    private func setupUI() {
        view.addSubview(dragIndicator)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            dragIndicator.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            dragIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dragIndicator.widthAnchor.constraint(equalToConstant: 40),
            dragIndicator.heightAnchor.constraint(equalToConstant: 5),

            titleLabel.topAnchor.constraint(equalTo: dragIndicator.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            logoutButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 54)
        ])

        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        logoutButton.enablePressScale()
    }


    @objc private func logoutTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onLogout?()
        }
    }
}
