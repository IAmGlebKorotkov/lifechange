//
//  AddTaskViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 31.03.2026.
//

import UIKit

final class AddTaskViewController: UIViewController {


    var onAddSubtaskTapped: ((String, @escaping (String) -> Void) -> Void)?
    var onEditSubtask: ((String, String, @escaping (String) -> Void) -> Void)?
    var onGenerate: ((CreateTaskUseCase.Input) -> Void)?


    private let validationUseCase = TaskValidationUseCase()


    private var isHardTask = false


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
    private let hardFormView = HardTaskFormView()


    private let hintView = ValidationHintView()
    private let generateButton = CustomButton(title: "Сгенерировать План", type: .main)


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        title = "Добавить задачу"
        setupNavigation()
        setupLayout()
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

        setupToggleCard()
        contentStack.addArrangedSubview(taskTypeCard)
        contentStack.addArrangedSubview(simpleFormView)
        contentStack.addArrangedSubview(hardFormView)
        contentStack.addArrangedSubview(hintView)
        contentStack.addArrangedSubview(generateButton)

        hardFormView.isHidden = true
        generateButton.isEnabled = false

        taskTypeToggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)

        simpleFormView.onValidationChanged = { [weak self] in self?.validateAndUpdateButton() }
        hardFormView.onValidationChanged = { [weak self] in self?.validateAndUpdateButton() }

        hardFormView.onAddSubtaskTapped = { [weak self] in
            self?.openAddSubtask()
        }

        hardFormView.onEditSubtask = { [weak self] index, currentName, completion in
            self?.openEditSubtask(index: index, currentName: currentName, completion: completion)
        }

        generateButton.addTarget(self, action: #selector(generateTapped), for: .touchUpInside)
    }

    private func openAddSubtask() {
        let parentName = hardFormView.nameTextField.text ?? ""
        onAddSubtaskTapped?(parentName) { [weak self] text in
            self?.hardFormView.appendSubtask(text)
        }
    }

    private func openEditSubtask(index: Int, currentName: String, completion: @escaping (String) -> Void) {
        let parentName = hardFormView.nameTextField.text ?? ""
        onEditSubtask?(parentName, currentName, completion)
    }

    @objc private func generateTapped() {
        let form: TaskBaseFormView = isHardTask ? hardFormView : simpleFormView
        let input = CreateTaskUseCase.Input(
            name: form.nameTextField.text ?? "",
            description: form.descTextView.text.isEmpty ? nil : form.descTextView.text,
            startDate: form.startDatePicker.date,
            deadlineDate: form.deadlineDatePicker.date,
            isHardTask: isHardTask,
            subtaskNames: isHardTask ? hardFormView.subtaskNames : []
        )
        onGenerate?(input)
    }


    private func setupToggleCard() {
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


    @objc private func toggleChanged() {
        isHardTask = taskTypeToggle.isOn

        UIView.transition(with: taskTypeLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.taskTypeLabel.text = self.isHardTask ? "Сложная задача" : "Простая задача"
        }

        UIView.animate(withDuration: 0.3) {
            self.simpleFormView.isHidden = self.isHardTask
            self.hardFormView.isHidden = !self.isHardTask
        }

        validateAndUpdateButton()
    }


    private func validateAndUpdateButton() {
        let activeForm: TaskBaseFormView = isHardTask ? hardFormView : simpleFormView
        let input = TaskValidationInput(
            name: activeForm.nameTextField.text ?? "",
            startDate: activeForm.startDatePicker.date,
            deadlineDate: activeForm.deadlineDatePicker.date,
            isHardTask: isHardTask,
            subtasksCount: isHardTask ? hardFormView.subtasksCount : 0
        )
        let result = validationUseCase.validate(input)
        generateButton.isEnabled = result.isValid
        hintView.update(with: result.errors.map { $0.message })
    }
}
