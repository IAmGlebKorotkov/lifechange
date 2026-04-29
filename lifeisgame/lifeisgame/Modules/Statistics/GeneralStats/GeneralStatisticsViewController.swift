//
//  GeneralStatisticsViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class GeneralStatisticsViewController: UIViewController {


    private let viewModel: GeneralStatsViewModel

    init(viewModel: GeneralStatsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.delaysContentTouches = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 12
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let photoPlaceholder: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray6
        v.layer.cornerRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let actionButton = CustomButton(title: "Подсказки дня", type: .main)

    private let trophyButton: UIButton = {
        let b = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        b.setImage(UIImage(systemName: "trophy.fill", withConfiguration: cfg), for: .normal)
        b.tintColor = UIColor.main
        b.backgroundColor = UIColor.main.withAlphaComponent(0.12)
        b.layer.cornerRadius = 22
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private lazy var tipsCardView: UIView = makeTipsCard()
    private var tipsExpanded = false

    private let tasksCard = WeeklyStatCardView(style: .taskCount(
        title: "Выполнено задач за неделю",
        completed: 15,
        total: 23
    ))

    private let sleepCard = WeeklyStatCardView(style: .percentage(
        title: "Качество сна",
        value: 0.72
    ))

    private let efficiencyCard = WeeklyStatCardView(style: .percentage(
        title: "Эффективность",
        value: 0.85
    ))

    private let moodCard = WeeklyStatCardView(style: .percentage(
        title: "Настроение за неделю",
        value: 0.68
    ))


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupLayout()
    }


    private func setupLayout() {
        setupPhotoPlaceholder()

        view.addSubview(scrollView)
        view.addSubview(trophyButton)
        scrollView.addSubview(contentStack)

        trophyButton.addTarget(self, action: #selector(openAchievements), for: .touchUpInside)
        trophyButton.enablePressScale(to: 0.90)

        tipsCardView.isHidden = true
        tipsCardView.alpha = 0

        contentStack.addArrangedSubview(photoPlaceholder)
        contentStack.setCustomSpacing(16, after: photoPlaceholder)
        contentStack.addArrangedSubview(actionButton)
        contentStack.setCustomSpacing(12, after: actionButton)
        contentStack.addArrangedSubview(tipsCardView)
        contentStack.setCustomSpacing(20, after: tipsCardView)

        actionButton.addTarget(self, action: #selector(toggleTips), for: .touchUpInside)
        contentStack.addArrangedSubview(tasksCard)
        contentStack.addArrangedSubview(sleepCard)
        contentStack.addArrangedSubview(efficiencyCard)
        contentStack.addArrangedSubview(moodCard)

        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),

            photoPlaceholder.heightAnchor.constraint(equalTo: photoPlaceholder.widthAnchor, multiplier: 3.0 / 4.0),

            trophyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            trophyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            trophyButton.widthAnchor.constraint(equalToConstant: 44),
            trophyButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }


    private func makeTipsCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Подсказки дня"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let tips = [
            "Выпейте стакан воды сразу после пробуждения",
            "Сделайте 10 минут медитации или глубокого дыхания",
            "Запишите 3 вещи, за которые вы благодарны сегодня",
        ]

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        for tip in tips {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 10
            row.alignment = .top

            let dot = UIView()
            dot.backgroundColor = UIColor.main
            dot.layer.cornerRadius = 4
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 8).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 8).isActive = true

            let dotWrapper = UIView()
            dotWrapper.translatesAutoresizingMaskIntoConstraints = false
            dotWrapper.addSubview(dot)
            NSLayoutConstraint.activate([
                dot.centerXAnchor.constraint(equalTo: dotWrapper.centerXAnchor),
                dot.topAnchor.constraint(equalTo: dotWrapper.topAnchor, constant: 5),
                dotWrapper.widthAnchor.constraint(equalToConstant: 8),
            ])

            let label = UILabel()
            label.text = tip
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.textColor = .secondaryLabel
            label.numberOfLines = 0

            row.addArrangedSubview(dotWrapper)
            row.addArrangedSubview(label)
            stack.addArrangedSubview(row)
        }

        card.addSubview(titleLabel)
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])

        return card
    }


    @objc private func openAchievements() {
        viewModel.onAchievementsTapped?()
    }

    @objc private func toggleTips() {
        tipsExpanded.toggle()
        let show = tipsExpanded

        actionButton.setTitle(show ? "Скрыть подсказки" : "Подсказки дня")

        if show {
            tipsCardView.isHidden = false
            tipsCardView.alpha = 0
            tipsCardView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }

        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3) {
            self.tipsCardView.alpha = show ? 1 : 0
            self.tipsCardView.transform = show ? .identity : CGAffineTransform(scaleX: 0.96, y: 0.96)
            if !show { self.tipsCardView.isHidden = true }
            self.contentStack.layoutIfNeeded()
        } completion: { _ in
            if !show { self.tipsCardView.isHidden = true }
        }
    }

    private func setupPhotoPlaceholder() {
        let cfg = UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
        let iconView = UIImageView(image: UIImage(systemName: "camera", withConfiguration: cfg))
        iconView.tintColor = UIColor.systemGray3
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        photoPlaceholder.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: photoPlaceholder.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: photoPlaceholder.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
}
