//
//  CustomButton.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

enum CustomButtonType {
    case main
    case secondary
}

final class CustomButton: UIControl {

    private let titleLabel = UILabel()

    init(title: String, type buttonType: CustomButtonType) {
        super.init(frame: .zero)
        setupButton(title: title, buttonType: buttonType)
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton(title: String, buttonType: CustomButtonType) {
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isUserInteractionEnabled = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        layer.cornerRadius = 12
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 52).isActive = true

        switch buttonType {
        case .main:
            backgroundColor = UIColor.main
            titleLabel.textColor = .white
        case .secondary:
            backgroundColor = .white
            titleLabel.textColor = .black
            layer.borderWidth = 1
            layer.borderColor = UIColor.systemGray4.cgColor
        }
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.alpha = self.isEnabled ? 1.0 : 0.4
            }
            isUserInteractionEnabled = isEnabled
        }
    }

    private func setupActions() {
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc private func handleTouchDown() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        animateScale(to: 0.92)
    }

    @objc private func handleTouchUp() {
        animateScale(to: 1.0)
    }

    private func animateScale(to scale: CGFloat) {
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction]
        ) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}
