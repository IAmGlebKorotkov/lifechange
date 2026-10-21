//
//  AnalysisMetricCardView.swift
//  lifeisgame
//
//  Карточка метрики в сетке 2×2 на экране «Анализ дня».
//

import UIKit

final class AnalysisMetricCardView: UIView {

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .textSecondaryToken
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.isHidden = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressTrack: UIView = {
        let view = UIView()
        view.backgroundColor = .progressTrackToken
        view.layer.cornerRadius = 2.5
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let progressFill: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var fillFraction: CGFloat = 0
    private var fillWidthConstraint: NSLayoutConstraint?

    init(caption: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 18
        applyCardShadow(strength: 0.85)
        captionLabel.text = caption
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        progressTrack.addSubview(progressFill)

        let bottomRow = UIStackView(arrangedSubviews: [statusLabel, progressTrack])
        bottomRow.axis = .horizontal
        bottomRow.spacing = 6
        bottomRow.alignment = .center
        bottomRow.translatesAutoresizingMaskIntoConstraints = false

        addSubview(captionLabel)
        addSubview(valueLabel)
        addSubview(bottomRow)

        fillWidthConstraint = progressFill.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            captionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

            valueLabel.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 3),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

            bottomRow.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 9),
            bottomRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            bottomRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            bottomRow.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            progressTrack.heightAnchor.constraint(equalToConstant: 5),

            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),
            fillWidthConstraint!
        ])
    }

    func setFraction(completed: Int, total: Int, tint: UIColor = .main) {
        let value = NSMutableAttributedString(
            string: "\(completed)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.label
            ]
        )
        value.append(NSAttributedString(
            string: " / \(total)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor(rgb: 0x3C3C43, alpha: 0.4)
            ]
        ))
        valueLabel.attributedText = value
        statusLabel.isHidden = true
        setProgress(total > 0 ? CGFloat(completed) / CGFloat(total) : 0, tint: tint)
    }

    func setPercent(_ value: Double, tint: UIColor, statusText: String? = nil) {
        let clamped = max(0, min(1, value))
        let attributed = NSMutableAttributedString(
            string: "\(Int((clamped * 100).rounded()))",
            attributes: [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.label
            ]
        )
        attributed.append(NSAttributedString(
            string: "%",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                .foregroundColor: UIColor.label
            ]
        ))
        valueLabel.attributedText = attributed

        statusLabel.text = statusText
        statusLabel.textColor = tint
        statusLabel.isHidden = statusText == nil

        setProgress(CGFloat(clamped), tint: tint)
    }

    private func setProgress(_ fraction: CGFloat, tint: UIColor) {
        fillFraction = fraction
        progressFill.backgroundColor = tint
        updateFill(animated: window != nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateFill(animated: false)
    }

    private func updateFill(animated: Bool) {
        fillWidthConstraint?.constant = progressTrack.bounds.width * fillFraction
        guard animated else {
            layoutIfNeeded()
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}
