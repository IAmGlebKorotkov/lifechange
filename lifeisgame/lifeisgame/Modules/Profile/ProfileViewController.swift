//
//  ProfileViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class ProfileViewController: UIViewController {


    private let viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Профиль"
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let avatarContainer: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 52
        v.backgroundColor = UIColor.main.withAlphaComponent(0.1)
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 52, weight: .light)
        iv.image = UIImage(systemName: "person.fill", withConfiguration: cfg)
        iv.tintColor = UIColor.main.withAlphaComponent(0.4)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.text = "Коротков Глеб"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .label
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let loginField  = ProfileTextField(title: "Логин",  value: "glebkorotkov")
    private let passwordField = ProfileTextField(title: "Пароль", value: "••••••••")

    private let logoutButton: UIButton = {
        let b = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        b.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right", withConfiguration: cfg), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.main.withAlphaComponent(0.6)
        b.layer.cornerRadius = 30
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let faceIDRow = ProfileToggleRow(icon: "faceid", title: "Вход через Face ID")
    private let notificationsRow = ProfileToggleRow(icon: "bell.fill", title: "Уведомления")

    private let changePasswordButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Изменить пароль", for: .normal)
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
        bindViewModel()
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        logoutButton.enablePressScale()
        changePasswordButton.enablePressScale()

        notificationsRow.isOn = LocalNotificationService.shared.isEnabled

        viewModel.loadProfile()

        faceIDRow.onValueChanged = { [weak self] isOn in
            self?.viewModel.setFaceIDEnabled(isOn)
        }
        notificationsRow.onValueChanged = { [weak self] isOn in
            self?.viewModel.setNotificationsEnabled(isOn)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadProfile()
    }

    private func bindViewModel() {
        viewModel.onProfileUpdated = { [weak self] profile in
            self?.nameLabel.text = profile.name
            self?.loginField.value = profile.email
            self?.passwordField.value = profile.passwordMask
            self?.faceIDRow.isOn = profile.isFaceIDEnabled
        }

        viewModel.onFaceIDStateChanged = { [weak self] isEnabled in
            self?.faceIDRow.isOn = isEnabled
        }

        viewModel.onNotificationsStateChanged = { [weak self] isEnabled in
            self?.notificationsRow.isOn = isEnabled
        }

        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }


    private func setupUI() {
        avatarContainer.addSubview(avatarImageView)
        view.addSubview(titleLabel)
        view.addSubview(logoutButton)
        view.addSubview(avatarContainer)
        view.addSubview(nameLabel)
        view.addSubview(loginField)
        view.addSubview(passwordField)
        view.addSubview(faceIDRow)
        view.addSubview(notificationsRow)
        view.addSubview(changePasswordButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            logoutButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoutButton.widthAnchor.constraint(equalToConstant: 60),
            logoutButton.heightAnchor.constraint(equalToConstant: 60),

            avatarContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 36),
            avatarContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 104),
            avatarContainer.heightAnchor.constraint(equalToConstant: 104),

            avatarImageView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),

            nameLabel.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            loginField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 32),
            loginField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            passwordField.topAnchor.constraint(equalTo: loginField.bottomAnchor, constant: 12),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            faceIDRow.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24),
            faceIDRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            faceIDRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            notificationsRow.topAnchor.constraint(equalTo: faceIDRow.bottomAnchor, constant: 12),
            notificationsRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            notificationsRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            changePasswordButton.topAnchor.constraint(equalTo: notificationsRow.bottomAnchor, constant: 24),
            changePasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            changePasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            changePasswordButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }


    @objc private func logoutTapped() {
        let sheet = LogoutBottomSheetViewController()
        sheet.onLogout = { [weak self] in
            self?.viewModel.onLogoutRequested?()
        }
        if let presenter = sheet.sheetPresentationController {
            presenter.detents = [.custom { _ in 260 }]
            presenter.prefersGrabberVisible = false
            presenter.preferredCornerRadius = 24
        }
        present(sheet, animated: true)
    }
}
