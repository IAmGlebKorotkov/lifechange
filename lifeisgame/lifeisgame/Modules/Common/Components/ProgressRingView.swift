//
//  ProgressRingView.swift
//  lifeisgame
//
//  Кольцевой индикатор прогресса (заголовок календаря, карточка готовности).
//

import UIKit

final class ProgressRingView: UIView {

    private let ringSize: CGFloat
    private let ringLineWidth: CGFloat
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    private(set) var progress: CGFloat = 0

    init(
        size: CGFloat,
        lineWidth: CGFloat,
        trackColor: UIColor = UIColor(rgb: 0x3C3C43, alpha: 0.13),
        progressColor: UIColor = .main
    ) {
        ringSize = size
        ringLineWidth = lineWidth
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = lineWidth

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0

        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (ringSize - ringLineWidth) / 2
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: .pi * 1.5,
            clockwise: true
        )
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }

    func setProgress(_ value: CGFloat, animated: Bool = true) {
        let clamped = max(0, min(1, value))
        let previous = progress
        progress = clamped

        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = previous
            animation.toValue = clamped
            animation.duration = 0.45
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            progressLayer.add(animation, forKey: "progress")
        }
        progressLayer.strokeEnd = clamped
    }

    func setProgressColor(_ color: UIColor) {
        progressLayer.strokeColor = color.cgColor
    }
}
