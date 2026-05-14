//
//  StatisticsViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class StatisticsViewController: UIViewController {


    private let carouselHeight: CGFloat = 300

    private let categoryNames = ["Эмоции", "Сон", "Задачи"]
    private let repository: DiaryRepositoryProtocol


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Статистика"
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Эмоции"
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let carouselView = StatsCarouselView()

    private let statsContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.background
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor   = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset  = CGSize(width: 0, height: -4)
        v.layer.shadowRadius  = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emotionStatsView = EmotionStatsView()
    private let sleepStatsView   = SleepStatsView()
    private let taskStatsView    = TaskStatsView()


    init(repository: DiaryRepositoryProtocol) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupLayout()
        observeDiaryChanges()
        carouselView.onSelectionChanged = { [weak self] index in
            self?.showStats(for: index)
        }
        taskStatsView.presentingViewController = self
        loadDiaryStats()
        showStats(for: 0)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDiaryStats()
    }


    private func setupLayout() {
        carouselView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(carouselView)
        view.addSubview(statsContainer)

        statsContainer.addSubview(emotionStatsView)
        statsContainer.addSubview(sleepStatsView)
        statsContainer.addSubview(taskStatsView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            carouselView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            carouselView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            carouselView.widthAnchor.constraint(equalTo: view.widthAnchor),
            carouselView.heightAnchor.constraint(equalToConstant: carouselHeight),

            statsContainer.topAnchor.constraint(equalTo: carouselView.centerYAnchor),
            statsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emotionStatsView.topAnchor.constraint(equalTo: statsContainer.topAnchor, constant: 24),
            emotionStatsView.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor),
            emotionStatsView.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor),
            emotionStatsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

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


    private func showStats(for index: Int) {
        let showEmotion = (index == 0)
        let showSleep   = (index == 1)
        let showTask    = (index == 2)

        UIView.transition(with: subtitleLabel, duration: 0.25, options: .transitionCrossDissolve) {
            self.subtitleLabel.text = self.categoryNames[index]
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

    private func observeDiaryChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(diaryDidChange),
            name: .diaryStoreDidChange,
            object: nil
        )
    }

    @objc private func diaryDidChange() {
        loadDiaryStats()
    }

    private func loadDiaryStats() {
        guard let userID = SessionManager.shared.currentUserID else {
            emotionStatsView.configure(entries: [])
            sleepStatsView.configure(entries: [])
            return
        }

        do {
            emotionStatsView.configure(entries: try repository.fetchEmotionEntries(forUserID: userID))
            sleepStatsView.configure(entries: try repository.fetchSleepEntries(forUserID: userID))
        } catch {
            emotionStatsView.configure(entries: [])
            sleepStatsView.configure(entries: [])
        }
    }
}
