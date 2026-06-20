//
//  IconBadgeView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import UIKit

final class IconBadgeView: UIView {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor.main
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    init(
        systemName: String,
        pointSize: CGFloat = 20,
        badgeSize: CGFloat = 44,
        iconSize: CGFloat = 22,
        tintColor: UIColor = UIColor.main,
        backgroundColor: UIColor = UIColor.main.withAlphaComponent(0.10)
    ) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = backgroundColor
        layer.cornerRadius = badgeSize / 2

        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
        imageView.image = UIImage(systemName: systemName, withConfiguration: config)
        imageView.tintColor = tintColor

        addSubview(imageView)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: badgeSize),
            heightAnchor.constraint(equalToConstant: badgeSize),

            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: iconSize),
            imageView.heightAnchor.constraint(equalToConstant: iconSize)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setImage(systemName: String, pointSize: CGFloat = 20) {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
        imageView.image = UIImage(systemName: systemName, withConfiguration: config)
    }
}
