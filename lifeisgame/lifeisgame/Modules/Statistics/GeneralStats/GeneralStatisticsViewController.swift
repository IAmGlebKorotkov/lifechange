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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализ дня"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

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

    private let tipsCardView = DayAnalysisTipsCardView()

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
        view.addSubview(scrollView)
        view.addSubview(trophyButton)
        view.addSubview(focusButton)
        scrollView.addSubview(contentStack)

        trophyButton.addTarget(self, action: #selector(openAchievements), for: .touchUpInside)
        trophyButton.enablePressScale(to: 0.90)
        focusButton.addTarget(self, action: #selector(openFocus), for: .touchUpInside)
        focusButton.enablePressScale()

        contentStack.addArrangedSubview(titleLabel)
        contentStack.setCustomSpacing(16, after: titleLabel)
        contentStack.addArrangedSubview(tipsCardView)
        contentStack.setCustomSpacing(20, after: tipsCardView)

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

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
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
            focusButton.widthAnchor.constraint(equalToConstant: 116),
            focusButton.heightAnchor.constraint(equalToConstant: 56),
        ])
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

    @objc private func openAchievements() {
        viewModel.onAchievementsTapped?()
    }

    @objc private func openFocus() {
        viewModel.onFocusTapped?()
    }
}
