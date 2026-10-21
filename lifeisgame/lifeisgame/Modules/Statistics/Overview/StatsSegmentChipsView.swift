//
//  StatsSegmentChipsView.swift
//  lifeisgame
//
//  Ряд сегмент-чипов «Эмоции / Сон / Задачи» на экране статистики.
//

import UIKit

final class StatsSegmentChipsView: UIView {

    var onSelectionChanged: ((Int) -> Void)?
    private(set) var selectedIndex = 0

    private var chips: [UIControl] = []

    init(items: [String]) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])

        for (index, title) in items.enumerated() {
            let chip = makeChip(title: title, index: index)
            chips.append(chip)
            stack.addArrangedSubview(chip)
        }
        updateChips()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeChip(title: String, index: Int) -> UIControl {
        let control = UIControl()
        control.tag = index
        control.layer.cornerRadius = 13

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        control.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: control.topAnchor, constant: 9),
            label.bottomAnchor.constraint(equalTo: control.bottomAnchor, constant: -9),
            label.leadingAnchor.constraint(equalTo: control.leadingAnchor, constant: 17),
            label.trailingAnchor.constraint(equalTo: control.trailingAnchor, constant: -17)
        ])

        control.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        control.enablePressScale(to: 0.96)
        return control
    }

    private func updateChips() {
        for chip in chips {
            guard let label = chip.subviews.first(where: { $0 is UILabel }) as? UILabel else { continue }
            let isSelected = chip.tag == selectedIndex

            UIView.animate(withDuration: 0.2) {
                chip.backgroundColor = isSelected ? .main : .white
                label.textColor = isSelected ? .white : UIColor(rgb: 0x3C3C43, alpha: 0.6)
                label.font = .systemFont(ofSize: 14, weight: isSelected ? .semibold : .medium)
            }

            if isSelected {
                chip.applyPrimaryButtonShadow()
                chip.layer.shadowOpacity = 0.35
            } else {
                chip.applyCardShadow(strength: 0.5)
            }
        }
    }

    @objc private func chipTapped(_ sender: UIControl) {
        guard sender.tag != selectedIndex else { return }
        selectedIndex = sender.tag
        updateChips()
        onSelectionChanged?(selectedIndex)
    }
}
