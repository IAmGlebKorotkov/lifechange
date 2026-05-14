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


    private let shapeLayer = CAShapeLayer()
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

        setupShapeLayer()
        setupRegularButtons()
        setupCenterButton()
    }

    private func setupShapeLayer() {
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOpacity = 0.12
        shapeLayer.shadowOffset = CGSize(width: 0, height: 4)
        shapeLayer.shadowRadius = 12
        layer.insertSublayer(shapeLayer, at: 0)
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

        let imgConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        button.setImage(UIImage(named: item.icon), for: .normal)
        button.tintColor = .systemGray2
        button.addTarget(self, action: #selector(regularButtonTapped(_:)), for: .touchUpInside)
        return button
    }

    private func setupCenterButton() {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        centerButton.setImage(UIImage(named: "User"), for: .normal)
        centerButton.tintColor = .white
        centerButton.backgroundColor = .main
        centerButton.layer.cornerRadius = centerButtonSize / 2
        centerButton.layer.shadowColor = UIColor.main.cgColor
        centerButton.layer.shadowOpacity = 0.40
        centerButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        centerButton.layer.shadowRadius = 10
        centerButton.tag = 2
        centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
        addSubview(centerButton)
    }


    private func updateSelection() {
        let accent = UIColor.main

        for button in regularButtons {
            button.tintColor = button.tag == selectedIndex ? accent : .systemGray2
        }

        UIView.animate(withDuration: 0.15) {
            if self.selectedIndex == 2 {
                self.centerButton.layer.shadowOpacity = 0.55
                self.centerButton.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
            } else {
                self.centerButton.layer.shadowOpacity = 0.40
                self.centerButton.transform = .identity
            }
        }
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        shapeLayer.path = createCapsulePath().cgPath
        layoutRegularButtons()
        layoutCenterButton()
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
