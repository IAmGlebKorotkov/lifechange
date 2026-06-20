//
//  AddSubtaskViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 09.04.2026.
//

import UIKit

final class AddSubtaskViewController: UIViewController {


    private let viewModel: AddSubtaskViewModel

    init(viewModel: AddSubtaskViewModel) {
        self.viewModel = viewModel
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
        tf.text = viewModel.parentTaskName
        tf.isUserInteractionEnabled = false
        tf.alpha = 0.6
        return tf
    }()


    private let subtaskNameTextField = CustomTextField(fieldType: .standard, placeholder: "Введите название")


    private let descriptionCard = LabeledTextViewCard(title: "Описание", placeholder: "Введите описание")
    private var descTextView: UITextView { descriptionCard.textView }

    private let importanceSliderCard = MetricSliderCard(title: "Важность")
    private let difficultySliderCard = MetricSliderCard(title: "Сложность")
    private let timePickerCard = ExpandableTimePickerCard()
    private var timePicker: UIDatePicker { timePickerCard.picker }

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

    var onSubtaskAdded: ((TaskService.SubtaskInput) -> Void)?


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupNavigation()
        setupLayout()
        applyMode()
        addMoreButton.addTarget(self, action: #selector(addMoreTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        subtaskNameTextField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        updateButtonStates()
    }

    @objc private func nameChanged() {
        updateButtonStates()
    }

    private func updateButtonStates() {
        let valid = viewModel.canSave(name: subtaskNameTextField.text)
        continueButton.isEnabled = valid
        addMoreButton.isEnabled = valid
    }

    private func applyMode() {
        title = viewModel.title
        addMoreButton.isHidden = !viewModel.showsAddMoreButton

        if let currentSubtask = viewModel.currentSubtask {
            subtaskNameTextField.text = currentSubtask.name
            descriptionCard.text = currentSubtask.description ?? ""
            importanceSliderCard.value = currentSubtask.importance
            difficultySliderCard.value = currentSubtask.difficulty
            timePickerCard.countDownDuration = currentSubtask.estimatedDuration
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

        contentStack.addArrangedSubview(FormFieldCard(title: "Название задачи", field: parentTaskTextField))
        contentStack.addArrangedSubview(FormFieldCard(title: "Название подзадачи", field: subtaskNameTextField))

        contentStack.addArrangedSubview(descriptionCard)

        contentStack.addArrangedSubview(importanceSliderCard)
        contentStack.addArrangedSubview(difficultySliderCard)

        contentStack.addArrangedSubview(timePickerCard)

        contentStack.addArrangedSubview(addMoreButton)
        contentStack.addArrangedSubview(continueButton)
    }

    @objc private func addMoreTapped() {
        saveCurrentSubtaskForChain()
        let nextViewModel = AddSubtaskViewModel(parentTaskName: viewModel.parentTaskName)
        let vc = AddSubtaskViewController(viewModel: nextViewModel)
        vc.onSubtaskAdded = onSubtaskAdded
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func continueTapped() {
        guard let subtask = makeSubtaskInput() else { return }

        if viewModel.isEditingExistingSubtask {
            viewModel.saveEditedSubtask(subtask)
            navigationController?.popViewController(animated: true)
        } else {
            onSubtaskAdded?(subtask)
            guard let navController = navigationController else { return }
            if let target = navController.viewControllers.first(where: { $0 is AddTaskViewController }) {
                navController.popToViewController(target, animated: true)
            } else {
                navController.popViewController(animated: true)
            }
        }
    }

    private func saveCurrentSubtaskForChain() {
        guard let subtask = makeSubtaskInput() else { return }
        onSubtaskAdded?(subtask)
    }

    private func makeSubtaskInput() -> TaskService.SubtaskInput? {
        viewModel.makeInput(
            name: subtaskNameTextField.text,
            description: descTextView.text,
            importance: importanceSliderCard.value,
            difficulty: difficultySliderCard.value,
            estimatedDuration: timePicker.countDownDuration
        )
    }
}
