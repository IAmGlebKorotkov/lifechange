//
//  EditTaskViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 09.05.2026.
//

import UIKit

final class EditTaskViewController: UIViewController {

    var onSaved: (() -> Void)?

    private let viewModel: EditTaskViewModel

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

    init(viewModel: EditTaskViewModel) {
        self.viewModel = viewModel
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
        bindViewModel()
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
            name: viewModel.viewData.name,
            description: viewModel.viewData.description,
            importance: viewModel.viewData.importance,
            difficulty: viewModel.viewData.difficulty
        )
    }

    private func bindViewModel() {
        viewModel.onSaved = { [weak self] in
            self?.onSaved?()
            self?.navigationController?.popViewController(animated: true)
        }
        viewModel.onSaveFailed = { [weak self] message in
            self?.showError(message)
        }
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
        AddTaskUIHelpers.styleCard(card)

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
        valueLabel.text = viewModel.viewData.timeRangeText
        valueLabel.font = .systemFont(ofSize: 13, weight: .medium)
        valueLabel.textColor = UIColor.main
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.82
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let durationLabel = UILabel()
        durationLabel.text = viewModel.viewData.durationText
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
        saveButton.isEnabled = viewModel.canSaveTaskName(formView.nameTextField.text)
    }

    @objc private func saveTapped() {
        viewModel.save(
            name: formView.nameTextField.text,
            description: formView.descTextView.text,
            importance: formView.importance,
            difficulty: formView.difficulty
        )
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

}
