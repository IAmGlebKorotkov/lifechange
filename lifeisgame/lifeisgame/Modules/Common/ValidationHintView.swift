//
//  ValidationHintView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 09.04.2026.
//

import UIKit

final class ValidationHintView: UIView {


    private let iconView: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        let iv = UIImageView(image: UIImage(systemName: "info.circle.fill", withConfiguration: cfg))
        iv.tintColor = UIColor.main
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.setContentHuggingPriority(.required, for: .horizontal)
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Для продолжения нужно:"
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = UIColor.main
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let itemsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 5
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.main.withAlphaComponent(0.06)
        layer.cornerRadius = 14
        layer.borderWidth = 1
        layer.borderColor = UIColor.main.withAlphaComponent(0.18).cgColor
        translatesAutoresizingMaskIntoConstraints = false

        let headerStack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        headerStack.axis = .horizontal
        headerStack.spacing = 6
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(headerStack)
        addSubview(itemsStack)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            itemsStack.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            itemsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            itemsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            itemsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }


    func update(with hints: [String]) {
        itemsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        hints.forEach { hint in
            itemsStack.addArrangedSubview(makeRow(text: hint))
        }

        let shouldHide = hints.isEmpty
        guard isHidden != shouldHide else { return }

        if shouldHide {
            UIView.animate(withDuration: 0.25) { self.alpha = 0 } completion: { _ in
                self.isHidden = true
                self.alpha = 1
            }
        } else {
            isHidden = false
            alpha = 0
            UIView.animate(withDuration: 0.25) { self.alpha = 1 }
        }
    }


    private func makeRow(text: String) -> UIView {
        let bullet = UIView()
        bullet.backgroundColor = UIColor.main.withAlphaComponent(0.5)
        bullet.layer.cornerRadius = 3
        bullet.translatesAutoresizingMaskIntoConstraints = false
        bullet.widthAnchor.constraint(equalToConstant: 6).isActive = true
        bullet.heightAnchor.constraint(equalToConstant: 6).isActive = true

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [bullet, label])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }
}
