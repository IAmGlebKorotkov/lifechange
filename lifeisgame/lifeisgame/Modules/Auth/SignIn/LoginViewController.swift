//
//  LoginViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class LoginViewController: UIViewController {


    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Войти"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Введите ваш логин и пароль"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailTextField = CustomTextField(fieldType: .email, placeholder: "почта")
    private let passwordTextField = CustomTextField(fieldType: .password, placeholder: "пароль")

    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Забыли пароль?", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(.systemGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .trailing
        return button
    }()

    private let hintView = ValidationHintView()

    private let loginButton: CustomButton = {
        let b = CustomButton(title: "Войти", type: .main)
        b.isEnabled = false
        return b
    }()

    private let faceIDButton: CustomButton = {
        let button = CustomButton(title: "Войти через Face ID", type: .secondary)
        button.isHidden = true
        return button
    }()

    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Регистрация", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.setTitleColor(.main, for: .normal)
        button.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        return button
    }()

    private lazy var bottomStackView: UIStackView = {
        let label = UILabel()
        label.text = "У вас нет аккаунта?"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray

        let stack = UIStackView(arrangedSubviews: [label, registerButton])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()


    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        emailTextField.addTarget(self, action: #selector(fieldsChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(fieldsChanged), for: .editingChanged)
        validateAndUpdate()
        viewModel.updateFaceIDAvailability()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateFaceIDAvailability()
    }


    @objc private func fieldsChanged() {
        validateAndUpdate()
    }

    private func validateAndUpdate() {
        let result = viewModel.validate(
            email: emailTextField.text ?? "",
            password: passwordTextField.text ?? ""
        )
        loginButton.isEnabled = result.isValid
        hintView.update(with: result.errors.map { $0.message })
    }


    private func setupUI() {
        view.backgroundColor = UIColor.background

        let emailContainer = LabeledInputCard(title: "Логин", field: emailTextField)
        let passwordContainer = LabeledInputCard(title: "Пароль", field: passwordTextField)

        let stackView = UIStackView(arrangedSubviews: [
            emailContainer,
            passwordContainer,
            forgotPasswordButton,
            hintView,
            loginButton,
            faceIDButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.setCustomSpacing(8, after: passwordContainer)
        stackView.setCustomSpacing(24, after: forgotPasswordButton)
        stackView.setCustomSpacing(12, after: hintView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(stackView)
        contentView.addSubview(bottomStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -24),

            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            bottomStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            bottomStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        faceIDButton.addTarget(self, action: #selector(faceIDLoginTapped), for: .touchUpInside)

        viewModel.onError = { [weak self] message in
            self?.hintView.update(with: [message])
        }
        viewModel.onFaceIDAvailabilityChanged = { [weak self] isAvailable in
            self?.faceIDButton.isHidden = !isAvailable
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }


    @objc private func registerTapped() { viewModel.registerTapped() }
    @objc private func loginTapped() {
        viewModel.loginTapped(
            email: emailTextField.text ?? "",
            password: passwordTextField.text ?? ""
        )
    }
    @objc private func faceIDLoginTapped() {
        viewModel.faceIDLoginTapped()
    }
    @objc private func dismissKeyboard() { view.endEditing(true) }
}
