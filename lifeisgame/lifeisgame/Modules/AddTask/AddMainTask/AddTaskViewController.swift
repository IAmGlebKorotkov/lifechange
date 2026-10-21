//
//  AddTaskViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 31.03.2026.
//

import UIKit

final class AddTaskViewController: UIViewController {
    var onAddSubtaskTapped: ((String, @escaping (TaskService.SubtaskInput) -> Void) -> Void)?
    var onEditSubtask: ((String, TaskService.SubtaskInput, @escaping (TaskService.SubtaskInput) -> Void) -> Void)?
    var onGenerate: ((TaskService.Input) -> Void)?


    private let viewModel: AddTaskViewModel
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

    private let simpleFormView = TaskBaseFormView()
    private let eventFormView = TaskBaseFormView(
        showsTimeSection: false,
        startDateTitle: "Начало",
        deadlineDateTitle: "Конец",
        datePickerMode: .dateAndTime
    )
    private let hardFormView = HardTaskFormView()

    private let formContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    private let hintView = ValidationHintView()
    private let generateButton = CustomButton(title: "Сгенерировать План", type: .main)

    private var activeFormView: TaskBaseFormView {
        switch viewModel.kind {
        case .event:
            return eventFormView
        case .simpleTask:
            return simpleFormView
        case .hardTask:
            return hardFormView
        }
    }


    init(viewModel: AddTaskViewModel = AddTaskViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        title = viewModel.kind.navigationTitle
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

        contentStack.addArrangedSubview(formContainer)
        setupFormContainer()
        contentStack.addArrangedSubview(hintView)
        contentStack.addArrangedSubview(generateButton)

        generateButton.isEnabled = false
        generateButton.setTitle(viewModel.isEvent ? "Создать событие" : "Сгенерировать План")

        activeFormView.onValidationChanged = { [weak self] in self?.validateAndUpdateButton() }

        hardFormView.onAddSubtaskTapped = { [weak self] in
            self?.openAddSubtask()
        }

        hardFormView.onEditSubtask = { [weak self] index, currentSubtask, completion in
            self?.openEditSubtask(index: index, currentSubtask: currentSubtask, completion: completion)
        }

        generateButton.addTarget(self, action: #selector(generateTapped), for: .touchUpInside)
    }

    private func setupFormContainer() {
        let form = activeFormView
        formContainer.addSubview(form)

        NSLayoutConstraint.activate([
            form.topAnchor.constraint(equalTo: formContainer.topAnchor),
            form.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor),
            form.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor),
            form.bottomAnchor.constraint(equalTo: formContainer.bottomAnchor)
        ])
    }

    private func applyInitialDateIfNeeded() {
        guard let initialDate else { return }
        activeFormView.startDatePicker.date = initialDate
        activeFormView.deadlineDatePicker.date = viewModel.isEvent
            ? initialDate.addingTimeInterval(60 * 60)
            : initialDate
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
        currentSubtask: TaskService.SubtaskInput,
        completion: @escaping (TaskService.SubtaskInput) -> Void
    ) {
        let parentName = hardFormView.nameTextField.text ?? ""
        onEditSubtask?(parentName, currentSubtask, completion)
    }

    @objc private func generateTapped() {
        onGenerate?(viewModel.makeInput(from: currentDraft()))
    }


    private func validateAndUpdateButton() {
        let result = viewModel.validate(currentDraft())
        generateButton.isEnabled = result.isValid
        hintView.update(with: result.errors.map { $0.message })
    }

    private func currentDraft() -> AddTaskDraft {
        let activeForm = activeFormView

        return AddTaskDraft(
            name: activeForm.nameTextField.text ?? "",
            description: activeForm.descTextView.text,
            startDate: activeForm.startDatePicker.date,
            deadlineDate: activeForm.deadlineDatePicker.date,
            importance: activeForm.importance,
            difficulty: activeForm.difficulty,
            selectedDuration: viewModel.isHardTask
                ? hardFormView.totalSubtasksDuration
                : activeForm.timePicker.countDownDuration,
            subtasks: hardFormView.subtaskInputs
        )
    }
}
