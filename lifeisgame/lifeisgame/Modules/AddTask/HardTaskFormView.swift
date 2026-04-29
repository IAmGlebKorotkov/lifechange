//
//  HardTaskFormView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 31.03.2026.
//

import UIKit

final class HardTaskFormView: TaskBaseFormView {


    private var subtasks: [String] = [] {
        didSet { onValidationChanged?() }
    }

    var subtasksCount: Int { subtasks.count }
    var subtaskNames: [String] { subtasks }


    private let subtasksCard = UIView()

    private let subtasksStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 8
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let addSubtaskButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Добавить подзадачу", for: .normal)
        b.setTitleColor(UIColor.main, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let subtasksMenuButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Список подзадач", for: .normal)
        b.setTitleColor(.label, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        b.backgroundColor = .white
        b.layer.cornerRadius = 22
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.systemGray4.cgColor
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.06
        b.layer.shadowOffset = CGSize(width: 0, height: 2)
        b.layer.shadowRadius = 8
        b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        b.showsMenuAsPrimaryAction = true
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true
        return b
    }()


    var onAddSubtaskTapped: (() -> Void)?

    var onEditSubtask: ((Int, String, @escaping (String) -> Void) -> Void)?


    override func addSubtasksSection() {
        setupSubtasksCard()
        addArrangedSubview(subtasksCard)

        subtasksMenuButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        addArrangedSubview(subtasksMenuButton)

        addSubtaskButton.addTarget(self, action: #selector(addSubtaskTapped), for: .touchUpInside)
    }


    private func setupSubtasksCard() {
        styleCard(subtasksCard)
        let header = makeTaskSectionHeader("Подзадачи")
        subtasksCard.addSubview(header)
        subtasksCard.addSubview(subtasksStack)
        subtasksCard.addSubview(addSubtaskButton)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: subtasksCard.topAnchor, constant: 14),
            header.leadingAnchor.constraint(equalTo: subtasksCard.leadingAnchor, constant: 16),

            subtasksStack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            subtasksStack.leadingAnchor.constraint(equalTo: subtasksCard.leadingAnchor, constant: 16),
            subtasksStack.trailingAnchor.constraint(equalTo: subtasksCard.trailingAnchor, constant: -16),

            addSubtaskButton.topAnchor.constraint(equalTo: subtasksStack.bottomAnchor, constant: 8),
            addSubtaskButton.leadingAnchor.constraint(equalTo: subtasksCard.leadingAnchor, constant: 16),
            addSubtaskButton.bottomAnchor.constraint(equalTo: subtasksCard.bottomAnchor, constant: -14)
        ])
    }


    @objc private func addSubtaskTapped() {
        onAddSubtaskTapped?()
    }

    func appendSubtask(_ text: String) {
        subtasks.append(text)
        addSubtaskRow(text)
        updateSubtasksMenu()
    }

    private func addSubtaskRow(_ text: String) {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center

        let bullet = UIView()
        bullet.backgroundColor = UIColor.main
        bullet.layer.cornerRadius = 4
        bullet.translatesAutoresizingMaskIntoConstraints = false
        bullet.widthAnchor.constraint(equalToConstant: 8).isActive = true
        bullet.heightAnchor.constraint(equalToConstant: 8).isActive = true

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let removeBtn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        removeBtn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: cfg), for: .normal)
        removeBtn.tintColor = .systemGray3
        removeBtn.translatesAutoresizingMaskIntoConstraints = false

        row.addArrangedSubview(bullet)
        row.addArrangedSubview(label)
        row.addArrangedSubview(removeBtn)

        removeBtn.addAction(UIAction { [weak self, weak row] _ in
            guard let self, let row else { return }
            if let idx = self.subtasksStack.arrangedSubviews.firstIndex(of: row) {
                self.subtasks.remove(at: idx)
            }
            UIView.animate(withDuration: 0.25) {
                row.alpha = 0
                row.isHidden = true
            } completion: { _ in
                self.subtasksStack.removeArrangedSubview(row)
                row.removeFromSuperview()
                self.updateSubtasksMenu()
            }
        }, for: .touchUpInside)

        row.alpha = 0
        subtasksStack.addArrangedSubview(row)
        UIView.animate(withDuration: 0.25) { row.alpha = 1 }
    }


    private func updateSubtasksMenu() {
        let isEmpty = subtasks.isEmpty
        UIView.animate(withDuration: 0.2) {
            self.subtasksMenuButton.isHidden = isEmpty
        }
        guard !isEmpty else { return }

        let count = subtasks.count
        let title = count == 1 ? "1 подзадача" : "\(count) подзадач"
        subtasksMenuButton.setTitle("  \(title)  ›", for: .normal)

        let editIcon = UIImage(systemName: "pencil.circle.fill")
        let trashIcon = UIImage(systemName: "trash.circle.fill")

        let menuItems: [UIMenuElement] = subtasks.enumerated().map { (index, subtask) in
            UIMenu(title: subtask, image: UIImage(systemName: "circle.fill"), options: [], children: [
                UIAction(title: "Изменить", image: editIcon) { [weak self] _ in
                    self?.editSubtask(at: index)
                },
                UIAction(title: "Удалить", image: trashIcon, attributes: .destructive) { [weak self] _ in
                    self?.deleteSubtask(at: index)
                }
            ])
        }

        subtasksMenuButton.menu = UIMenu(title: "Подзадачи", children: menuItems)
    }

    private func editSubtask(at index: Int) {
        guard index < subtasks.count else { return }
        let currentName = subtasks[index]
        onEditSubtask?(index, currentName) { [weak self] newName in
            guard let self else { return }
            self.subtasks[index] = newName
            if index < self.subtasksStack.arrangedSubviews.count,
               let row = self.subtasksStack.arrangedSubviews[index] as? UIStackView,
               let label = row.arrangedSubviews[safe: 1] as? UILabel {
                label.text = newName
            }
            self.updateSubtasksMenu()
        }
    }

    private func deleteSubtask(at index: Int) {
        guard index < subtasks.count,
              index < subtasksStack.arrangedSubviews.count else { return }
        subtasks.remove(at: index)
        let row = subtasksStack.arrangedSubviews[index]
        UIView.animate(withDuration: 0.25) {
            row.alpha = 0
            row.isHidden = true
        } completion: { _ in
            self.subtasksStack.removeArrangedSubview(row)
            row.removeFromSuperview()
            self.updateSubtasksMenu()
        }
    }
}


private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
