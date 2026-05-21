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

    private let focusButton: UIButton = {
        let b = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        b.setImage(UIImage(systemName: "play.fill", withConfiguration: cfg), for: .normal)
        b.setTitle("Старт", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.tintColor = .white
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor.main.withAlphaComponent(0.82)
        b.layer.cornerRadius = 28
        b.semanticContentAttribute = .forceLeftToRight
        b.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        b.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

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

    private let tipsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализ дня"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let readinessBadgeLabel: UILabel = {
        let label = UILabel()
        label.text = "--"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = UIColor.main
        label.textAlignment = .center
        label.backgroundColor = UIColor.main.withAlphaComponent(0.10)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tipsSummaryLabel: UILabel = {
        let label = UILabel()
        label.text = "Собираю сон, эмоции и задачи..."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let signalsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let tipsListStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let tasksCard = WeeklyStatCardView(style: .taskCount(
        title: "Выполнено задач за неделю",
        completed: 0,
        total: 0
    ))

    private let sleepCard = WeeklyStatCardView(style: .percentage(
        title: "Качество сна",
        value: 0
    ))

    private let efficiencyCard = WeeklyStatCardView(style: .percentage(
        title: "Эффективность",
        value: 0
    ))

    private let moodCard = WeeklyStatCardView(style: .percentage(
        title: "Настроение за неделю",
        value: 0
    ))


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupLayout()
        bindViewModel()
        observeChanges()
        showLoadingAnalysis()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadAnalysis()
    }


    private func setupLayout() {
        setupPhotoPlaceholder()

        view.addSubview(scrollView)
        view.addSubview(trophyButton)
        view.addSubview(focusButton)
        scrollView.addSubview(contentStack)

        trophyButton.addTarget(self, action: #selector(openAchievements), for: .touchUpInside)
        trophyButton.enablePressScale(to: 0.90)
        focusButton.addTarget(self, action: #selector(openFocus), for: .touchUpInside)
        focusButton.enablePressScale()

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

            focusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            focusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -96),
            focusButton.widthAnchor.constraint(equalToConstant: 116),
            focusButton.heightAnchor.constraint(equalToConstant: 56),
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

        let headerStack = UIStackView(arrangedSubviews: [tipsTitleLabel, readinessBadgeLabel])
        headerStack.axis = .horizontal
        headerStack.spacing = 10
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(headerStack)
        stack.addArrangedSubview(tipsSummaryLabel)
        stack.addArrangedSubview(signalsStack)
        stack.addArrangedSubview(tipsListStack)

        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),

            readinessBadgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 74),
            readinessBadgeLabel.heightAnchor.constraint(equalToConstant: 24),
        ])

        return card
    }

    private func bindViewModel() {
        viewModel.onAnalysisLoadingChanged = { [weak self] isLoading in
            guard isLoading else { return }
            self?.showLoadingAnalysis()
        }

        viewModel.onAnalysisChanged = { [weak self] analysis in
            self?.applyAnalysis(analysis)
        }

        viewModel.onAnalysisError = { [weak self] message in
            self?.showAnalysisError(message)
        }

        viewModel.onWeeklyStatsChanged = { [weak self] stats in
            self?.applyWeeklyStats(stats)
        }
    }

    private func observeChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadAnalysis),
            name: .diaryStoreDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadAnalysis),
            name: .taskStoreDidChange,
            object: nil
        )
    }

    @objc private func reloadAnalysis() {
        viewModel.loadAnalysis()
    }

    private func showLoadingAnalysis() {
        tipsTitleLabel.text = "Анализ дня"
        readinessBadgeLabel.text = "--"
        readinessBadgeLabel.textColor = UIColor.main
        readinessBadgeLabel.backgroundColor = UIColor.main.withAlphaComponent(0.10)
        tipsSummaryLabel.text = "Собираю сон, эмоции, возраст и нагрузку по задачам..."

        clearStack(signalsStack)
        clearStack(tipsListStack)
        signalsStack.addArrangedSubview(makeSignalRow("Идет расчет нагрузки"))
        tipsListStack.addArrangedSubview(makePlainAdviceRow("Скоро здесь появятся персональные рекомендации."))
    }

    private func applyAnalysis(_ analysis: UserAnalysisResult) {
        tipsTitleLabel.text = analysis.workloadLevel.title
        tipsSummaryLabel.text = analysis.summary
        readinessBadgeLabel.text = "\(analysis.readinessScore)/100"
        readinessBadgeLabel.textColor = color(for: analysis.readinessScore)
        readinessBadgeLabel.backgroundColor = color(for: analysis.readinessScore).withAlphaComponent(0.10)

        clearStack(signalsStack)
        analysis.signals.forEach { signalsStack.addArrangedSubview(makeSignalRow($0)) }

        clearStack(tipsListStack)
        analysis.advices.forEach { tipsListStack.addArrangedSubview(makeAdviceRow($0)) }
    }

    private func showAnalysisError(_ message: String) {
        tipsTitleLabel.text = "Анализ недоступен"
        readinessBadgeLabel.text = "--"
        readinessBadgeLabel.textColor = .systemOrange
        readinessBadgeLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.10)
        tipsSummaryLabel.text = message

        clearStack(signalsStack)
        clearStack(tipsListStack)
        tipsListStack.addArrangedSubview(makePlainAdviceRow("Проверь данные профиля, сна, эмоций и задач, затем открой подсказки снова."))
    }

    private func applyWeeklyStats(_ stats: GeneralWeeklyStats) {
        tasksCard.configure(
            style: .taskCount(
                title: "Выполнено задач за неделю",
                completed: stats.completedTasks,
                total: stats.totalTasks
            )
        )
        sleepCard.configure(
            style: .percentage(
                title: "Качество сна",
                value: stats.sleepQuality
            )
        )
        efficiencyCard.configure(
            style: .percentage(
                title: "Эффективность",
                value: stats.efficiency
            )
        )
        moodCard.configure(
            style: .percentage(
                title: "Настроение за неделю",
                value: stats.mood
            )
        )
    }

    private func clearStack(_ stack: UIStackView) {
        stack.arrangedSubviews.forEach {
            stack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    private func makeSignalRow(_ text: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center

        let dot = UIView()
        dot.backgroundColor = UIColor.main.withAlphaComponent(0.70)
        dot.layer.cornerRadius = 3
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 6).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 6).isActive = true

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0

        row.addArrangedSubview(dot)
        row.addArrangedSubview(label)
        return row
    }

    private func makeAdviceRow(_ advice: UserAnalysisAdvice) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .top

        let iconBg = UIView()
        iconBg.backgroundColor = color(for: advice.priority).withAlphaComponent(0.10)
        iconBg.layer.cornerRadius = 14
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iconBg.heightAnchor.constraint(equalToConstant: 28).isActive = true

        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        let iconView = UIImageView(image: UIImage(systemName: advice.sfSymbol, withConfiguration: cfg))
        iconView.tintColor = color(for: advice.priority)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),
        ])

        let titleLabel = UILabel()
        titleLabel.text = advice.title
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        let messageLabel = UILabel()
        messageLabel.text = advice.message
        messageLabel.font = .systemFont(ofSize: 13, weight: .regular)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        textStack.axis = .vertical
        textStack.spacing = 3

        row.addArrangedSubview(iconBg)
        row.addArrangedSubview(textStack)
        return row
    }

    private func makePlainAdviceRow(_ text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }

    private func color(for score: Int) -> UIColor {
        switch score {
        case 76...100:
            return UIColor.main
        case 52..<76:
            return .systemOrange
        default:
            return .systemRed
        }
    }

    private func color(for priority: UserAdvicePriority) -> UIColor {
        switch priority {
        case .high:
            return .systemRed
        case .medium:
            return .systemOrange
        case .info:
            return UIColor.main
        }
    }


    @objc private func openAchievements() {
        viewModel.onAchievementsTapped?()
    }

    @objc private func openFocus() {
        viewModel.onFocusTapped?()
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
