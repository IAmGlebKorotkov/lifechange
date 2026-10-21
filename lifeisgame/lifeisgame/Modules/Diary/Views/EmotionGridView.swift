//
//  EmotionGridView.swift
//  lifeisgame
//
//  Сетка эмоций 3×2 для дневника (дизайн design_handoff_life_is_game_screens).
//

import UIKit

final class EmotionGridView: UIView {

    var onSelectionChanged: ((EmotionStyle) -> Void)?

    private(set) var selectedIndex = 0
    private var cards: [EmotionCardControl] = []
    private let emotions = EmotionStyle.all

    var selectedEmotion: EmotionStyle {
        emotions[selectedIndex]
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
        updateSelection(animated: false)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        let vertical = UIStackView()
        vertical.axis = .vertical
        vertical.spacing = 11
        vertical.translatesAutoresizingMaskIntoConstraints = false
        addSubview(vertical)

        NSLayoutConstraint.activate([
            vertical.topAnchor.constraint(equalTo: topAnchor),
            vertical.leadingAnchor.constraint(equalTo: leadingAnchor),
            vertical.trailingAnchor.constraint(equalTo: trailingAnchor),
            vertical.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        for rowIndex in 0..<2 {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 11
            row.distribution = .fillEqually

            for column in 0..<3 {
                let index = rowIndex * 3 + column
                let card = EmotionCardControl(emotion: emotions[index])
                card.tag = index
                card.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
                cards.append(card)
                row.addArrangedSubview(card)
            }
            vertical.addArrangedSubview(row)
        }
    }

    @objc private func cardTapped(_ sender: EmotionCardControl) {
        guard sender.tag != selectedIndex else { return }
        selectedIndex = sender.tag
        updateSelection(animated: true)
        onSelectionChanged?(selectedEmotion)
    }

    private func updateSelection(animated: Bool) {
        for (index, card) in cards.enumerated() {
            let isSelected = index == selectedIndex
            // Баунс — только у выбранной карточки, остальные меняются без прыжка.
            card.setSelectedState(isSelected, animated: animated && isSelected)
        }
    }
}

private final class EmotionCardControl: UIControl {

    private let emotion: EmotionStyle

    private let tileView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .main
        view.layer.cornerRadius = 9.5
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false

        let cfg = UIImage.SymbolConfiguration(pointSize: 9, weight: .heavy)
        let check = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: cfg))
        check.tintColor = .white
        check.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(check)
        NSLayoutConstraint.activate([
            check.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            check.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()

    init(emotion: EmotionStyle) {
        self.emotion = emotion
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 18
        applyCardShadow(strength: 0.7)

        tileView.backgroundColor = emotion.tileColor
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        iconView.image = UIImage(systemName: emotion.sfSymbol, withConfiguration: cfg)
        iconView.tintColor = emotion.tintColor
        nameLabel.text = emotion.name

        tileView.addSubview(iconView)
        addSubview(tileView)
        addSubview(nameLabel)
        addSubview(checkBadge)

        NSLayoutConstraint.activate([
            tileView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            tileView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tileView.widthAnchor.constraint(equalToConstant: 46),
            tileView.heightAnchor.constraint(equalToConstant: 46),

            iconView.centerXAnchor.constraint(equalTo: tileView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: tileView.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: tileView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -13),

            checkBadge.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            checkBadge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            checkBadge.widthAnchor.constraint(equalToConstant: 19),
            checkBadge.heightAnchor.constraint(equalToConstant: 19)
        ])

        enablePressScale(to: 0.95)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSelectedState(_ isSelected: Bool, animated: Bool) {
        let apply = {
            self.layer.borderWidth = isSelected ? 2 : 0
            self.layer.borderColor = UIColor.main.cgColor
            self.checkBadge.isHidden = !isSelected
            self.nameLabel.font = .systemFont(ofSize: 13, weight: isSelected ? .semibold : .regular)
        }

        guard animated else {
            apply()
            return
        }

        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.15) {
            apply()
            self.transform = .identity
        }
    }
}
