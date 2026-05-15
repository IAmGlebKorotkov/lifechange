//
//  CustomTextField.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

enum TextFieldType {
    case email
    case password
    case standard
    case date
}

final class CustomTextField: UITextField {

    private let fieldType: TextFieldType

    private lazy var rightActionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()

    private var isPasswordVisible = false

    init(fieldType: TextFieldType, placeholder: String) {
        self.fieldType = fieldType
        super.init(frame: .zero)
        setupTextField(placeholder: placeholder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTextField(placeholder: String) {
        self.placeholder = placeholder
        backgroundColor = .clear
        borderStyle = .none
        font = .systemFont(ofSize: 16)
        autocapitalizationType = .none
        autocorrectionType = .no
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 44).isActive = true

        switch fieldType {
        case .email:
            keyboardType = .emailAddress
            textContentType = .emailAddress
            setupRightButton()
            addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        case .password:
            isSecureTextEntry = true
            textContentType = .password
            setupRightButton()
        case .standard:
            break
        case .date:
            inputView = datePicker
            tintColor = .clear
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(dateDonePressed))
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbar.setItems([spacer, doneButton], animated: false)
            inputAccessoryView = toolbar
        }
    }

    private func setupRightButton() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 52))
        rightActionButton.frame = CGRect(x: 0, y: 14, width: 24, height: 24)
        containerView.addSubview(rightActionButton)

        rightView = containerView
        rightViewMode = .whileEditing

        updateRightButtonIcon()
    }

    private func updateRightButtonIcon() {
        switch fieldType {
        case .email:
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
            rightActionButton.setImage(image, for: .normal)
        case .password:
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            let iconName = isPasswordVisible ? "Hide" : "Show"
            let image = UIImage(named: iconName)
            rightActionButton.setImage(image, for: .normal)
            rightViewMode = .always
        default:
            break
        }
    }

    @objc private func rightButtonTapped() {
        switch fieldType {
        case .email:
            text = ""
            sendActions(for: .editingChanged)
        case .password:
            isPasswordVisible.toggle()
            isSecureTextEntry = !isPasswordVisible
            updateRightButtonIcon()

            if let existingText = text {
                text = nil
                text = existingText
            }
        default:
            break
        }
    }

    @objc private func textDidChange() {
        if fieldType == .email {
            rightViewMode = (text?.isEmpty ?? true) ? .never : .whileEditing
        }
    }

    @objc private func dateChanged() {
        text = formatDate(datePicker.date)
    }

    @objc private func dateDonePressed() {
        text = formatDate(datePicker.date)
        resignFirstResponder()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy'г.'"
        return formatter.string(from: date)
    }
}
