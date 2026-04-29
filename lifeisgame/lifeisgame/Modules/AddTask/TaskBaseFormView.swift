//
//  TaskBaseFormView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 31.03.2026.
//

import UIKit

class TaskBaseFormView: UIStackView {


    let nameTextField = CustomTextField(fieldType: .standard, placeholder: "Введите название")

    let descTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

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

    let importanceSlider: UISlider = {
        let s = UISlider()
        s.minimumValue = 1
        s.maximumValue = 10
        s.value = 5
        s.minimumTrackTintColor = UIColor.main
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    let difficultySlider: UISlider = {
        let s = UISlider()
        s.minimumValue = 1
        s.maximumValue = 10
        s.value = 5
        s.minimumTrackTintColor = UIColor.main
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    let timePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .countDownTimer
        dp.locale = Locale(identifier: "ru_RU")
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()


    private let descPlaceholder: UILabel = {
        let l = UILabel()
        l.text = "Введите описание"
        l.font = .systemFont(ofSize: 16)
        l.textColor = .placeholderText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let importanceValueLabel: UILabel = {
        let l = UILabel()
        l.text = "5"
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = UIColor.main
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let difficultyValueLabel: UILabel = {
        let l = UILabel()
        l.text = "5"
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = UIColor.main
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let timeValueLabel: UILabel = {
        let l = UILabel()
        l.text = "Выберите время"
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let timeCard = UIView()
    private let timePickerContainer = UIView()
    private var timePickerHeightConstraint: NSLayoutConstraint!
    private var isTimePickerExpanded = false


    var onValidationChanged: (() -> Void)?


    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        spacing = 20
        translatesAutoresizingMaskIntoConstraints = false
        buildForm()
        setupSliderActions()
        setupValidationObservers()
        descTextView.delegate = self
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    private func buildForm() {
        addNameSection()
        addDescSection()
        addDatesSection()
        addSubtasksSection()
        addSlidersSection()
        addTimeSection()
    }

    func addSubtasksSection() {}


    private func addNameSection() {
        let header = makeTaskSectionHeader("Название задачи")
        addArrangedSubview(makeFieldBlock(header: header, field: nameTextField))
    }

    private func addDescSection() {
        let card = UIView()
        styleCard(card)

        let header = makeTaskSectionHeader("Описание")
        card.addSubview(header)
        card.addSubview(descTextView)
        descTextView.addSubview(descPlaceholder)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            header.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            header.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            descTextView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 4),
            descTextView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            descTextView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            descTextView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
            descTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),

            descPlaceholder.topAnchor.constraint(equalTo: descTextView.topAnchor, constant: 8),
            descPlaceholder.leadingAnchor.constraint(equalTo: descTextView.leadingAnchor, constant: 5)
        ])

        addArrangedSubview(card)
    }

    private func addDatesSection() {
        addArrangedSubview(makeDateCard(icon: "Calendar", title: "Начало", picker: startDatePicker))
        addArrangedSubview(makeDateCard(icon: "Calendar", title: "Дедлайн", picker: deadlineDatePicker))
    }

    private func addSlidersSection() {
        let importanceHeader = makeTaskSectionHeader("Важность")
        addArrangedSubview(makeSliderBlock(header: importanceHeader, valueLabel: importanceValueLabel, slider: importanceSlider))

        let difficultyHeader = makeTaskSectionHeader("Сложность")
        addArrangedSubview(makeSliderBlock(header: difficultyHeader, valueLabel: difficultyValueLabel, slider: difficultySlider))
    }

    private func addTimeSection() {
        setupTimeCard()
        addArrangedSubview(timeCard)
    }


    private func setupTimeCard() {
        styleCard(timeCard)
        timeCard.clipsToBounds = true

        let iconBg = UIView()
        iconBg.backgroundColor = UIColor.main.withAlphaComponent(0.1)
        iconBg.layer.cornerRadius = 20
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView()
        if let asset = UIImage(named: "Clock") {
            iconView.image = asset.withRenderingMode(.alwaysTemplate)
        } else {
            let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            iconView.image = UIImage(systemName: "clock", withConfiguration: cfg)
        }
        iconView.tintColor = UIColor.main
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Время"
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let chevronCfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let chevron = UIImageView(image: UIImage(systemName: "chevron.down", withConfiguration: chevronCfg))
        chevron.tintColor = .systemGray3
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tag = 999

        timePickerContainer.translatesAutoresizingMaskIntoConstraints = false
        timePickerContainer.clipsToBounds = true
        timePickerContainer.addSubview(timePicker)

        timeCard.addSubview(iconBg)
        iconBg.addSubview(iconView)
        timeCard.addSubview(titleLabel)
        timeCard.addSubview(timeValueLabel)
        timeCard.addSubview(chevron)
        timeCard.addSubview(timePickerContainer)

        timePickerHeightConstraint = timePickerContainer.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: timeCard.leadingAnchor, constant: 16),
            iconBg.topAnchor.constraint(equalTo: timeCard.topAnchor, constant: 12),
            iconBg.widthAnchor.constraint(equalToConstant: 40),
            iconBg.heightAnchor.constraint(equalToConstant: 40),

            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.topAnchor.constraint(equalTo: timeCard.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),

            timeValueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            timeValueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            chevron.trailingAnchor.constraint(equalTo: timeCard.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),

            timePickerContainer.topAnchor.constraint(equalTo: iconBg.bottomAnchor, constant: 8),
            timePickerContainer.leadingAnchor.constraint(equalTo: timeCard.leadingAnchor),
            timePickerContainer.trailingAnchor.constraint(equalTo: timeCard.trailingAnchor),
            timePickerContainer.bottomAnchor.constraint(equalTo: timeCard.bottomAnchor),
            timePickerHeightConstraint,

            timePicker.topAnchor.constraint(equalTo: timePickerContainer.topAnchor),
            timePicker.leadingAnchor.constraint(equalTo: timePickerContainer.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: timePickerContainer.trailingAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(timeCardTapped))
        timeCard.addGestureRecognizer(tap)
    }

    @objc private func timeCardTapped() {
        isTimePickerExpanded.toggle()
        timePickerHeightConstraint.constant = isTimePickerExpanded ? 200 : 0

        let chevron = timeCard.viewWithTag(999) as? UIImageView

        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            chevron?.transform = self.isTimePickerExpanded
                ? CGAffineTransform(rotationAngle: .pi)
                : .identity
            self.window?.layoutIfNeeded()
        }
    }


