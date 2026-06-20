//
//  DayAnalysisTipsCardView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class DayAnalysisTipsCardView: CardContainerView {

    private let titleLabel: UILabel = {
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

    private let summaryLabel: UILabel = {
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

    private let advicesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(cornerRadius: CGFloat = 16) {
        super.init(cornerRadius: cornerRadius)
        setupLayout()
        showLoading()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func showLoading() {
        titleLabel.text = "Анализ дня"
        configureBadge(text: "--", color: UIColor.main)
        summaryLabel.text = "Собираю сон, эмоции, возраст и нагрузку по задачам..."

        clearStack(signalsStack)
        clearStack(advicesStack)
        signalsStack.addArrangedSubview(makeSignalRow("Идет расчет нагрузки"))
        advicesStack.addArrangedSubview(makePlainAdviceRow("Скоро здесь появятся персональные рекомендации."))
    }

    func apply(_ analysis: UserAnalysisResult) {
        titleLabel.text = analysis.workloadLevel.title
        summaryLabel.text = analysis.summary
        configureBadge(text: "\(analysis.readinessScore)/100", color: color(for: analysis.readinessScore))

        clearStack(signalsStack)
        analysis.signals.forEach { signalsStack.addArrangedSubview(makeSignalRow($0)) }

        clearStack(advicesStack)
        analysis.advices.forEach { advicesStack.addArrangedSubview(makeAdviceRow($0)) }
    }

    func showError(_ message: String) {
        titleLabel.text = "Анализ недоступен"
        configureBadge(text: "--", color: .systemOrange)
        summaryLabel.text = message

        clearStack(signalsStack)
        clearStack(advicesStack)
        advicesStack.addArrangedSubview(makePlainAdviceRow("Проверь данные профиля, сна, эмоций и задач, затем открой подсказки снова."))
    }

    private func setupLayout() {
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, readinessBadgeLabel])
        headerStack.axis = .horizontal
        headerStack.spacing = 10
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [headerStack, summaryLabel, signalsStack, advicesStack])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            readinessBadgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 74),
            readinessBadgeLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func configureBadge(text: String, color: UIColor) {
        readinessBadgeLabel.text = text
        readinessBadgeLabel.textColor = color
        readinessBadgeLabel.backgroundColor = color.withAlphaComponent(0.10)
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

        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        let iconView = UIImageView(image: UIImage(systemName: advice.sfSymbol, withConfiguration: config))
        iconView.tintColor = color(for: advice.priority)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16)
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
}
