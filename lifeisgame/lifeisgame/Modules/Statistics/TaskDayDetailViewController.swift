//
//  TaskDayDetailViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class TaskDayDetailViewController: UIViewController {


    struct TaskItem {
        let title: String
        let isCompleted: Bool
    }

    private let date: String
    private let tasks: [TaskItem]

    init(date: String, tasks: [TaskItem]) {
        self.date  = date
        self.tasks = tasks
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    private let dragIndicator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.separator
        v.layer.cornerRadius = 2.5
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 10
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        titleLabel.text = date
        setupLayout()
        buildRows()
    }


    private func setupLayout() {
        view.addSubview(dragIndicator)
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            dragIndicator.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            dragIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dragIndicator.widthAnchor.constraint(equalToConstant: 40),
            dragIndicator.heightAnchor.constraint(equalToConstant: 5),

            titleLabel.topAnchor.constraint(equalTo: dragIndicator.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    private func buildRows() {
        for task in tasks {
            stack.addArrangedSubview(makeRow(task))
        }
    }

    private func makeRow(_ task: TaskItem) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false

        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let icon = task.isCompleted ? "checkmark.circle.fill" : "circle"
        let iconView = UIImageView(image: UIImage(systemName: icon, withConfiguration: cfg))
        iconView.tintColor = task.isCompleted ? UIColor.main : .systemGray3
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = task.title
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = task.isCompleted ? .secondaryLabel : .label
        if task.isCompleted {
            let attrs: [NSAttributedString.Key: Any] = [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            label.attributedText = NSAttributedString(string: task.title, attributes: attrs)
        }
        label.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconView)
        card.addSubview(label)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            label.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            card.heightAnchor.constraint(equalToConstant: 52)
        ])

        return card
    }
}
