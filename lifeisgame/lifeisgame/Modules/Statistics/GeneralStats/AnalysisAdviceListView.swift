//
//  AnalysisAdviceListView.swift
//  lifeisgame
//

import UIKit

final class AnalysisAdviceListView: UIStackView {

    private let visibleLimit: Int
    private var currentAdvices: [UserAnalysisAdvice] = []
    private var isShowingAllAdvices = false

    private let listStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 13
        return stack
    }()

    private lazy var showMoreButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .main
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 6
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var updated = attributes
            updated.font = .preferredFont(forTextStyle: .footnote)
            return updated
        }

        let button = UIButton(configuration: configuration)
        button.contentHorizontalAlignment = .leading
        button.accessibilityIdentifier = "dayAnalysis.showMore"
        button.accessibilityHint = "Показывает или скрывает дополнительные рекомендации"
        button.addTarget(self, action: #selector(toggleAllAdvices), for: .touchUpInside)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        return button
    }()

    init(visibleLimit: Int) {
        self.visibleLimit = visibleLimit
        super.init(frame: .zero)
        setupLayout()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func apply(_ advices: [UserAnalysisAdvice]) {
        currentAdvices = advices
        isShowingAllAdvices = false
        updateRows()
    }

    func showPlaceholder(_ text: String) {
        currentAdvices = []
        isShowingAllAdvices = false
        clearList()
        listStack.addArrangedSubview(makePlainRow(text))
    }

    private func setupLayout() {
        let titleLabel = UILabel()
        titleLabel.text = "Рекомендации"
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.accessibilityTraits = .header

        axis = .vertical
        spacing = 12
        addArrangedSubview(titleLabel)
        addArrangedSubview(listStack)
    }

    private func updateRows() {
        clearList()
        let visibleAdvices = isShowingAllAdvices
            ? currentAdvices
            : Array(currentAdvices.prefix(visibleLimit))

        if visibleAdvices.isEmpty {
            listStack.addArrangedSubview(makePlainRow("На сегодня дополнительных рекомендаций нет."))
            return
        }

        visibleAdvices.forEach { listStack.addArrangedSubview(makeAdviceRow($0)) }
        guard currentAdvices.count > visibleLimit else { return }

        let hiddenCount = currentAdvices.count - visibleLimit
        showMoreButton.configuration?.title = isShowingAllAdvices ? "Скрыть" : "Показать ещё \(hiddenCount)"
        showMoreButton.configuration?.image = UIImage(
            systemName: isShowingAllAdvices ? "chevron.up" : "chevron.down"
        )
        showMoreButton.accessibilityValue = isShowingAllAdvices ? "развёрнуто" : "свёрнуто"
        listStack.addArrangedSubview(showMoreButton)
    }

    @objc private func toggleAllAdvices() {
        window?.layoutIfNeeded()
        isShowingAllAdvices.toggle()
        updateRows()
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState]
        ) {
            self.window?.layoutIfNeeded()
        }
    }

    private func clearList() {
        listStack.arrangedSubviews.forEach {
            listStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    private func makeAdviceRow(_ advice: UserAnalysisAdvice) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .top
        row.isAccessibilityElement = true
        row.accessibilityLabel = advice.title
        row.accessibilityValue = advice.message
        row.accessibilityIdentifier = "dayAnalysis.adviceRow"

        let colors = tileColors(for: advice.priority)
        let iconBackground = makeIconBackground(advice: advice, colors: colors)

        let adviceTitleLabel = UILabel()
        let titleFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        adviceTitleLabel.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(
            for: titleFont,
            maximumPointSize: 20
        )
        adviceTitleLabel.adjustsFontForContentSizeCategory = true
        adviceTitleLabel.text = advice.title
        adviceTitleLabel.textColor = .label
        adviceTitleLabel.numberOfLines = 2

        let messageLabel = UILabel()
        messageLabel.text = advice.message
        messageLabel.font = .preferredFont(forTextStyle: .footnote)
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textColor = .textSecondaryToken
        messageLabel.numberOfLines = 0
        messageLabel.accessibilityIdentifier = "dayAnalysis.adviceMessage"

        let textStack = UIStackView(arrangedSubviews: [adviceTitleLabel, messageLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        row.addArrangedSubview(iconBackground)
        row.addArrangedSubview(textStack)
        return row
    }

    private func makeIconBackground(
        advice: UserAnalysisAdvice,
        colors: (tile: UIColor, tint: UIColor)
    ) -> UIView {
        let background = UIView()
        background.backgroundColor = colors.tile
        background.layer.cornerRadius = 10
        background.translatesAutoresizingMaskIntoConstraints = false
        background.widthAnchor.constraint(equalToConstant: 36).isActive = true
        background.heightAnchor.constraint(equalToConstant: 36).isActive = true
        background.isAccessibilityElement = false

        let configuration = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let iconView = UIImageView(
            image: UIImage(systemName: advice.sfSymbol, withConfiguration: configuration)
        )
        iconView.tintColor = colors.tint
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.isAccessibilityElement = false
        background.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18)
        ])
        return background
    }

    private func makePlainRow(_ text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .textSecondaryToken
        label.numberOfLines = 0
        return label
    }

    private func tileColors(for priority: UserAdvicePriority) -> (tile: UIColor, tint: UIColor) {
        switch priority {
        case .high:
            return (UIColor(rgb: 0xFFDFDA), UIColor(rgb: 0xE2402F))
        case .medium:
            return (UIColor(rgb: 0xFFEDCF), UIColor(rgb: 0xE8920C))
        case .info:
            return (UIColor(rgb: 0xEAE2FF), .appSleepPurple)
        }
    }
}
