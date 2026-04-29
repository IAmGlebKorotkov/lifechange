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
        case edit(currentName: String, onSaved: (String) -> Void)
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

    var onSubtaskAdded: ((String) -> Void)?


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
        case .edit(let currentName, _):
            title = "Изменение подзадачи"
            subtaskNameTextField.text = currentName
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


    @objc private func addMoreTapped() {
        saveCurrentSubtaskForChain()
        let vc = AddSubtaskViewController(parentTaskName: parentTaskName)
        vc.onSubtaskAdded = onSubtaskAdded
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func continueTapped() {
        let text = subtaskNameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""

        switch mode {
        case .add:
            if !text.isEmpty { onSubtaskAdded?(text) }
            guard let navController = navigationController else { return }
            if let target = navController.viewControllers.first(where: { $0 is AddTaskViewController }) {
                navController.popToViewController(target, animated: true)
            } else {
                navController.popViewController(animated: true)
            }

        case .edit(_, let onSaved):
            if !text.isEmpty { onSaved(text) }
            navigationController?.popViewController(animated: true)
        }
    }

    private func saveCurrentSubtaskForChain() {
        let text = subtaskNameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text.isEmpty else { return }
        onSubtaskAdded?(text)
    }
}


extension AddSubtaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descPlaceholder.isHidden = !textView.text.isEmpty
    }
}
