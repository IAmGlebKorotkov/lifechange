//
//  CustomTextField.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

extension DateFormatter {

    private static var appDateLocale: Locale { Locale(identifier: "ru_RU") }
    private static let appShortMonths = [
        "янв.", "февр.", "мар.", "апр.", "мая", "июн.",
        "июл.", "авг.", "сент.", "окт.", "нояб.", "дек."
    ]

    static func appDateString(from date: Date) -> String {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let day = components.day ?? 1
        let monthIndex = max(0, min((components.month ?? 1) - 1, appShortMonths.count - 1))
        let year = components.year ?? Calendar.current.component(.year, from: date)
        return "\(day) \(appShortMonths[monthIndex]) \(year) г."
    }

    static func appDateTimeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = appDateLocale
        formatter.dateFormat = "HH:mm"
        return "\(appDateString(from: date)), \(formatter.string(from: date))"
    }

    static func appWeekdayDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = appDateLocale
        formatter.dateFormat = "EEEE"
        let raw = formatter.string(from: date)
        let weekday = raw.prefix(1).uppercased() + raw.dropFirst()
        return "\(weekday), \(appDateString(from: date))"
    }

    static func appDate(from text: String) -> Date? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = trimmed
            .replacingOccurrences(of: " г.", with: "")
            .replacingOccurrences(of: " г", with: "")
            .replacingOccurrences(of: "  ", with: " ")
        let parts = normalized.split(separator: " ")

        if parts.count == 3,
           let day = Int(parts[0]),
           let monthIndex = appShortMonths.firstIndex(of: String(parts[1])),
           let year = Int(parts[2]) {
            var components = DateComponents()
            components.calendar = Calendar.current
            components.day = day
            components.month = monthIndex + 1
            components.year = year
            if let date = components.date {
                return date
            }
        }

        let currentFormatter = DateFormatter()
        currentFormatter.locale = appDateLocale
        currentFormatter.dateFormat = "d MMMM yyyy 'г.'"
        if let date = currentFormatter.date(from: trimmed) {
            return date
        }

        let legacyFormatter = DateFormatter()
        legacyFormatter.locale = appDateLocale
        legacyFormatter.dateFormat = "dd.MM.yyyy"
        return legacyFormatter.date(from: trimmed)
    }
}

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
        DateFormatter.appDateString(from: date)
    }
}
