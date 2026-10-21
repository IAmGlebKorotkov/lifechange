//
//  CustomTabBar.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class CustomTabBar: UIView {


    let topInset: CGFloat = 16

    private let capsuleHeight: CGFloat = 64

    private let centerButtonSize: CGFloat = 58
    private let centerButtonElevation: CGFloat = -12

    private let notchWidth: CGFloat = 76
    private let notchDepth: CGFloat = 28
    private let notchCurveInset: CGFloat = 18


    var selectedIndex: Int = 0 {
        didSet { updateSelection() }
    }

    var onTabSelected: ((Int) -> Void)?


    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    private let tintView = UIView()
    private let capsuleMaskLayer = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    private let selectionIndicator = UIView()
    private let centerButton = UIButton(type: .custom)
    private var regularButtons: [UIButton] = []


    private struct TabItem {
        let icon: String
        let index: Int
    }

    private let items: [TabItem] = [
        TabItem(icon: "Calendar", index: 0),
        TabItem(icon: "Lol", index: 1),
        TabItem(icon: "User", index: 2),
        TabItem(icon: "File_Document", index: 3),
        TabItem(icon: "Vector", index: 4)
    ]


    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }


    private func setup() {
        backgroundColor = .clear
        clipsToBounds = false

        setupBackground()
        setupSelectionIndicator()
        setupRegularButtons()
        setupCenterButton()
    }

    private func setupBackground() {
        // Мягкая тень капсулы (по shadowPath, содержимое прозрачное).
        layer.shadowColor = UIColor(rgb: 0x2D2054).cgColor
        layer.shadowOpacity = 0.16
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowRadius = 20

        // Полупрозрачный blur-материал внутри капсулы.
        blurView.isUserInteractionEnabled = false
        blurView.layer.mask = capsuleMaskLayer
        insertSubview(blurView, at: 0)

        tintView.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        tintView.isUserInteractionEnabled = false
        blurView.contentView.addSubview(tintView)

        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor(rgb: 0x3C3C43, alpha: 0.08).cgColor
        borderLayer.lineWidth = 1
        layer.addSublayer(borderLayer)
    }

    private func setupSelectionIndicator() {
        selectionIndicator.backgroundColor = UIColor.main.withAlphaComponent(0.10)
        selectionIndicator.layer.cornerRadius = 18
        selectionIndicator.alpha = 0
        addSubview(selectionIndicator)
    }

    private func setupRegularButtons() {
        for item in items where item.index != 2 {
            let button = makeRegularButton(item: item)
            regularButtons.append(button)
            addSubview(button)
        }
        updateSelection()
    }

    private func makeRegularButton(item: TabItem) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = item.index

        button.setImage(UIImage(named: item.icon)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .textSecondaryToken
        button.adjustsImageWhenHighlighted = false
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(regularButtonTapped(_:)), for: .touchUpInside)
        button.enablePressScale(to: 0.94)
        return button
    }

    private func setupCenterButton() {
        centerButton.setImage(UIImage(named: "User")?.withRenderingMode(.alwaysTemplate), for: .normal)
        centerButton.tintColor = .white
        // Градиент как background image: гарантированно рисуется под иконкой.
        centerButton.setBackgroundImage(Self.makeGradientCircle(diameter: centerButtonSize), for: .normal)

        centerButton.layer.cornerRadius = centerButtonSize / 2
        centerButton.layer.shadowColor = UIColor.main.cgColor
        centerButton.layer.shadowOpacity = 0.42
        centerButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        centerButton.layer.shadowRadius = 16
        centerButton.tag = 2
        centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
        centerButton.enablePressScale(to: 0.94)
        addSubview(centerButton)
    }


    private func updateSelection() {
        let accent = UIColor.main

        for button in regularButtons {
            let isSelected = button.tag == selectedIndex
            button.tintColor = isSelected ? accent : .textSecondaryToken
            button.alpha = isSelected ? 1 : 0.72
        }

        moveSelectionIndicator(animated: true)

        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            usingSpringWithDamping: 0.78,
            initialSpringVelocity: 0.35,
            options: .allowUserInteraction
        ) {
            if self.selectedIndex == 2 {
                self.centerButton.layer.shadowOpacity = 0.55
                self.centerButton.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
            } else {
                self.centerButton.layer.shadowOpacity = 0.42
                self.centerButton.transform = .identity
            }
        }
    }


    override func layoutSubviews() {
        super.layoutSubviews()

        let path = createCapsulePath().cgPath
        layer.shadowPath = path
        capsuleMaskLayer.path = path
        borderLayer.path = path

        blurView.frame = bounds
        tintView.frame = bounds

        layoutRegularButtons()
        layoutCenterButton()
        moveSelectionIndicator(animated: false)
    }

    private func layoutCenterButton() {
        let cx = bounds.midX
        let centerY = topInset - centerButtonElevation
        centerButton.frame = CGRect(
            x: cx - centerButtonSize / 2,
            y: centerY - centerButtonSize / 2,
            width: centerButtonSize,
            height: centerButtonSize
        )
    }

    private static func makeGradientCircle(diameter: CGFloat) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let ctx = context.cgContext
            ctx.addEllipse(in: CGRect(origin: .zero, size: size))
            ctx.clip()

            let colors = [
                UIColor(rgb: 0x8A68F5).cgColor,
                UIColor(rgb: 0x5F33E1).cgColor,
                UIColor(rgb: 0x4A1FD0).cgColor
            ]
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: [0, 0.55, 1]
            ) else { return }

            ctx.drawLinearGradient(
                gradient,
                start: CGPoint(x: diameter * 0.15, y: 0),
                end: CGPoint(x: diameter * 0.85, y: diameter),
                options: []
            )
        }
    }

    private func layoutRegularButtons() {
        let w = bounds.width
        let midX = w / 2
        let top = topInset
        let ch = capsuleHeight

        let sideWidth = midX - notchWidth / 2
        let buttonWidth = sideWidth / 2

        let leftButtons = regularButtons.filter { $0.tag < 2 }.sorted { $0.tag < $1.tag }
        for (i, btn) in leftButtons.enumerated() {
            btn.frame = CGRect(
                x: CGFloat(i) * buttonWidth,
                y: top,
                width: buttonWidth,
                height: ch
            )
        }

        let rightStart = midX + notchWidth / 2
        let rightBtnW = (w - rightStart) / 2
        let rightButtons = regularButtons.filter { $0.tag > 2 }.sorted { $0.tag < $1.tag }
        for (i, btn) in rightButtons.enumerated() {
            btn.frame = CGRect(
                x: rightStart + CGFloat(i) * rightBtnW,
                y: top,
                width: rightBtnW,
                height: ch
            )
        }
    }

    private func moveSelectionIndicator(animated: Bool) {
        guard let selectedButton = regularButtons.first(where: { $0.tag == selectedIndex }) else {
            let updates = {
                self.selectionIndicator.alpha = 0
                self.selectionIndicator.transform = CGAffineTransform(scaleX: 0.72, y: 0.72)
            }
            if animated {
                UIView.animate(withDuration: 0.16, animations: updates)
            } else {
                updates()
            }
            return
        }

        let targetFrame = selectedButton.frame.insetBy(dx: max(8, selectedButton.bounds.width * 0.26), dy: 14)
        let updates = {
            self.selectionIndicator.alpha = 1
            self.selectionIndicator.transform = .identity
            self.selectionIndicator.frame = targetFrame
        }

        guard animated else {
            updates()
            return
        }

        UIView.animate(
            withDuration: 0.24,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.35,
            options: .allowUserInteraction,
            animations: updates
        )
    }


    private func createCapsulePath() -> UIBezierPath {
        let w = bounds.width
        let h = bounds.height
        let top = topInset
        let ch = capsuleHeight
        let r = ch / 2
        let midX = w / 2
        let halfN = notchWidth / 2
        let depth = notchDepth
        let ci = notchCurveInset

        let path = UIBezierPath()

        path.move(to: CGPoint(x: 0, y: top + r))

        path.addQuadCurve(
            to: CGPoint(x: r, y: top),
            controlPoint: CGPoint(x: 0, y: top)
        )

        path.addLine(to: CGPoint(x: midX - halfN, y: top))

        path.addCurve(
            to: CGPoint(x: midX, y: top + depth),
            controlPoint1: CGPoint(x: midX - halfN + ci, y: top),
            controlPoint2: CGPoint(x: midX - ci, y: top + depth)
        )

        path.addCurve(
            to: CGPoint(x: midX + halfN, y: top),
            controlPoint1: CGPoint(x: midX + ci, y: top + depth),
            controlPoint2: CGPoint(x: midX + halfN - ci, y: top)
        )

        path.addLine(to: CGPoint(x: w - r, y: top))

        path.addQuadCurve(
            to: CGPoint(x: w, y: top + r),
            controlPoint: CGPoint(x: w, y: top)
        )

        path.addLine(to: CGPoint(x: w, y: h - r))

        path.addQuadCurve(
            to: CGPoint(x: w - r, y: h),
            controlPoint: CGPoint(x: w, y: h)
        )

        path.addLine(to: CGPoint(x: r, y: h))

        path.addQuadCurve(
            to: CGPoint(x: 0, y: h - r),
            controlPoint: CGPoint(x: 0, y: h)
        )

        path.close()
        return path
    }


    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else { return nil }

        let converted = centerButton.convert(point, from: self)
        if centerButton.isUserInteractionEnabled,
           !centerButton.isHidden,
           centerButton.alpha > 0.01,
           centerButton.bounds.contains(converted) {
            return centerButton
        }
        return super.hitTest(point, with: event)
    }


    @objc private func regularButtonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        onTabSelected?(sender.tag)
    }

    @objc private func centerButtonTapped() {
        selectedIndex = 2
        onTabSelected?(2)
    }
}
