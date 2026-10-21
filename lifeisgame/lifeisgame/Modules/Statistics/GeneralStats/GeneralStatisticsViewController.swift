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
        sv.clipsToBounds = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 13
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализ дня"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textSecondaryToken
        return label
    }()

    private let focusButton: UIButton = {
        let b = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        b.setImage(UIImage(systemName: "play.fill", withConfiguration: cfg), for: .normal)
        b.setTitle("Фокус", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.tintColor = .white
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .main
        b.layer.cornerRadius = 25
        b.semanticContentAttribute = .forceLeftToRight
        b.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        b.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.applyPrimaryButtonShadow()
        return b
    }()

    private let trophyButton: UIButton = {
        let b = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        b.setImage(UIImage(systemName: "trophy.fill", withConfiguration: cfg), for: .normal)
        b.tintColor = UIColor.main
        b.backgroundColor = UIColor.lightMain
        b.layer.cornerRadius = 22
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let tipsCardView = DayAnalysisTipsCardView()

    private let tasksCard = AnalysisMetricCardView(caption: "Выполнено за неделю")
    private let sleepCard = AnalysisMetricCardView(caption: "Сон")
    private let efficiencyCard = AnalysisMetricCardView(caption: "Эффективность")
    private let moodCard = AnalysisMetricCardView(caption: "Настроение")


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
        view.addSubview(scrollView)
        view.addSubview(trophyButton)
        view.addSubview(focusButton)
        scrollView.addSubview(contentStack)

        trophyButton.addTarget(self, action: #selector(openAchievements), for: .touchUpInside)
        trophyButton.enablePressScale(to: 0.90)
        focusButton.addTarget(self, action: #selector(openFocus), for: .touchUpInside)
        focusButton.enablePressScale()

        dateLabel.text = formattedToday()

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 1
        headerStack.alignment = .leading

        contentStack.addArrangedSubview(headerStack)
        contentStack.setCustomSpacing(16, after: headerStack)
        contentStack.addArrangedSubview(tipsCardView)

        let topRow = UIStackView(arrangedSubviews: [tasksCard, sleepCard])
        topRow.axis = .horizontal
        topRow.spacing = 11
        topRow.distribution = .fillEqually

        let bottomRow = UIStackView(arrangedSubviews: [efficiencyCard, moodCard])
        bottomRow.axis = .horizontal
        bottomRow.spacing = 11
        bottomRow.distribution = .fillEqually

        contentStack.addArrangedSubview(topRow)
        contentStack.setCustomSpacing(11, after: topRow)
        contentStack.addArrangedSubview(bottomRow)

        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 170, right: 0)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),

            trophyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            trophyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            trophyButton.widthAnchor.constraint(equalToConstant: 44),
            trophyButton.heightAnchor.constraint(equalToConstant: 44),

            focusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            focusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -96),
            focusButton.widthAnchor.constraint(equalToConstant: 118),
            focusButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"
        let text = formatter.string(from: Date())
        return text.prefix(1).uppercased() + text.dropFirst()
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
        tipsCardView.showLoading()
    }

    private func applyAnalysis(_ analysis: UserAnalysisResult) {
        tipsCardView.apply(analysis)
    }

    private func showAnalysisError(_ message: String) {
        tipsCardView.showError(message)
    }

    private func applyWeeklyStats(_ stats: GeneralWeeklyStats) {
        tasksCard.setFraction(completed: stats.completedTasks, total: stats.totalTasks)
        sleepCard.setPercent(stats.sleepQuality, tint: .appSuccess, statusText: qualityWord(stats.sleepQuality))
        efficiencyCard.setPercent(stats.efficiency, tint: .main)
        moodCard.setPercent(stats.mood, tint: moodColor(stats.mood), statusText: moodWord(stats.mood))
    }

    private func qualityWord(_ value: Double) -> String {
        switch value {
        case 0.7...: return "Хорошо"
        case 0.4..<0.7: return "Средне"
        default: return "Мало"
        }
    }

    private func moodWord(_ value: Double) -> String {
        switch value {
        case 0.7...: return "Отлично"
        case 0.4..<0.7: return "Ровно"
        default: return "Так себе"
        }
    }

    private func moodColor(_ value: Double) -> UIColor {
        switch value {
        case 0.7...: return .appSuccess
        case 0.4..<0.7: return .appWarning
        default: return .appDanger
        }
    }

    @objc private func openAchievements() {
        viewModel.onAchievementsTapped?()
    }

    @objc private func openFocus() {
        viewModel.onFocusTapped?()
    }
}
