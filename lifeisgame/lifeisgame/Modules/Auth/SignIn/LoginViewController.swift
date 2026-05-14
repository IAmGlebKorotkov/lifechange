//
//  LoginViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class LoginViewController: UIViewController {


    private let validationUseCase = LoginValidationUseCase()


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
    private let telegramButton = CustomButton(title: "Войти с помощью Телеграм", type: .secondary)

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
        let result = validationUseCase.validate(LoginValidationInput(
            email: emailTextField.text ?? "",
            password: passwordTextField.text ?? ""
        ))
        loginButton.isEnabled = result.isValid
        hintView.update(with: result.errors.map { $0.message })
    }


    private func setupUI() {
        view.backgroundColor = UIColor.background

        let emailContainer = makeFieldContainer(title: "Логин", textField: emailTextField)
        let passwordContainer = makeFieldContainer(title: "Пароль", textField: passwordTextField)
        let separator = makeSeparatorView()

        let stackView = UIStackView(arrangedSubviews: [
            emailContainer,
            passwordContainer,
            forgotPasswordButton,
            hintView,
            loginButton,
            faceIDButton,
            separator,
            telegramButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.setCustomSpacing(8, after: passwordContainer)
        stackView.setCustomSpacing(24, after: forgotPasswordButton)
        stackView.setCustomSpacing(12, after: hintView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(stackView)
        view.addSubview(bottomStackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            bottomStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        faceIDButton.addTarget(self, action: #selector(faceIDLoginTapped), for: .touchUpInside)
        telegramButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

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


    private func makeFieldContainer(title: String, textField: CustomTextField) -> UIView {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false

        wrapper.addSubview(label)
        wrapper.addSubview(container)
        container.addSubview(textField)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: wrapper.topAnchor),
            label.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),

            container.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            container.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 52),

            textField.topAnchor.constraint(equalTo: container.topAnchor),
            textField.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])

        return wrapper
    }

    private func makeSeparatorView() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let leftLine = UIView()
        leftLine.backgroundColor = .systemGray4
        leftLine.translatesAutoresizingMaskIntoConstraints = false

        let rightLine = UIView()
        rightLine.backgroundColor = .systemGray4
        rightLine.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "или"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(leftLine)
        container.addSubview(label)
        container.addSubview(rightLine)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 20),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            leftLine.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            leftLine.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -12),
            leftLine.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            leftLine.heightAnchor.constraint(equalToConstant: 1),
            rightLine.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12),
            rightLine.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            rightLine.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            rightLine.heightAnchor.constraint(equalToConstant: 1)
        ])

        return container
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
