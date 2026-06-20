//
//  FaceIDUnlockViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 14.05.2026.
//

import UIKit

final class FaceIDUnlockViewController: UIViewController {

    private let viewModel: FaceIDUnlockViewModel
    private var didStartAuthentication = false

    var onUnlocked: (() -> Void)?
    var onFallbackLogin: (() -> Void)?

    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.main.withAlphaComponent(0.1)
        view.layer.cornerRadius = 48
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 44, weight: .medium)
        let imageView = UIImageView(image: UIImage(systemName: "faceid", withConfiguration: config))
        imageView.tintColor = UIColor.main
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Вход через Face ID"
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Подтвердите личность, чтобы открыть приложение"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let retryButton = CustomButton(title: "Повторить Face ID", type: .main)
    private let fallbackButton = CustomButton(title: "Войти другим способом", type: .secondary)

    init(viewModel: FaceIDUnlockViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupLayout()
        bindViewModel()
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        fallbackButton.addTarget(self, action: #selector(fallbackTapped), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didStartAuthentication else { return }
        didStartAuthentication = true
        authenticate()
    }

    private func setupLayout() {
        iconContainer.addSubview(iconView)
        view.addSubview(iconContainer)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(errorLabel)
        view.addSubview(retryButton)
        view.addSubview(fallbackButton)

        NSLayoutConstraint.activate([
            iconContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120),
            iconContainer.widthAnchor.constraint(equalToConstant: 96),
            iconContainer.heightAnchor.constraint(equalToConstant: 96),

            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            errorLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 18),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            fallbackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            fallbackButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            fallbackButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),

            retryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            retryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            retryButton.bottomAnchor.constraint(equalTo: fallbackButton.topAnchor, constant: -12)
        ])
    }

    private func bindViewModel() {
        viewModel.onUnlocked = { [weak self] in
            self?.onUnlocked?()
        }
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
    }

    private func authenticate() {
        errorLabel.isHidden = true
        viewModel.authenticate()
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    @objc private func retryTapped() {
        authenticate()
    }

    @objc private func fallbackTapped() {
        onFallbackLogin?()
    }
}
