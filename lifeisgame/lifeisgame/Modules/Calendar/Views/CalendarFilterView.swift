//
//  CalendarFilterView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

enum CalendarFilter: Int, CaseIterable {
    case all, inProgress, done

    var title: String {
        switch self {
        case .all:        return "Все"
        case .inProgress: return "В процессе"
        case .done:       return "Готово"
        }
    }
}

final class CalendarFilterView: UIView {

    var onFilterChanged: ((CalendarFilter) -> Void)?

    private var selectedFilter: CalendarFilter = .all
    private var filterButtons: [UIControl] = []

    private let selectionPill: UIView = {
        let view = UIView()
        view.backgroundColor = .main
        view.layer.cornerRadius = 9
        view.layer.shadowColor = UIColor.main.cgColor
        view.layer.shadowOpacity = 0.22
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .segmentTrack
        layer.cornerRadius = 11

        addSubview(selectionPill)
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3)
        ])

        setupButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Кнопки должны получить фреймы до позиционирования пилюли,
        // иначе на первом проходе «Все» остаётся без выделения.
        stackView.layoutIfNeeded()
        movePill(animated: false)
    }

    private func setupButtons() {
        for filter in CalendarFilter.allCases {
            let btn = makeButton(filter: filter)
            filterButtons.append(btn)
            stackView.addArrangedSubview(btn)
        }
        updateButtons()
    }

    private func makeButton(filter: CalendarFilter) -> UIControl {
        let control = UIControl()
        control.tag = filter.rawValue

        let label = UILabel()
        label.text = filter.title
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        control.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: control.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: control.centerYAnchor)
        ])

        control.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return control
    }

    private func updateButtons() {
        for control in filterButtons {
            guard let filter = CalendarFilter(rawValue: control.tag),
                  let label = control.subviews.first(where: { $0 is UILabel }) as? UILabel
            else { continue }

            let isSelected = filter == selectedFilter
            label.font = .systemFont(ofSize: 13, weight: isSelected ? .semibold : .medium)
            label.textColor = isSelected ? .white : .textSecondaryToken
        }
    }

    private func movePill(animated: Bool) {
        guard let control = filterButtons.first(where: { $0.tag == selectedFilter.rawValue }) else { return }
        let target = control.convert(control.bounds, to: self)
        let apply = { self.selectionPill.frame = target }

        guard animated else {
            apply()
            return
        }
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.4,
            options: .allowUserInteraction,
            animations: apply
        )
    }

    @objc private func buttonTapped(_ sender: UIControl) {
        guard let filter = CalendarFilter(rawValue: sender.tag), filter != selectedFilter else { return }
        selectedFilter = filter
        updateButtons()
        movePill(animated: true)
        onFilterChanged?(filter)
    }
}
