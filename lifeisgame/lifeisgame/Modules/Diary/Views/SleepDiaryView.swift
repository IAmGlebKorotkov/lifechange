//
//  SleepDiaryView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class SleepDiaryView: UIView {


    var onSaveRequested: ((Date, Date) -> Void)?


    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Сон"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = UIColor.main
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let healthButton: UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = .white
        b.layer.cornerRadius = 14
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 54).isActive = true

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "heart.fill",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))?
                           .withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        config.imagePadding = 10
        config.imagePlacement = .leading
        config.title = "Подключить интеграцию «Здоровье»"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs; a.font = .systemFont(ofSize: 15, weight: .medium)
            a.foregroundColor = UIColor.label; return a
        }
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        b.configuration = config
        b.contentHorizontalAlignment = .leading
        return b
    }()

    private let separator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.separator
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return v
    }()

    private let bedtimePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .time
        dp.preferredDatePickerStyle = .compact
        dp.tintColor = UIColor.main
        if let d = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date()) { dp.date = d }
        return dp
    }()

    private let wakePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .time
        dp.preferredDatePickerStyle = .compact
        dp.tintColor = UIColor.main
        if let d = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) { dp.date = d }
        return dp
    }()

    private let clockView = SleepClockView()

    private let saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Сохранить", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor.main
        b.layer.cornerRadius = 14
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 54).isActive = true
        return b
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
        wireSync()
        healthButton.enablePressScale()
        saveButton.enablePressScale()
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    private func setupLayout() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(healthButton)
        contentStack.addArrangedSubview(separator)
        contentStack.addArrangedSubview(buildSleepCard())
        contentStack.addArrangedSubview(saveButton)
    }

    private func buildSleepCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false

        let bedtimeBlock = makePickerBlock(title: "Время отбоя",       picker: bedtimePicker)
        let wakeBlock    = makePickerBlock(title: "Время пробуждения",  picker: wakePicker)

        let leftStack = UIStackView(arrangedSubviews: [bedtimeBlock, wakeBlock])
        leftStack.axis = .vertical
        leftStack.spacing = 16
        leftStack.alignment = .leading
        leftStack.translatesAutoresizingMaskIntoConstraints = false

        clockView.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView(arrangedSubviews: [leftStack, clockView])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(row)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),

            clockView.widthAnchor.constraint(equalTo: clockView.heightAnchor),
            clockView.heightAnchor.constraint(equalToConstant: 210)
        ])

        return card
    }

    private func makePickerBlock(title: String, picker: UIDatePicker) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [label, picker])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }


    private func wireSync() {
        bedtimePicker.addTarget(self, action: #selector(bedtimePickerChanged), for: .valueChanged)
        wakePicker.addTarget(self,    action: #selector(wakePickerChanged),    for: .valueChanged)

        clockView.onSleepDateChanged = { [weak self] date in
            self?.bedtimePicker.setDate(date, animated: true)
        }
        clockView.onWakeDateChanged = { [weak self] date in
            self?.wakePicker.setDate(date, animated: true)
        }
    }

    @objc private func bedtimePickerChanged() {
        clockView.sleepDate = bedtimePicker.date
    }

    @objc private func wakePickerChanged() {
        clockView.wakeDate = wakePicker.date
    }

    @objc private func saveTapped() {
        onSaveRequested?(bedtimePicker.date, wakePicker.date)
    }

    func showSavedState() {
        saveButton.setTitle("Сохранено", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.saveButton.setTitle("Сохранить", for: .normal)
        }
    }
}
