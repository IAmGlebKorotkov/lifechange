//
//  TaskBaseFormView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 31.03.2026.
//

import UIKit

class TaskBaseFormView: UIStackView {


    private let showsDateSection: Bool
    private let showsTimeSection: Bool
    private let startDateTitle: String
    private let deadlineDateTitle: String
    private let datePickerMode: UIDatePicker.Mode

    let nameTextField = CustomTextField(fieldType: .standard, placeholder: "Введите название")

    private let descriptionCard = LabeledTextViewCard(title: "Описание", placeholder: "Введите описание")
    var descTextView: UITextView { descriptionCard.textView }

    let startDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.locale = Locale(identifier: "ru_RU")
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()

    let deadlineDatePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.locale = Locale(identifier: "ru_RU")
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()

    private let importanceSliderCard = MetricSliderCard(title: "Важность")
    private let difficultySliderCard = MetricSliderCard(title: "Сложность")

    private let timePickerCard = ExpandableTimePickerCard()
    var timePicker: UIDatePicker { timePickerCard.picker }


    var importance: Int { importanceSliderCard.value }
    var difficulty: Int { difficultySliderCard.value }

    var onValidationChanged: (() -> Void)?


    override init(frame: CGRect = .zero) {
        self.showsDateSection = true
        self.showsTimeSection = true
        self.startDateTitle = "Начало"
        self.deadlineDateTitle = "Дедлайн"
        self.datePickerMode = .date
        super.init(frame: frame)
        setupView()
    }

    init(
        frame: CGRect = .zero,
        showsDateSection: Bool = true,
        showsTimeSection: Bool,
        startDateTitle: String = "Начало",
        deadlineDateTitle: String = "Дедлайн",
        datePickerMode: UIDatePicker.Mode = .date
    ) {
        self.showsDateSection = showsDateSection
        self.showsTimeSection = showsTimeSection
        self.startDateTitle = startDateTitle
        self.deadlineDateTitle = deadlineDateTitle
        self.datePickerMode = datePickerMode
        super.init(frame: frame)
        setupView()
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        axis = .vertical
        spacing = 20
        translatesAutoresizingMaskIntoConstraints = false
        startDatePicker.datePickerMode = datePickerMode
        deadlineDatePicker.datePickerMode = datePickerMode
        buildForm()
        setupValidationObservers()
    }


    private func buildForm() {
        addNameSection()
        addDescSection()
        if showsDateSection {
            addDatesSection()
        }
        addSubtasksSection()
        addSlidersSection()
        if showsTimeSection {
            addTimeSection()
        }
    }

    func addSubtasksSection() {}


    private func addNameSection() {
        addArrangedSubview(FormFieldCard(title: "Название задачи", field: nameTextField))
    }

    private func addDescSection() {
        addArrangedSubview(descriptionCard)
    }

    private func addDatesSection() {
        addArrangedSubview(DatePickerCard(title: startDateTitle, picker: startDatePicker))
        addArrangedSubview(DatePickerCard(title: deadlineDateTitle, picker: deadlineDatePicker))
    }

    private func addSlidersSection() {
        addArrangedSubview(importanceSliderCard)
        addArrangedSubview(difficultySliderCard)
    }

    private func addTimeSection() {
        addArrangedSubview(timePickerCard)
    }


    private func setupValidationObservers() {
        nameTextField.addTarget(self, action: #selector(validationTrigger), for: .editingChanged)
        startDatePicker.addTarget(self, action: #selector(validationTrigger), for: .valueChanged)
        deadlineDatePicker.addTarget(self, action: #selector(validationTrigger), for: .valueChanged)
    }

    @objc private func validationTrigger() {
        onValidationChanged?()
    }

    func configureFields(
        name: String,
        description: String?,
        importance: Int,
        difficulty: Int,
        duration: TimeInterval? = nil
    ) {
        nameTextField.text = name
        descriptionCard.text = description ?? ""

        let safeImportance = max(1, min(10, importance))
        importanceSliderCard.value = safeImportance

        let safeDifficulty = max(1, min(10, difficulty))
        difficultySliderCard.value = safeDifficulty

        if let duration {
            let roundedDuration = max(60, duration)
            timePickerCard.countDownDuration = roundedDuration
        }
    }
}
