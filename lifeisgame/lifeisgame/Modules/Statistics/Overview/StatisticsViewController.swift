//
//  StatisticsViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class StatisticsViewController: UIViewController {


    private let viewModel: StatisticsViewModel


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Статистика"
        l.font = .systemFont(ofSize: 30, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Эмоции · 30 дней"
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .textSecondaryToken
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let chipsView = StatsSegmentChipsView(items: ["Эмоции", "Сон", "Задачи"])

    private let statsContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emotionStatsView = EmotionStatsView()
    private let sleepStatsView   = SleepStatsView()
    private let taskStatsView    = TaskStatsView()
    private let maximumHeaderCollapse: CGFloat = 68
    private var selectedStatsIndex = 0


    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupLayout()
        setupScrollTracking()
        chipsView.onSelectionChanged = { [weak self] index in
            self?.showStats(for: index)
        }
        taskStatsView.presentingViewController = self
        bindViewModel()
        viewModel.viewDidLoad()
        showStats(for: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
    }


    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(chipsView)
        view.addSubview(statsContainer)

        statsContainer.addSubview(emotionStatsView)
        statsContainer.addSubview(sleepStatsView)
        statsContainer.addSubview(taskStatsView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),

            chipsView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),
            chipsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            chipsView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            statsContainer.topAnchor.constraint(equalTo: chipsView.bottomAnchor, constant: 6),
            statsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statsContainer.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: maximumHeaderCollapse
            ),

            emotionStatsView.topAnchor.constraint(equalTo: statsContainer.topAnchor),
            emotionStatsView.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor),
            emotionStatsView.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor),
            emotionStatsView.bottomAnchor.constraint(equalTo: statsContainer.bottomAnchor),

            sleepStatsView.topAnchor.constraint(equalTo: emotionStatsView.topAnchor),
            sleepStatsView.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor),
            sleepStatsView.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor),
            sleepStatsView.bottomAnchor.constraint(equalTo: emotionStatsView.bottomAnchor),

            taskStatsView.topAnchor.constraint(equalTo: emotionStatsView.topAnchor),
            taskStatsView.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor),
            taskStatsView.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor),
            taskStatsView.bottomAnchor.constraint(equalTo: emotionStatsView.bottomAnchor)
        ])
    }

    private func setupScrollTracking() {
        emotionStatsView.onVerticalScroll = { [weak self] offset in
            self?.handleVerticalScroll(offset, from: 0)
        }
        sleepStatsView.onVerticalScroll = { [weak self] offset in
            self?.handleVerticalScroll(offset, from: 1)
        }
        taskStatsView.onVerticalScroll = { [weak self] offset in
            self?.handleVerticalScroll(offset, from: 2)
        }
    }


    private func showStats(for index: Int) {
        selectedStatsIndex = index
        let showEmotion = (index == 0)
        let showSleep   = (index == 1)
        let showTask    = (index == 2)

        emotionStatsView.isHidden = false
        sleepStatsView.isHidden = false
        taskStatsView.isHidden = false

        updateHeader(for: verticalScrollOffset(at: index), animated: true)

        UIView.transition(with: subtitleLabel, duration: 0.25, options: .transitionCrossDissolve) {
            self.subtitleLabel.text = "\(self.viewModel.categoryName(at: index)) · 30 дней"
        }

        UIView.animate(withDuration: 0.25) {
            self.emotionStatsView.alpha = showEmotion ? 1 : 0
            self.sleepStatsView.alpha   = showSleep   ? 1 : 0
            self.taskStatsView.alpha    = showTask    ? 1 : 0
        } completion: { _ in
            self.emotionStatsView.isHidden = !showEmotion
            self.sleepStatsView.isHidden   = !showSleep
            self.taskStatsView.isHidden    = !showTask
        }
    }

    private func handleVerticalScroll(_ offset: CGFloat, from index: Int) {
        guard index == selectedStatsIndex else { return }
        updateHeader(for: offset, animated: false)
    }

    private func verticalScrollOffset(at index: Int) -> CGFloat {
        switch index {
        case 1:
            return sleepStatsView.verticalScrollOffset
        case 2:
            return taskStatsView.verticalScrollOffset
        default:
            return emotionStatsView.verticalScrollOffset
        }
    }

    private func updateHeader(for scrollOffset: CGFloat, animated: Bool) {
        let collapse = min(max(0, scrollOffset), maximumHeaderCollapse)
        let progress = collapse / maximumHeaderCollapse
        let changes = {
            let translation = CGAffineTransform(translationX: 0, y: -collapse)
            self.titleLabel.transform = translation
            self.subtitleLabel.transform = translation
            self.titleLabel.alpha = 1 - progress
            self.subtitleLabel.alpha = 1 - progress
            self.chipsView.transform = translation
            self.statsContainer.transform = translation

            self.emotionStatsView.applyHeaderCompensation(collapse)
            self.sleepStatsView.applyHeaderCompensation(collapse)
            self.taskStatsView.applyHeaderCompensation(collapse)
        }

        guard animated, !UIAccessibility.isReduceMotionEnabled else {
            changes()
            return
        }

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseInOut],
            animations: changes
        )
    }

    private func bindViewModel() {
        viewModel.onDiaryStatsLoaded = { [weak self] emotionEntries, sleepEntries in
            self?.emotionStatsView.configure(entries: emotionEntries)
            self?.sleepStatsView.configure(entries: sleepEntries)
        }
        viewModel.onTaskStatsLoaded = { [weak self] days in
            self?.taskStatsView.configure(days: days)
        }
    }
}
