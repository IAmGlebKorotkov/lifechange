//
//  StatsCarouselView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class StatsCarouselView: UIView {


    var onSelectionChanged: ((Int) -> Void)?
    private(set) var selectedIndex: Int = 0


    private let circleRadius: CGFloat = 110
    private let nodeSize:     CGFloat = 70
    private let step:         CGFloat = 2 * .pi / 3
    private let nodeCount     = 3

    private let items: [(name: String, image: String)] = [
        ("Эмоции",  "Lol"),
        ("Сон",     "Time_sleep"),
        ("Задачи",  "Calendar"),
    ]


    private var rotationAngle: CGFloat = 0


    private let dashLayer = CAShapeLayer()
    private var nodeCircles: [UIView]  = []
    private var nodeLabels:  [UILabel] = []


    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        setupDashCircle()
        setupNodes()
        addGestures()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        dashLayer.path = UIBezierPath(arcCenter: center, radius: circleRadius,
                                      startAngle: 0, endAngle: 2 * .pi,
                                      clockwise: true).cgPath
        positionNodes(animated: false)
    }


    private func setupDashCircle() {
        dashLayer.fillColor   = UIColor.clear.cgColor
        dashLayer.strokeColor = UIColor.main.cgColor
        dashLayer.lineWidth   = 2.5
        dashLayer.lineDashPattern = [6, 5]
        layer.addSublayer(dashLayer)
    }

    private func setupNodes() {
        for item in items {
            let circle = UIView()
            circle.bounds = CGRect(origin: .zero, size: CGSize(width: nodeSize, height: nodeSize))
            circle.backgroundColor = .main
            circle.layer.cornerRadius = nodeSize / 2
            circle.layer.shadowColor   = UIColor.black.cgColor
            circle.layer.shadowOpacity = 0.1
            circle.layer.shadowOffset  = CGSize(width: 0, height: 2)
            circle.layer.shadowRadius  = 6

            let icon = UIImageView()
            if let asset = UIImage(named: item.image) {
                icon.image = asset.withRenderingMode(.alwaysTemplate)
                icon.tintColor = UIColor.lightMain
            } else {
                let cfg = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
                icon.image = UIImage(systemName: item.image, withConfiguration: cfg)
                icon.tintColor = UIColor.main
            }
            icon.contentMode = .scaleAspectFit
            let inset: CGFloat = 13
            icon.frame = CGRect(x: inset, y: inset, width: nodeSize - inset * 2, height: nodeSize - inset * 2)
            circle.addSubview(icon)
            addSubview(circle)
            nodeCircles.append(circle)

            let label = UILabel()
            label.text = item.name
            label.font = .systemFont(ofSize: 11, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            label.sizeToFit()
            addSubview(label)
            nodeLabels.append(label)
        }
    }

    private func addGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(pan)
    }


    private func positionNodes(animated: Bool) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        for i in 0..<nodeCount {
            let angle = -.pi / 2 + CGFloat(i) * step + rotationAngle
            let cx = center.x + circleRadius * cos(angle)
            let cy = center.y + circleRadius * sin(angle)
            nodeCircles[i].center = CGPoint(x: cx, y: cy)
            nodeLabels[i].center  = CGPoint(x: cx, y: cy + nodeSize / 2 + 14)
        }

        updateSelection()
    }

    private func updateSelection() {
        var minSin = CGFloat.infinity
        var newIdx = 0
        for i in 0..<nodeCount {
            let s = sin(-.pi / 2 + CGFloat(i) * step + rotationAngle)
            if s < minSin { minSin = s; newIdx = i }
        }

        if newIdx != selectedIndex {
            selectedIndex = newIdx
            onSelectionChanged?(selectedIndex)
        }

        for i in 0..<nodeCount {
            let sel = i == selectedIndex
            UIView.animate(withDuration: 0.2) {
                self.nodeCircles[i].transform = sel ? CGAffineTransform(scaleX: 1.18, y: 1.18) : .identity
                self.nodeLabels[i].textColor  = sel ? UIColor.main : .secondaryLabel
                self.nodeLabels[i].font       = sel
                    ? .systemFont(ofSize: 11, weight: .semibold)
                    : .systemFont(ofSize: 11, weight: .medium)
            }
        }
    }


    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        let dx = pan.translation(in: self).x
        pan.setTranslation(.zero, in: self)

        switch pan.state {
        case .changed:
            rotationAngle -= dx / 140 * step
            positionNodes(animated: false)
        case .ended, .cancelled:
            snapToNearest()
        default:
            break
        }
    }

    private func snapToNearest() {
        rotationAngle = round(rotationAngle / step) * step
        UIView.animate(withDuration: 0.4, delay: 0,
                       usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5,
                       options: .allowUserInteraction) {
            self.positionNodes(animated: true)
        }
    }
}