    private func setupValidationObservers() {
        nameTextField.addTarget(self, action: #selector(validationTrigger), for: .editingChanged)
        startDatePicker.addTarget(self, action: #selector(validationTrigger), for: .valueChanged)
        deadlineDatePicker.addTarget(self, action: #selector(validationTrigger), for: .valueChanged)
    }

    @objc private func validationTrigger() {
        onValidationChanged?()
    }


    private func setupSliderActions() {
        timePicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
        importanceSlider.addTarget(self, action: #selector(importanceChanged), for: .valueChanged)
        difficultySlider.addTarget(self, action: #selector(difficultyChanged), for: .valueChanged)
    }

    @objc private func timeChanged() {
        let total = Int(timePicker.countDownDuration)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        timeValueLabel.text = "\(hours) часов \(minutes) минут"
        timeValueLabel.textColor = .label
    }

    @objc private func importanceChanged() {
        let val = Int(roundf(importanceSlider.value))
        importanceSlider.value = Float(val)
        importanceValueLabel.text = "\(val)"
    }

    @objc private func difficultyChanged() {
        let val = Int(roundf(difficultySlider.value))
        difficultySlider.value = Float(val)
        difficultyValueLabel.text = "\(val)"
    }
}


extension TaskBaseFormView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descPlaceholder.isHidden = !textView.text.isEmpty
    }
}
