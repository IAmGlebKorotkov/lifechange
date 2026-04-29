//
//  GeneratePlanLoadingViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 09.04.2026.
//

import UIKit

final class GeneratePlanLoadingViewController: UIViewController {


    private let outerRingView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.main.withAlphaComponent(0.08)
        v.layer.cornerRadius = 80
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let middleRingView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.main.withAlphaComponent(0.14)
        v.layer.cornerRadius = 60
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let innerCircle: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.main
        v.layer.cornerRadius = 40
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let iconView: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "sparkles", withConfiguration: cfg))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let arcLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 3
        layer.lineCap = .round
        return layer
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Генерируем план"
        l.font = .systemFont(ofSize: 26, weight: .bold)
        l.textColor = .label
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let stepLabel: UILabel = {
        let l = UILabel()
        l.text = "Анализируем задачи..."
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()


    private let steps = [
        "Анализируем задачи...",
        "Строим структуру...",
        "Формируем шаги...",
        "Почти готово..."
    ]
    private var stepIndex = 0
    private var stepTimer: Timer?


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupArcLayer()
        startAnimations()
        scheduleTransition()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stepTimer?.invalidate()
    }


    private func setupLayout() {
        view.addSubview(outerRingView)
        view.addSubview(middleRingView)
        view.addSubview(innerCircle)
        innerCircle.addSubview(iconView)
        view.addSubview(titleLabel)
        view.addSubview(stepLabel)

        NSLayoutConstraint.activate([
            outerRingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            outerRingView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            outerRingView.widthAnchor.constraint(equalToConstant: 160),
            outerRingView.heightAnchor.constraint(equalToConstant: 160),

            middleRingView.centerXAnchor.constraint(equalTo: outerRingView.centerXAnchor),
            middleRingView.centerYAnchor.constraint(equalTo: outerRingView.centerYAnchor),
            middleRingView.widthAnchor.constraint(equalToConstant: 120),
            middleRingView.heightAnchor.constraint(equalToConstant: 120),

            innerCircle.centerXAnchor.constraint(equalTo: outerRingView.centerXAnchor),
            innerCircle.centerYAnchor.constraint(equalTo: outerRingView.centerYAnchor),
            innerCircle.widthAnchor.constraint(equalToConstant: 80),
            innerCircle.heightAnchor.constraint(equalToConstant: 80),

            iconView.centerXAnchor.constraint(equalTo: innerCircle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: innerCircle.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.topAnchor.constraint(equalTo: outerRingView.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            stepLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            stepLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stepLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }


    private func setupArcLayer() {
        let center = CGPoint(x: outerRingView.bounds.midX, y: outerRingView.bounds.midY)
        let path = UIBezierPath(
            arcCenter: center,
            radius: 76,
            startAngle: -.pi / 2,
            endAngle: -.pi / 2 + 2 * .pi,
            clockwise: true
        )
        arcLayer.path = path.cgPath
        arcLayer.strokeColor = UIColor.main.cgColor
        arcLayer.strokeEnd = 0
        outerRingView.layer.addSublayer(arcLayer)

        let trackLayer = CAShapeLayer()
        trackLayer.path = path.cgPath
        trackLayer.strokeColor = UIColor.main.withAlphaComponent(0.12).cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 3
        trackLayer.lineCap = .round
        outerRingView.layer.insertSublayer(trackLayer, below: arcLayer)
    }


    private func startAnimations() {
        let fillArc = CABasicAnimation(keyPath: "strokeEnd")
        fillArc.fromValue = 0
        fillArc.toValue = 1
        fillArc.duration = 3.5
        fillArc.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        fillArc.fillMode = .forwards
        fillArc.isRemovedOnCompletion = false
        arcLayer.add(fillArc, forKey: "arcFill")

        UIView.animate(
            withDuration: 1.2,
            delay: 0,
            options: [.repeat, .autoreverse, .curveEaseInOut]
        ) {
            self.outerRingView.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
        }

        UIView.animate(
            withDuration: 0.9,
            delay: 0.15,
            options: [.repeat, .autoreverse, .curveEaseInOut]
        ) {
            self.innerCircle.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }

        view.alpha = 0
        UIView.animate(withDuration: 0.4) { self.view.alpha = 1 }

        stepTimer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { [weak self] _ in
            self?.advanceStep()
        }
    }

    private func advanceStep() {
        stepIndex = (stepIndex + 1) % steps.count
        UIView.transition(with: stepLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.stepLabel.text = self.steps[self.stepIndex]
        }
    }


    var onCompleted: (() -> Void)?

    private func scheduleTransition() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.onCompleted?()
        }
    }
}
