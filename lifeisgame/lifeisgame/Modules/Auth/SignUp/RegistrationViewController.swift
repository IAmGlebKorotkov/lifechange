//
//  RegistrationViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class RegistrationViewController: UIViewController {


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
        label.text = "Регистрация"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameTextField = CustomTextField(fieldType: .standard, placeholder: "имя")
    private let emailTextField = CustomTextField(fieldType: .email, placeholder: "почта")
    private let birthDateTextField = CustomTextField(fieldType: .date, placeholder: "дата рождения")
    private let passwordTextField = CustomTextField(fieldType: .password, placeholder: "пароль")

    private let hintView = ValidationHintView()

    private let registerButton: CustomButton = {
        let b = CustomButton(title: "Зарегистрироваться", type: .main)
        b.isEnabled = false
        return b
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.setTitleColor(.main, for: .normal)
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()

    private lazy var bottomStackView: UIStackView = {
        let label = UILabel()
        label.text = "У вас уже есть аккаунт?"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray

        let stack = UIStackView(arrangedSubviews: [label, loginButton])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()


    private let viewModel: RegistrationViewModel

    init(viewModel: RegistrationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        nameTextField.addTarget(self, action: #selector(fieldsChanged), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(fieldsChanged), for: .editingChanged)
        birthDateTextField.addTarget(self, action: #selector(fieldsChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(fieldsChanged), for: .editingChanged)
        validateAndUpdate()
    }


    @objc private func fieldsChanged() {
        validateAndUpdate()
    }

    private func validateAndUpdate() {
        let result = viewModel.validate(
            name: nameTextField.text ?? "",
            email: emailTextField.text ?? "",
            birthDate: birthDateTextField.text ?? "",
            password: passwordTextField.text ?? ""
        )
        registerButton.isEnabled = result.isValid
        hintView.update(with: result.errors.map { $0.message })
    }


    private func setupUI() {
        view.backgroundColor = UIColor.background

        let nameContainer = LabeledInputCard(title: "Имя", field: nameTextField)
        let emailContainer = LabeledInputCard(title: "Почта", field: emailTextField)
        let birthDateContainer = LabeledInputCard(title: "Дата рождения", field: birthDateTextField)
        let passwordContainer = LabeledInputCard(title: "Пароль", field: passwordTextField)

        let stackView = UIStackView(arrangedSubviews: [
            nameContainer,
            emailContainer,
            birthDateContainer,
            passwordContainer,
            hintView,
            registerButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.setCustomSpacing(12, after: hintView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
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
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -24),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            bottomStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            bottomStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)

        viewModel.onError = { [weak self] message in
            self?.hintView.update(with: [message])
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }


    @objc private func loginTapped() { viewModel.loginTapped() }
    @objc private func registerTapped() {
        viewModel.registerTapped(
            name: nameTextField.text ?? "",
            email: emailTextField.text ?? "",
            birthDateText: birthDateTextField.text ?? "",
            password: passwordTextField.text ?? ""
        )
    }
    @objc private func dismissKeyboard() { view.endEditing(true) }
}
