//
//  AchievementCell.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit


enum AchievementState {
    case locked
    case unlocked
    case opened
}

struct AchievementItem {
    let id: Int
    let icon: String
    let title: String
    let goal: String
    let progress: String
    var state: AchievementState
    let cellHeight: CGFloat

    static let samples: [AchievementItem] = [
        .init(id:  0, icon: "flame.fill",        title: "Первый шаг",     goal: "Выполни первое задание",                    progress: "1/1",   state: .opened,   cellHeight: 160),
        .init(id:  1, icon: "star.fill",          title: "Неделя побед",   goal: "Выполняй задания 7 дней подряд",            progress: "7/7",   state: .opened,   cellHeight: 200),
        .init(id:  2, icon: "bolt.fill",          title: "Суперскорость",  goal: "Выполни все задачи за 30 дней",             progress: "30/30", state: .unlocked, cellHeight: 145),
        .init(id:  3, icon: "moon.fill",          title: "Сладкий сон",    goal: "Спи по 8 часов 5 дней подряд",             progress: "5/5",   state: .unlocked, cellHeight: 185),
        .init(id:  4, icon: "heart.fill",         title: "Хорошее настроение", goal: "Отмечай отличное настроение 30 дней",  progress: "30/30", state: .unlocked, cellHeight: 150),
        .init(id:  5, icon: "trophy.fill",        title: "Чемпион",        goal: "Выполни 100 заданий",                       progress: "0/100", state: .locked,   cellHeight: 170),
        .init(id:  6, icon: "leaf.fill",          title: "Здоровый образ", goal: "Веди дневник 14 дней без пропусков",       progress: "0/14",  state: .locked,   cellHeight: 140),
        .init(id:  7, icon: "figure.run",         title: "Марафонец",      goal: "Выполняй активные задачи 30 дней подряд",  progress: "0/30",  state: .locked,   cellHeight: 195),
        .init(id:  8, icon: "brain.head.profile", title: "Медитация",      goal: "Медитируй каждый день на протяжении 21 дня", progress: "0/21", state: .locked,  cellHeight: 155),
        .init(id:  9, icon: "book.fill",          title: "Книжный червь",  goal: "Читай минимум 20 страниц 10 дней подряд",  progress: "0/10",  state: .locked,   cellHeight: 165),
        .init(id: 10, icon: "drop.fill",          title: "Водный баланс",  goal: "Выпивай 2 литра воды 7 дней подряд",       progress: "0/7",   state: .locked,   cellHeight: 140),
        .init(id: 11, icon: "crown.fill",         title: "Легенда",        goal: "Не пропускай ни одного дня целый год",      progress: "0/365", state: .locked,   cellHeight: 200),
    ]
}


final class AchievementCell: UICollectionViewCell {

    static let reuseID = "AchievementCell"

    var onOpened: (() -> Void)?


    private var currentState: AchievementState = .locked
    private var pressTimer: Timer?
    private var progressTrackLayer: CAShapeLayer?
    private var progressFillLayer: CAShapeLayer?
    private var progressGlowLayer: CAShapeLayer?
    private let longPressGR = UILongPressGestureRecognizer()


