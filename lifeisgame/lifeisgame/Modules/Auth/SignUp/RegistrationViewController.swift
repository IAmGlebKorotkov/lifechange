//
//  RegistrationViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class RegistrationViewController: UIViewController {


    private let validationUseCase = RegistrationValidationUseCase()


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
        let result = validationUseCase.validate(RegistrationValidationInput(
            name: nameTextField.text ?? "",
            email: emailTextField.text ?? "",
            birthDate: birthDateTextField.text ?? "",
            password: passwordTextField.text ?? ""
        ))
        registerButton.isEnabled = result.isValid
        hintView.update(with: result.errors.map { $0.message })
    }


    private func setupUI() {
        view.backgroundColor = UIColor.background

        let nameContainer = makeFieldContainer(title: "Имя", textField: nameTextField)
        let emailContainer = makeFieldContainer(title: "Почта", textField: emailTextField)
        let birthDateContainer = makeFieldContainer(title: "Дата рождения", textField: birthDateTextField)
        let passwordContainer = makeFieldContainer(title: "Пароль", textField: passwordTextField)

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

        view.addSubview(titleLabel)
        view.addSubview(stackView)
        view.addSubview(bottomStackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            bottomStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)

        viewModel.onError = { [weak self] message in
            self?.hintView.update(with: [message])
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
