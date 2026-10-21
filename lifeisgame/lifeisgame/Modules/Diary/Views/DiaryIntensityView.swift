//
//  DiaryIntensityView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class DiaryIntensityView: UIView {

    var value: Int { Int(slider.value.rounded()) }


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Интенсивность"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let valueBadge: UILabel = {
        let l = PaddedBadgeLabel()
        l.text = "5 / 10"
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.layer.cornerRadius = 8
        l.layer.masksToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let slider: UISlider = {
        let s = UISlider()
        s.minimumValue = 1
        s.maximumValue = 10
        s.value = 5
        s.minimumTrackTintColor = UIColor.main
        s.maximumTrackTintColor = UIColor(rgb: 0x787880, alpha: 0.18)
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 18
        applyCardShadow(strength: 0.7)

        addSubview(titleLabel)
        addSubview(valueBadge)
        addSubview(slider)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            valueBadge.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            valueBadge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            slider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])

        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        updateBadge()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func reset() {
        slider.setValue(5, animated: false)
        updateBadge()
    }


    @objc private func sliderChanged() {
        updateBadge()
    }

    private func updateBadge() {
        valueBadge.text = "\(value) / 10"
        let colors = IntensityColors(value: CGFloat(slider.value))
        valueBadge.textColor = colors.tint
        valueBadge.backgroundColor = colors.badgeBackground
        slider.minimumTrackTintColor = colors.tint
    }
}

private struct IntensityColors {

    let tint: UIColor
    let badgeBackground: UIColor

    init(value: CGFloat) {
        let lowTint = UIColor(rgb: 0xE2402F)
        let middleTint = UIColor(rgb: 0xE8920C)
        let highTint = UIColor(rgb: 0x1E9E63)
        let lowBackground = UIColor(rgb: 0xFFDFDA)
        let middleBackground = UIColor(rgb: 0xFFEDCF)
        let highBackground = UIColor(rgb: 0xDDF7E8)

        if value <= 5 {
            let progress = max(0, min(1, (value - 1) / 4))
            tint = UIColor.interpolate(from: lowTint, to: middleTint, progress: progress)
            badgeBackground = UIColor.interpolate(
                from: lowBackground,
                to: middleBackground,
                progress: progress
            )
        } else {
            let progress = max(0, min(1, (value - 5) / 5))
            tint = UIColor.interpolate(from: middleTint, to: highTint, progress: progress)
            badgeBackground = UIColor.interpolate(
                from: middleBackground,
                to: highBackground,
                progress: progress
            )
        }
    }
}

private extension UIColor {

    static func interpolate(from start: UIColor, to end: UIColor, progress: CGFloat) -> UIColor {
        var startRed: CGFloat = 0
        var startGreen: CGFloat = 0
        var startBlue: CGFloat = 0
        var startAlpha: CGFloat = 0
        var endRed: CGFloat = 0
        var endGreen: CGFloat = 0
        var endBlue: CGFloat = 0
        var endAlpha: CGFloat = 0

        start.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        end.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)

        return UIColor(
            red: startRed + (endRed - startRed) * progress,
            green: startGreen + (endGreen - startGreen) * progress,
            blue: startBlue + (endBlue - startBlue) * progress,
            alpha: startAlpha + (endAlpha - startAlpha) * progress
        )
    }
}

private final class PaddedBadgeLabel: UILabel {

    private let insets = UIEdgeInsets(top: 3, left: 9, bottom: 3, right: 9)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}