    private let bgIconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.alpha = 0.07
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let iconCircleBg: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 28
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let lockIconView: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "lock.fill", withConfiguration: cfg))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor.white.withAlphaComponent(0.55)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .bold)
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let goalLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .regular)
        l.numberOfLines = 3
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let badgeView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        v.layer.cornerRadius = 10
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let badgeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let checkBadge: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "checkmark.seal.fill", withConfiguration: cfg))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor.main
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupGesture()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        layer.removeAnimation(forKey: "shake")
        transform = .identity
        cancelPressAnimation()
        onOpened = nil
    }


    private func setupLayout() {
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true

        badgeView.addSubview(badgeLabel)

        contentView.addSubview(bgIconView)
        contentView.addSubview(iconCircleBg)
        contentView.addSubview(iconView)
        contentView.addSubview(lockIconView)
        contentView.addSubview(goalLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(badgeView)
        contentView.addSubview(checkBadge)

        NSLayoutConstraint.activate([
            bgIconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 16),
            bgIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),
            bgIconView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.72),
            bgIconView.heightAnchor.constraint(equalTo: bgIconView.widthAnchor),

            iconCircleBg.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconCircleBg.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconCircleBg.widthAnchor.constraint(equalTo: iconView.widthAnchor, constant: 20),
            iconCircleBg.heightAnchor.constraint(equalTo: iconCircleBg.widthAnchor),

            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -16),
            iconView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.38),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),

            lockIconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            lockIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -16),
            lockIconView.widthAnchor.constraint(equalToConstant: 28),
            lockIconView.heightAnchor.constraint(equalToConstant: 28),

            goalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            goalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            goalLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            titleLabel.leadingAnchor.constraint(equalTo: goalLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: goalLabel.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: goalLabel.topAnchor, constant: -3),

            badgeLabel.topAnchor.constraint(equalTo: badgeView.topAnchor, constant: 4),
            badgeLabel.bottomAnchor.constraint(equalTo: badgeView.bottomAnchor, constant: -4),
            badgeLabel.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor, constant: 8),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: -8),
            badgeView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            badgeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            checkBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            checkBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            checkBadge.widthAnchor.constraint(equalToConstant: 22),
            checkBadge.heightAnchor.constraint(equalToConstant: 22),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        iconCircleBg.layer.cornerRadius = iconCircleBg.bounds.width / 2
    }

    private func setupGesture() {
        longPressGR.minimumPressDuration = 0
        longPressGR.addTarget(self, action: #selector(handleLongPress(_:)))
        contentView.addGestureRecognizer(longPressGR)
    }


    func configure(with item: AchievementItem) {
        currentState = item.state
        badgeLabel.text = item.progress
        goalLabel.text = item.goal
        titleLabel.text = item.title

        let iconCfg = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
        let icon = UIImage(systemName: item.icon, withConfiguration: iconCfg)
        iconView.image = icon

        let bgCfg = UIImage.SymbolConfiguration(pointSize: 80, weight: .medium)
        bgIconView.image = UIImage(systemName: item.icon, withConfiguration: bgCfg)
        bgIconView.transform = CGAffineTransform(rotationAngle: .pi / 12)

        applyVisuals(for: item.state)
        if item.state == .unlocked { startShaking() }
    }

    private func applyVisuals(for state: AchievementState) {
        switch state {

        case .locked:
            contentView.backgroundColor = UIColor(white: 0.12, alpha: 1)
            bgIconView.isHidden = false
            bgIconView.tintColor = .white
            bgIconView.alpha = 0.05
            iconCircleBg.isHidden = true
            iconView.isHidden = true
            lockIconView.isHidden = false
            titleLabel.isHidden = false
            titleLabel.textColor = UIColor.white.withAlphaComponent(0.65)
            goalLabel.isHidden = false
            goalLabel.textColor = UIColor.white.withAlphaComponent(0.38)
            badgeView.isHidden = false
            badgeLabel.textColor = UIColor.white.withAlphaComponent(0.50)
            badgeView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
            checkBadge.isHidden = true
            longPressGR.isEnabled = false

        case .unlocked:
            contentView.backgroundColor = UIColor.main
            bgIconView.isHidden = false
            bgIconView.tintColor = .white
            bgIconView.alpha = 0.08
            iconCircleBg.isHidden = true
            iconView.isHidden = false
            iconView.tintColor = .white
            lockIconView.isHidden = true
            titleLabel.isHidden = false
            titleLabel.textColor = .white
            goalLabel.isHidden = false
            goalLabel.textColor = UIColor.white.withAlphaComponent(0.70)
            badgeView.isHidden = false
            badgeLabel.textColor = .white
            badgeView.backgroundColor = UIColor.white.withAlphaComponent(0.20)
            checkBadge.isHidden = true
            longPressGR.isEnabled = true

        case .opened:
            contentView.backgroundColor = .white
            bgIconView.isHidden = true
            iconCircleBg.isHidden = false
            iconCircleBg.backgroundColor = UIColor.main.withAlphaComponent(0.10)
            iconView.isHidden = false
            iconView.tintColor = UIColor.main
            iconView.transform = .identity
            lockIconView.isHidden = true
            titleLabel.isHidden = false
            titleLabel.textColor = .label
            goalLabel.isHidden = false
            goalLabel.textColor = .secondaryLabel
            badgeView.isHidden = true
            checkBadge.isHidden = false
            longPressGR.isEnabled = false
        }
    }


    private func startShaking() {
        let wobble = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        wobble.values = [-0.018, 0.018, -0.014, 0.014, -0.008, 0.008, 0.0]
        wobble.duration = 0.55
        wobble.repeatCount = .greatestFiniteMagnitude
        layer.add(wobble, forKey: "shake")
    }


    @objc private func handleLongPress(_ gr: UILongPressGestureRecognizer) {
        guard currentState == .unlocked else { return }
        switch gr.state {
        case .began:
            layer.removeAnimation(forKey: "shake")
            showProgressRing()
            pressTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.openCell()
            }
        case .ended, .cancelled, .failed:
            cancelPressAnimation()
            if currentState == .unlocked { startShaking() }
        default:
            break
        }
    }

    private func showProgressRing() {
        UIView.animate(withDuration: 0.25, delay: 0,
                       usingSpringWithDamping: 0.75, initialSpringVelocity: 0) {
            self.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
        }

        let inset: CGFloat = 3
        let path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: inset, dy: inset),
            cornerRadius: 20 - inset
        )

        let track = CAShapeLayer()
        track.path = path.cgPath
        track.strokeColor = UIColor.white.withAlphaComponent(0.18).cgColor
        track.fillColor = UIColor.clear.cgColor
        track.lineWidth = 4
        layer.addSublayer(track)
        progressTrackLayer = track

        let glow = CAShapeLayer()
        glow.path = path.cgPath
        glow.strokeColor = UIColor.white.withAlphaComponent(0.35).cgColor
        glow.fillColor = UIColor.clear.cgColor
        glow.lineWidth = 10
        glow.lineCap = .round
        glow.strokeEnd = 0
        layer.addSublayer(glow)
        progressGlowLayer = glow

        let fill = CAShapeLayer()
        fill.path = path.cgPath
        fill.strokeColor = UIColor.white.cgColor
        fill.fillColor = UIColor.clear.cgColor
        fill.lineWidth = 4
        fill.lineCap = .round
        fill.strokeEnd = 0
        layer.addSublayer(fill)
        progressFillLayer = fill

        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = 0
        anim.toValue = 1
        anim.duration = 3.0
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false

        fill.add(anim, forKey: "ring")
        glow.add(anim.copy() as! CABasicAnimation, forKey: "ring")
    }

    private func cancelPressAnimation() {
        pressTimer?.invalidate()
        pressTimer = nil
        progressFillLayer?.removeFromSuperlayer()
        progressFillLayer = nil
        progressGlowLayer?.removeFromSuperlayer()
        progressGlowLayer = nil
        progressTrackLayer?.removeFromSuperlayer()
        progressTrackLayer = nil
        UIView.animate(withDuration: 0.2) { self.transform = .identity }
    }

    private func openCell() {
        currentState = .opened
        cancelPressAnimation()
        longPressGR.isEnabled = false

        UIView.transition(with: contentView, duration: 0.45, options: [.transitionFlipFromRight, .allowUserInteraction]) {
            self.applyVisuals(for: .opened)
        } completion: { _ in
            UIView.animate(withDuration: 0.18) {
                self.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
            } completion: { _ in
                UIView.animate(withDuration: 0.35, delay: 0,
                               usingSpringWithDamping: 0.55, initialSpringVelocity: 0.5) {
                    self.transform = .identity
                }
            }
            self.onOpened?()
        }
    }
}
