//
//  EditTaskViewController.swift
//  lifeisgame
//
//  Created by Codex on 16.05.2026.
//

import UIKit

final class EditTaskViewController: UIViewController {

    var onSaved: (() -> Void)?

    private let task: TaskItem
    private let updateTaskDetailsUseCase: UpdateTaskDetailsUseCase

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

    private let formView = TaskBaseFormView(showsDateSection: false, showsTimeSection: false)
    private let saveButton = CustomButton(title: "Сохранить изменения", type: .main)

    init(task: TaskItem, updateTaskDetailsUseCase: UpdateTaskDetailsUseCase) {
        self.task = task
        self.updateTaskDetailsUseCase = updateTaskDetailsUseCase
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        title = "Изменение задачи"
        setupNavigation()
        setupLayout()
        configureForm()
        setupActions()
        updateSaveButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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

        contentStack.addArrangedSubview(formView)
        contentStack.addArrangedSubview(makeTimeInfoCard())
        contentStack.addArrangedSubview(saveButton)
    }

    private func configureForm() {
        formView.configureFields(
            name: task.name,
            description: task.taskDescription,
            importance: task.importance,
            difficulty: task.difficulty
        )
    }

    private func setupActions() {
        formView.onValidationChanged = { [weak self] in
            self?.updateSaveButton()
        }
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func makeTimeInfoCard() -> UIView {
        let card = UIView()
        styleCard(card)

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
        titleLabel.text = "Время выполнения"
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = "\(dateTimeString(task.startDate)) - \(dateTimeString(task.deadlineDate))"
        valueLabel.font = .systemFont(ofSize: 13, weight: .medium)
        valueLabel.textColor = UIColor.main
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.82
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let durationLabel = UILabel()
        durationLabel.text = durationString(task.estimatedDuration)
        durationLabel.font = .systemFont(ofSize: 13)
        durationLabel.textColor = .secondaryLabel
        durationLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconBg)
        iconBg.addSubview(iconView)
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        card.addSubview(durationLabel)

        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconBg.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            iconBg.widthAnchor.constraint(equalToConstant: 40),
            iconBg.heightAnchor.constraint(equalToConstant: 40),

            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            durationLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            durationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            durationLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        return card
    }

    private func updateSaveButton() {
        saveButton.isEnabled = !(formView.nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @objc private func saveTapped() {
        let name = (formView.nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            showError("Введите название задачи")
            return
        }

        let description = formView.descTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let input = UpdateTaskDetailsUseCase.Input(
            taskID: task.id,
            name: name,
            description: description.isEmpty ? nil : description,
            importance: Int(roundf(formView.importanceSlider.value)),
            difficulty: Int(roundf(formView.difficultySlider.value))
        )

        do {
            _ = try updateTaskDetailsUseCase.execute(input: input)
            onSaved?()
            navigationController?.popViewController(animated: true)
        } catch {
            showError(error.localizedDescription)
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Не удалось сохранить", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }

    private func dateTimeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM, HH:mm"
        return formatter.string(from: date)
    }

    private func durationString(_ duration: TimeInterval) -> String {
        let minutes = max(0, Int(duration / 60))
        if minutes < 60 { return "\(minutes) мин" }
        let hours = minutes / 60
        let restMinutes = minutes % 60
        return restMinutes == 0 ? "\(hours) ч" : "\(hours) ч \(restMinutes) мин"
    }
}
