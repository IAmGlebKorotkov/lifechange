//
//  DayAnalysisTipsCardView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class DayAnalysisTipsCardView: CardContainerView {

    private let ringView = ProgressRingView(size: 76, lineWidth: 6)
    private let resourceMetricView = AnalysisMiniMetricView(title: "ресурс", color: .main)
    private let loadMetricView = AnalysisMiniMetricView(title: "нагрузка", color: .systemGreen)
    private let confidenceMetricView = AnalysisMiniMetricView(title: "точность", color: .systemBlue)
    private let adviceListView = AnalysisAdviceListView(visibleLimit: 2)

    private let scoreLabel: UILabel = {
        let label = UILabel()
        let baseFont = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.font = UIFontMetrics(forTextStyle: .title2).scaledFont(
            for: baseFont,
            maximumPointSize: 30
        )
        label.adjustsFontForContentSizeCategory = true
        label.text = "--"
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let scoreCaptionLabel: UILabel = {
        let label = UILabel()
        label.text = "баланс"
        label.font = .preferredFont(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .textSecondaryToken
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        let baseFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.font = UIFontMetrics(forTextStyle: .title3).scaledFont(
            for: baseFont,
            maximumPointSize: 26
        )
        label.adjustsFontForContentSizeCategory = true
        label.text = "Анализ дня"
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .textSecondaryToken
        label.numberOfLines = 2
        return label
    }()

    private lazy var statusStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 3
        stack.isAccessibilityElement = true
        return stack
    }()

    private lazy var metricsStack: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [resourceMetricView, loadMetricView, confidenceMetricView]
        )
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.separator.withAlphaComponent(0.55)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return view
    }()

    override init(cornerRadius: CGFloat = 22) {
        super.init(cornerRadius: cornerRadius)
        applyCardShadow(strength: 1.15)
        setupLayout()
        showLoading()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func showLoading() {
        titleLabel.text = "Анализ дня"
        subtitleLabel.text = "Собираем данные…"
        statusStack.accessibilityLabel = "Анализ дня. Собираем данные"
        configureMainRing(value: nil, accessibilityValue: "рассчитывается", animated: false)
        resourceMetricView.configure(value: nil, status: "считаем", color: .main, animated: false)
        loadMetricView.configure(value: nil, status: "считаем", color: .systemGreen, animated: false)
        confidenceMetricView.configure(value: nil, status: "считаем", color: .systemBlue, animated: false)

        adviceListView.showPlaceholder("Персональные рекомендации скоро появятся.")
    }

    func apply(_ analysis: UserAnalysisResult) {
        let title = statusTitle(for: analysis)
        let subtitle = statusSubtitle(for: analysis)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        statusStack.accessibilityLabel = "\(title). \(subtitle). \(analysis.summary)"

        let balanceValue = analysis.confidenceLevel == .low ? nil : analysis.balanceScore
        configureMainRing(
            value: balanceValue,
            accessibilityValue: balanceValue.map { "\($0) из 100" } ?? "предварительная оценка"
        )

        resourceMetricView.configure(
            value: analysis.resourceScore,
            status: resourceStatus(for: analysis.resourceScore),
            color: .main
        )
        loadMetricView.configure(
            value: analysis.loadScore,
            status: loadStatus(for: analysis.loadScore),
            color: loadColor(for: analysis.loadScore)
        )
        confidenceMetricView.configure(
            value: analysis.confidenceScore,
            status: analysis.confidenceLevel.title,
            color: confidenceColor(for: analysis.confidenceLevel)
        )

        adviceListView.apply(analysis.advices)
    }

    func showError(_ message: String) {
        titleLabel.text = "Анализ недоступен"
        subtitleLabel.text = "Не удалось собрать данные"
        statusStack.accessibilityLabel = "Анализ недоступен. \(message)"
        configureMainRing(value: nil, accessibilityValue: "нет данных", animated: false)
        resourceMetricView.configure(value: nil, status: "нет данных", color: .main, animated: false)
        loadMetricView.configure(value: nil, status: "нет данных", color: .systemGreen, animated: false)
        confidenceMetricView.configure(value: nil, status: "нет данных", color: .systemBlue, animated: false)

        adviceListView.showPlaceholder(message)
    }

    private func setupLayout() {
        let scoreStack = UIStackView(arrangedSubviews: [scoreLabel, scoreCaptionLabel])
        scoreStack.axis = .vertical
        scoreStack.spacing = 1
        scoreStack.alignment = .center
        scoreStack.translatesAutoresizingMaskIntoConstraints = false
        ringView.addSubview(scoreStack)
        ringView.isAccessibilityElement = true
        ringView.accessibilityLabel = "Баланс дня"

        let headerStack = UIStackView(arrangedSubviews: [ringView, statusStack])
        headerStack.axis = .horizontal
        headerStack.spacing = 16
        headerStack.alignment = .center

        let stack = UIStackView(
            arrangedSubviews: [headerStack, metricsStack, divider, adviceListView]
        )
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            scoreStack.centerXAnchor.constraint(equalTo: ringView.centerXAnchor),
            scoreStack.centerYAnchor.constraint(equalTo: ringView.centerYAnchor),

            stack.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18)
        ])
    }

    private func configureMainRing(
        value: Int?,
        accessibilityValue: String,
        animated: Bool = true
    ) {
        scoreLabel.text = value.map(String.init) ?? "--"
        ringView.setProgress(value.map { CGFloat($0) / 100 } ?? 0, animated: animated)
        ringView.accessibilityValue = accessibilityValue
    }

    private func statusTitle(for analysis: UserAnalysisResult) -> String {
        if analysis.confidenceLevel == .low {
            return "Нужно больше данных"
        }
        if analysis.resourceScore < 45 && analysis.loadScore < 45 {
            return "Свободный день"
        }
        if analysis.resourceScore < 45 {
            return "Ресурс снижен"
        }
        if analysis.loadScore >= 78 {
            return "Нужна разгрузка"
        }
        if analysis.loadScore >= 58 {
            return "Нагрузка высокая"
        }
        if analysis.resourceScore >= 70 && analysis.loadScore < 45 {
            return "Есть запас ресурса"
        }
        return "День сбалансирован"
    }

    private func statusSubtitle(for analysis: UserAnalysisResult) -> String {
        if analysis.confidenceLevel == .low {
            return "Предварительная оценка"
        }
        if analysis.resourceScore < 45 && analysis.loadScore < 45 {
            return "Низкая нагрузка — время восстановиться"
        }
        if analysis.resourceScore < 45 {
            return "План выше текущего ресурса"
        }
        if analysis.loadScore >= 78 {
            return "План больше доступного времени"
        }
        if analysis.loadScore >= 58 {
            return "Сосредоточься на главном"
        }
        if analysis.resourceScore >= 70 && analysis.loadScore < 45 {
            return "Есть место для важной задачи"
        }
        return "Ресурс соответствует плану"
    }

    private func resourceStatus(for value: Int) -> String {
        switch value {
        case 0..<45:
            return "снижен"
        case 45..<70:
            return "средний"
        default:
            return "высокий"
        }
    }

    private func loadStatus(for value: Int) -> String {
        switch value {
        case 0..<45:
            return "низкая"
        case 45..<70:
            return "средняя"
        default:
            return "высокая"
        }
    }

    private func loadColor(for value: Int) -> UIColor {
        switch value {
        case 0..<45:
            return .systemGreen
        case 45..<70:
            return .systemOrange
        default:
            return .systemRed
        }
    }

    private func confidenceColor(for level: UserAnalysisConfidenceLevel) -> UIColor {
        switch level {
        case .low:
            return .systemGray
        case .medium:
            return .systemBlue
        case .high:
            return .systemTeal
        }
    }

}
