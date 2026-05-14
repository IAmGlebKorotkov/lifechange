//
//  AddSubtaskViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 09.04.2026.
//

import UIKit

final class AddSubtaskViewController: UIViewController {


    private let validationUseCase = SubtaskValidationUseCase()


    enum Mode {
        case add
        case edit(currentSubtask: CreateTaskUseCase.SubtaskInput, onSaved: (CreateTaskUseCase.SubtaskInput) -> Void)
    }


    private let parentTaskName: String
    private let mode: Mode

    init(parentTaskName: String, mode: Mode = .add) {
        self.parentTaskName = parentTaskName
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .interactive
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 20
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()


    private lazy var parentTaskTextField: CustomTextField = {
        let tf = CustomTextField(fieldType: .standard, placeholder: "")
        tf.text = parentTaskName
        tf.isUserInteractionEnabled = false
        tf.alpha = 0.6
        return tf
    }()


    private let subtaskNameTextField = CustomTextField(fieldType: .standard, placeholder: "Введите название")


    private let descTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let descPlaceholder: UILabel = {
        let l = UILabel()
        l.text = "Введите описание"
        l.font = .systemFont(ofSize: 16)
        l.textColor = .placeholderText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let importanceSlider: UISlider = {
        let s = UISlider()
        s.minimumValue = 1
        s.maximumValue = 10
        s.value = 5
        s.minimumTrackTintColor = UIColor.main
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let difficultySlider: UISlider = {
        let s = UISlider()
        s.minimumValue = 1
        s.maximumValue = 10
        s.value = 5
        s.minimumTrackTintColor = UIColor.main
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
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

    private let timePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .countDownTimer
        dp.countDownDuration = 3600
        dp.locale = Locale(identifier: "ru_RU")
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()

    private let timeValueLabel: UILabel = {
        let l = UILabel()
        l.text = "1 часов 0 минут"
        l.font = .systemFont(ofSize: 14)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let timeCard = UIView()
    private let timePickerContainer = UIView()
    private var timePickerHeightConstraint: NSLayoutConstraint!
    private var isTimePickerExpanded = false

    private let addMoreButton: CustomButton = {
        let b = CustomButton(title: "Добавить ещё подзадачу", type: .secondary)
        b.isEnabled = false
        return b
    }()

    private let continueButton: CustomButton = {
        let b = CustomButton(title: "Продолжить", type: .main)
        b.isEnabled = false
        return b
    }()

    var onSubtaskAdded: ((CreateTaskUseCase.SubtaskInput) -> Void)?


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupNavigation()
        setupLayout()
        applyMode()
        descTextView.delegate = self
        addMoreButton.addTarget(self, action: #selector(addMoreTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        subtaskNameTextField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        importanceSlider.addTarget(self, action: #selector(importanceChanged), for: .valueChanged)
        difficultySlider.addTarget(self, action: #selector(difficultyChanged), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
        updateButtonStates()
    }

    @objc private func nameChanged() {
        updateButtonStates()
    }

    private func updateButtonStates() {
        let valid = validationUseCase.isValid(SubtaskValidationInput(name: subtaskNameTextField.text ?? ""))
        continueButton.isEnabled = valid
        addMoreButton.isEnabled = valid
    }

    private func applyMode() {
        switch mode {
        case .add:
            title = "Добавить подзадачу"
        case .edit(let currentSubtask, _):
            title = "Изменение подзадачи"
            subtaskNameTextField.text = currentSubtask.name
            descTextView.text = currentSubtask.description ?? ""
            descPlaceholder.isHidden = !(currentSubtask.description?.isEmpty ?? true)
            importanceSlider.value = Float(currentSubtask.importance)
            difficultySlider.value = Float(currentSubtask.difficulty)
            timePicker.countDownDuration = currentSubtask.estimatedDuration
            updateImportanceLabel()
            updateDifficultyLabel()
            updateTimeLabel()
            addMoreButton.isHidden = true
        }
    }


    private func setupNavigation() {
        let backButton = UIBarButtonItem(
            image: UIImage(named: "Arrow - Left") ?? UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }


    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -40),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        let parentHeader = makeTaskSectionHeader("Название задачи")
        contentStack.addArrangedSubview(makeFieldBlock(header: parentHeader, field: parentTaskTextField))

        let subtaskHeader = makeTaskSectionHeader("Название подзадачи")
        contentStack.addArrangedSubview(makeFieldBlock(header: subtaskHeader, field: subtaskNameTextField))

        contentStack.addArrangedSubview(makeDescCard())

        let importanceHeader = makeTaskSectionHeader("Важность")
        contentStack.addArrangedSubview(makeSliderBlock(header: importanceHeader, valueLabel: importanceValueLabel, slider: importanceSlider))

        let difficultyHeader = makeTaskSectionHeader("Сложность")
        contentStack.addArrangedSubview(makeSliderBlock(header: difficultyHeader, valueLabel: difficultyValueLabel, slider: difficultySlider))

        setupTimeCard()
        contentStack.addArrangedSubview(timeCard)

        contentStack.addArrangedSubview(addMoreButton)
        contentStack.addArrangedSubview(continueButton)
    }


    private func makeDescCard() -> UIView {
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

        return card
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
            self.view.layoutIfNeeded()
        }
    }

    @objc private func importanceChanged() {
        let val = Int(roundf(importanceSlider.value))
        importanceSlider.value = Float(val)
        updateImportanceLabel()
    }

    @objc private func difficultyChanged() {
        let val = Int(roundf(difficultySlider.value))
        difficultySlider.value = Float(val)
        updateDifficultyLabel()
    }

    @objc private func timeChanged() {
        updateTimeLabel()
    }

    private func updateImportanceLabel() {
        importanceValueLabel.text = "\(Int(roundf(importanceSlider.value)))"
    }

    private func updateDifficultyLabel() {
        difficultyValueLabel.text = "\(Int(roundf(difficultySlider.value)))"
    }

    private func updateTimeLabel() {
        let total = Int(timePicker.countDownDuration)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        timeValueLabel.text = "\(hours) часов \(minutes) минут"
        timeValueLabel.textColor = .label
    }


    @objc private func addMoreTapped() {
        saveCurrentSubtaskForChain()
        let vc = AddSubtaskViewController(parentTaskName: parentTaskName)
        vc.onSubtaskAdded = onSubtaskAdded
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func continueTapped() {
        guard let subtask = makeSubtaskInput() else { return }

        switch mode {
        case .add:
            onSubtaskAdded?(subtask)
            guard let navController = navigationController else { return }
            if let target = navController.viewControllers.first(where: { $0 is AddTaskViewController }) {
                navController.popToViewController(target, animated: true)
            } else {
                navController.popViewController(animated: true)
            }

        case .edit(_, let onSaved):
            onSaved(subtask)
            navigationController?.popViewController(animated: true)
        }
    }

    private func saveCurrentSubtaskForChain() {
        guard let subtask = makeSubtaskInput() else { return }
        onSubtaskAdded?(subtask)
    }

    private func makeSubtaskInput() -> CreateTaskUseCase.SubtaskInput? {
        let name = subtaskNameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !name.isEmpty else { return nil }

        let description = descTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return CreateTaskUseCase.SubtaskInput(
            name: name,
            description: description.isEmpty ? nil : description,
            importance: Int(roundf(importanceSlider.value)),
            difficulty: Int(roundf(difficultySlider.value)),
            estimatedDuration: timePicker.countDownDuration
        )
    }
}


extension AddSubtaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descPlaceholder.isHidden = !textView.text.isEmpty
    }
}
