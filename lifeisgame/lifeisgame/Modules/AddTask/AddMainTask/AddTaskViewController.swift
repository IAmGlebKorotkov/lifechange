//
//  AddTaskViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 31.03.2026.
//

import UIKit

final class AddTaskViewController: UIViewController {


    var onAddSubtaskTapped: ((String, @escaping (CreateTaskUseCase.SubtaskInput) -> Void) -> Void)?
    var onEditSubtask: ((String, CreateTaskUseCase.SubtaskInput, @escaping (CreateTaskUseCase.SubtaskInput) -> Void) -> Void)?
    var onGenerate: ((CreateTaskUseCase.Input) -> Void)?


    private let validationUseCase = TaskValidationUseCase()


    private var isHardTask = false
    private var isEvent = false
    private var initialDate: Date?


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


    private let taskTypeCard = UIView()
    private let taskKindCard = UIView()

    private let taskKindLabel: UILabel = {
        let l = UILabel()
        l.text = "Задача"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let taskKindToggle: UISwitch = {
        let s = UISwitch()
        s.onTintColor = UIColor.main
        s.isOn = false
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let taskTypeLabel: UILabel = {
        let l = UILabel()
        l.text = "Простая задача"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let taskTypeToggle: UISwitch = {
        let s = UISwitch()
        s.onTintColor = UIColor.main
        s.isOn = false
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()


    private let simpleFormView = TaskBaseFormView()
    private let eventFormView = TaskBaseFormView(
        showsTimeSection: false,
        startDateTitle: "Начало",
        deadlineDateTitle: "Конец",
        datePickerMode: .dateAndTime
    )
    private let hardFormView = HardTaskFormView()


    private let hintView = ValidationHintView()
    private let generateButton = CustomButton(title: "Сгенерировать План", type: .main)


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        title = "Добавить задачу"
        setupNavigation()
        setupLayout()
        applyInitialDateIfNeeded()
    }

    func configureInitialDate(_ date: Date) {
        initialDate = date
        if isViewLoaded {
            applyInitialDateIfNeeded()
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

        setupKindToggleCard()
        setupTypeToggleCard()
        contentStack.addArrangedSubview(taskKindCard)
        contentStack.addArrangedSubview(taskTypeCard)
        contentStack.addArrangedSubview(simpleFormView)
        contentStack.addArrangedSubview(eventFormView)
        contentStack.addArrangedSubview(hardFormView)
        contentStack.addArrangedSubview(hintView)
        contentStack.addArrangedSubview(generateButton)

        eventFormView.isHidden = true
        hardFormView.isHidden = true
        generateButton.isEnabled = false

        taskKindToggle.addTarget(self, action: #selector(kindToggleChanged), for: .valueChanged)
        taskTypeToggle.addTarget(self, action: #selector(typeToggleChanged), for: .valueChanged)

        simpleFormView.onValidationChanged = { [weak self] in self?.validateAndUpdateButton() }
        eventFormView.onValidationChanged = { [weak self] in self?.validateAndUpdateButton() }
        hardFormView.onValidationChanged = { [weak self] in self?.validateAndUpdateButton() }

        hardFormView.onAddSubtaskTapped = { [weak self] in
            self?.openAddSubtask()
        }

        hardFormView.onEditSubtask = { [weak self] index, currentSubtask, completion in
            self?.openEditSubtask(index: index, currentSubtask: currentSubtask, completion: completion)
        }

        generateButton.addTarget(self, action: #selector(generateTapped), for: .touchUpInside)
    }

    private func applyInitialDateIfNeeded() {
        guard let initialDate else { return }
        simpleFormView.startDatePicker.date = initialDate
        simpleFormView.deadlineDatePicker.date = initialDate
        eventFormView.startDatePicker.date = initialDate
        eventFormView.deadlineDatePicker.date = initialDate.addingTimeInterval(60 * 60)
        hardFormView.startDatePicker.date = initialDate
        hardFormView.deadlineDatePicker.date = initialDate
        validateAndUpdateButton()
    }

    private func openAddSubtask() {
        let parentName = hardFormView.nameTextField.text ?? ""
        onAddSubtaskTapped?(parentName) { [weak self] subtask in
            self?.hardFormView.appendSubtask(subtask)
        }
    }

    private func openEditSubtask(
        index: Int,
        currentSubtask: CreateTaskUseCase.SubtaskInput,
        completion: @escaping (CreateTaskUseCase.SubtaskInput) -> Void
    ) {
        let parentName = hardFormView.nameTextField.text ?? ""
        onEditSubtask?(parentName, currentSubtask, completion)
    }

    @objc private func generateTapped() {
        let form: TaskBaseFormView = isEvent ? eventFormView : (isHardTask ? hardFormView : simpleFormView)
        let eventDuration = max(15 * 60, eventFormView.deadlineDatePicker.date.timeIntervalSince(eventFormView.startDatePicker.date))
        let input = CreateTaskUseCase.Input(
            name: form.nameTextField.text ?? "",
            description: form.descTextView.text.isEmpty ? nil : form.descTextView.text,
            startDate: form.startDatePicker.date,
            deadlineDate: form.deadlineDatePicker.date,
            importance: Int(roundf(form.importanceSlider.value)),
            difficulty: Int(roundf(form.difficultySlider.value)),
            estimatedDuration: isEvent
                ? eventDuration
                : (isHardTask ? hardFormView.totalSubtasksDuration : form.timePicker.countDownDuration),
            isHardTask: !isEvent && isHardTask,
            isEvent: isEvent,
            subtasks: (!isEvent && isHardTask) ? hardFormView.subtaskInputs : []
        )
        onGenerate?(input)
    }


    private func setupKindToggleCard() {
        styleCard(taskKindCard)
        taskKindCard.addSubview(taskKindLabel)
        taskKindCard.addSubview(taskKindToggle)

        NSLayoutConstraint.activate([
            taskKindLabel.leadingAnchor.constraint(equalTo: taskKindCard.leadingAnchor, constant: 16),
            taskKindLabel.centerYAnchor.constraint(equalTo: taskKindCard.centerYAnchor),

            taskKindToggle.trailingAnchor.constraint(equalTo: taskKindCard.trailingAnchor, constant: -16),
            taskKindToggle.centerYAnchor.constraint(equalTo: taskKindCard.centerYAnchor),

            taskKindCard.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func setupTypeToggleCard() {
        styleCard(taskTypeCard)
        taskTypeCard.addSubview(taskTypeLabel)
        taskTypeCard.addSubview(taskTypeToggle)

        NSLayoutConstraint.activate([
            taskTypeLabel.leadingAnchor.constraint(equalTo: taskTypeCard.leadingAnchor, constant: 16),
            taskTypeLabel.centerYAnchor.constraint(equalTo: taskTypeCard.centerYAnchor),

            taskTypeToggle.trailingAnchor.constraint(equalTo: taskTypeCard.trailingAnchor, constant: -16),
            taskTypeToggle.centerYAnchor.constraint(equalTo: taskTypeCard.centerYAnchor),

            taskTypeCard.heightAnchor.constraint(equalToConstant: 56)
        ])
    }


    @objc private func kindToggleChanged() {
        isEvent = taskKindToggle.isOn

        UIView.transition(with: taskKindLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.taskKindLabel.text = self.isEvent ? "Событие" : "Задача"
        }

        updateVisibleForm()
    }

    @objc private func typeToggleChanged() {
        isHardTask = taskTypeToggle.isOn

        UIView.transition(with: taskTypeLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.taskTypeLabel.text = self.isHardTask ? "Сложная задача" : "Простая задача"
        }

        updateVisibleForm()
    }

    private func updateVisibleForm() {
        UIView.animate(withDuration: 0.3) {
            self.taskTypeCard.isHidden = self.isEvent
            self.simpleFormView.isHidden = self.isEvent || self.isHardTask
            self.eventFormView.isHidden = !self.isEvent
            self.hardFormView.isHidden = self.isEvent || !self.isHardTask
        }

        generateButton.setTitle(isEvent ? "Создать событие" : "Сгенерировать План")
        validateAndUpdateButton()
    }


    private func validateAndUpdateButton() {
        let activeForm: TaskBaseFormView = isEvent ? eventFormView : (isHardTask ? hardFormView : simpleFormView)
        let input = TaskValidationInput(
            name: activeForm.nameTextField.text ?? "",
            startDate: activeForm.startDatePicker.date,
            deadlineDate: activeForm.deadlineDatePicker.date,
            isHardTask: !isEvent && isHardTask,
            isEvent: isEvent,
            subtasksCount: (!isEvent && isHardTask) ? hardFormView.subtasksCount : 0
        )
        let result = validationUseCase.validate(input)
        generateButton.isEnabled = result.isValid
        hintView.update(with: result.errors.map { $0.message })
    }
}
