//
//  DateCell.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class DateCell: UICollectionViewCell {

    static let reuseID = "DateCell"


    private let cardControl: UIControl = {
        let control = UIControl()
        control.layer.cornerRadius = 18
        control.isUserInteractionEnabled = false
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [monthLabel, dayLabel, weekdayLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 1
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        cardControl.enablePressScale(to: 0.97)
        contentView.addSubview(cardControl)
        cardControl.addSubview(stackView)

        NSLayoutConstraint.activate([
            cardControl.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cardControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            stackView.centerXAnchor.constraint(equalTo: cardControl.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: cardControl.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func configure(date: Date, isSelected: Bool) {
        let cal = Calendar.current
        let comps = cal.dateComponents([.month, .day, .weekday], from: date)

        let months    = ["янв","фев","мар","апр","май","июн","июл","авг","сен","окт","ноя","дек"]
        let weekdays  = ["вс","пн","вт","ср","чт","пт","сб"]

        monthLabel.text   = months[(comps.month ?? 1) - 1]
        dayLabel.text     = "\(comps.day ?? 1)"
        weekdayLabel.text = weekdays[(comps.weekday ?? 1) - 1]

        UIView.animate(withDuration: 0.18) {
            if isSelected {
                self.cardControl.backgroundColor = UIColor.main
                self.monthLabel.textColor        = UIColor.white.withAlphaComponent(0.85)
                self.dayLabel.textColor          = .white
                self.weekdayLabel.textColor      = UIColor.white.withAlphaComponent(0.85)
            } else {
                self.cardControl.backgroundColor = UIColor.white
                self.monthLabel.textColor        = .systemGray
                self.dayLabel.textColor          = .label
                self.weekdayLabel.textColor      = .systemGray
            }
        }
    }
}
