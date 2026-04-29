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
        case .done:       return "Выполнено"
        }
    }
}

final class CalendarFilterView: UIView {

    var onFilterChanged: ((CalendarFilter) -> Void)?


    private var selectedFilter: CalendarFilter = .all
    private var filterButtons: [UIControl] = []


    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])

        setupButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        control.layer.cornerRadius = 12

        let label = UILabel()
        label.text = filter.title
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        control.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: control.topAnchor, constant: 11),
            label.bottomAnchor.constraint(equalTo: control.bottomAnchor, constant: -11),
            label.leadingAnchor.constraint(equalTo: control.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: control.trailingAnchor, constant: -20)
        ])

        control.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        control.enablePressScale()
        return control
    }

    private func updateButtons() {
        let mainColor = UIColor.main
        let lightMain = mainColor.withAlphaComponent(0.12)

        for control in filterButtons {
            guard let filter = CalendarFilter(rawValue: control.tag),
                  let label = control.subviews.first(where: { $0 is UILabel }) as? UILabel
            else { continue }

            let isSelected = filter == selectedFilter
            UIView.animate(withDuration: 0.18) {
                control.backgroundColor = isSelected ? mainColor : lightMain
                label.textColor = isSelected ? .white : mainColor
            }
        }
    }

    @objc private func buttonTapped(_ sender: UIControl) {
        guard let filter = CalendarFilter(rawValue: sender.tag), filter != selectedFilter else { return }
        selectedFilter = filter
        updateButtons()
        onFilterChanged?(filter)
    }
}
