//
//  CalendarAddMenuView.swift
//  lifeisgame
//

import UIKit

final class CalendarAddMenuView: UIView, UIGestureRecognizerDelegate {

    var onSelection: ((AddTaskKind) -> Void)?

    private let mainButton = UIButton(type: .custom)
    private var actionButtons: [CalendarAddActionButton] = []
    private var isExpanded = false
    private var highlightedKind: AddTaskKind?
    private let selectionFeedback = UISelectionFeedbackGenerator()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        configureMainButton()
        configureActionButtons()
        configureGestures()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isExpanded {
            return bounds.contains(point)
        }

        let buttonPoint = mainButton.convert(point, from: self)
        return mainButton.point(inside: buttonPoint, with: event)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let buttonSize: CGFloat = 54
        let bottomInset = max(safeAreaInsets.bottom, 0)
        mainButton.frame = CGRect(
            x: bounds.width - buttonSize - 20,
            y: max(16, bounds.height - bottomInset - 96 - buttonSize),
            width: buttonSize,
            height: buttonSize
        )
        mainButton.layer.cornerRadius = buttonSize / 2

        guard isExpanded else { return }
        layoutActionButtons()
    }

    private func configureMainButton() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        mainButton.setImage(UIImage(systemName: "plus", withConfiguration: configuration), for: .normal)
        mainButton.tintColor = .white
        mainButton.backgroundColor = .main
        mainButton.applyPrimaryButtonShadow()
        mainButton.accessibilityIdentifier = "calendar.add.menu"
        mainButton.accessibilityLabel = "Добавить"
        mainButton.accessibilityHint = "Нажмите или удерживайте, чтобы выбрать тип"
        mainButton.addTarget(self, action: #selector(mainButtonTapped), for: .touchUpInside)
        mainButton.enablePressScale()
        addSubview(mainButton)
    }

    private func configureActionButtons() {
        let kindsFromBottomToTop: [AddTaskKind] = [.hardTask, .simpleTask, .event]

        actionButtons = kindsFromBottomToTop.map { kind in
            let button = CalendarAddActionButton(kind: kind)
            button.alpha = 0
            button.isHidden = true
            button.addTarget(self, action: #selector(actionButtonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(actionButtonTouchCancelled(_:)), for: [
                .touchCancel,
                .touchDragExit,
                .touchUpOutside
            ])
            addSubview(button)
            return button
        }
    }

    private func configureGestures() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.3
        longPress.allowableMovement = .greatestFiniteMagnitude
        mainButton.addGestureRecognizer(longPress)

        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundTap.cancelsTouchesInView = false
        backgroundTap.delegate = self
        addGestureRecognizer(backgroundTap)
    }

    private func layoutActionButtons() {
        let rightEdge = mainButton.frame.maxX
        let verticalStep: CGFloat = 60

        for (index, button) in actionButtons.enumerated() {
            let isHighlighted = button.kind == highlightedKind
            let width: CGFloat = isHighlighted ? 174 : 48
            button.setShowsTitle(isHighlighted)
            button.frame = CGRect(
                x: rightEdge - width,
                y: mainButton.frame.minY - CGFloat(index + 1) * verticalStep,
                width: width,
                height: 48
            )
        }
    }

    private func setExpanded(_ expanded: Bool) {
        guard expanded != isExpanded else { return }
        isExpanded = expanded
        setHighlightedKind(nil, animated: false)
        updateMainButtonImage()

        if expanded {
            presentActionButtons()
        } else {
            dismissActionButtons()
        }
    }

    private func presentActionButtons() {
        selectionFeedback.prepare()
        layoutActionButtons()
        actionButtons.forEach {
            $0.isHidden = false
            $0.alpha = 0
            $0.transform = CGAffineTransform(
                translationX: mainButton.center.x - $0.center.x,
                y: mainButton.center.y - $0.center.y
            ).scaledBy(x: 0.55, y: 0.55)
        }

        guard !UIAccessibility.isReduceMotionEnabled else {
            actionButtons.forEach {
                $0.alpha = 1
                $0.transform = .identity
            }
            return
        }

        UIView.animate(
            withDuration: 0.32,
            delay: 0,
            usingSpringWithDamping: 0.76,
            initialSpringVelocity: 0.55,
            options: [.beginFromCurrentState, .allowUserInteraction]
        ) {
            self.actionButtons.forEach {
                $0.alpha = 1
                $0.transform = .identity
            }
        }
    }

    private func dismissActionButtons() {
        let animations = {
            self.actionButtons.forEach {
                let center = $0.center
                $0.transform = CGAffineTransform(
                    translationX: self.mainButton.center.x - center.x,
                    y: self.mainButton.center.y - center.y
                ).scaledBy(x: 0.55, y: 0.55)
                $0.alpha = 0
            }
        }
        let completion: (Bool) -> Void = { _ in
            self.actionButtons.forEach {
                $0.isHidden = true
                $0.transform = .identity
            }
        }

        if UIAccessibility.isReduceMotionEnabled {
            animations()
            completion(true)
        } else {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseIn],
                animations: animations,
                completion: completion
            )
        }
    }

    private func setHighlightedKind(_ kind: AddTaskKind?, animated: Bool = true) {
        guard kind != highlightedKind else { return }
        highlightedKind = kind

        if kind != nil {
            selectionFeedback.selectionChanged()
            selectionFeedback.prepare()
        }

        let changes = { self.layoutActionButtons() }
        if animated && !UIAccessibility.isReduceMotionEnabled {
            UIView.animate(
                withDuration: 0.18,
                delay: 0,
                options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseInOut],
                animations: changes
            )
        } else {
            changes()
        }
    }

    private func kind(at point: CGPoint) -> AddTaskKind? {
        actionButtons.first { button in
            button.frame.insetBy(dx: -10, dy: -6).contains(point)
        }?.kind
    }

    private func select(_ kind: AddTaskKind) {
        setExpanded(false)
        onSelection?(kind)
    }

    private func updateMainButtonImage() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(
            systemName: isExpanded ? "xmark" : "plus",
            withConfiguration: configuration
        )
        UIView.transition(
            with: mainButton,
            duration: UIAccessibility.isReduceMotionEnabled ? 0 : 0.18,
            options: [.transitionCrossDissolve, .allowUserInteraction]
        ) {
            self.mainButton.setImage(image, for: .normal)
        }
        mainButton.accessibilityValue = isExpanded ? "Меню открыто" : "Меню закрыто"
    }

    @objc private func mainButtonTapped() {
        setExpanded(!isExpanded)
    }

    @objc private func actionButtonTouchDown(_ sender: CalendarAddActionButton) {
        setHighlightedKind(sender.kind)
    }

    @objc private func actionButtonTouchCancelled(_ sender: CalendarAddActionButton) {
        setHighlightedKind(nil)
    }

    @objc private func actionButtonTapped(_ sender: CalendarAddActionButton) {
        select(sender.kind)
    }

    @objc private func backgroundTapped() {
        guard isExpanded else { return }
        setExpanded(false)
    }

    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: self)

        switch recognizer.state {
        case .began:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            setExpanded(true)
        case .changed:
            setHighlightedKind(kind(at: location))
        case .ended:
            if let highlightedKind {
                select(highlightedKind)
            }
        case .cancelled, .failed:
            setExpanded(false)
        default:
            break
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var touchedView = touch.view
        while let view = touchedView, view !== self {
            if view is UIControl { return false }
            touchedView = view.superview
        }
        return true
    }
}

private final class CalendarAddActionButton: UIButton {

    let kind: AddTaskKind

    init(kind: AddTaskKind) {
        self.kind = kind
        super.init(frame: .zero)

        layer.cornerRadius = 24
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        accessibilityIdentifier = "calendar.add.\(kind.accessibilityID)"
        accessibilityLabel = kind.title
        setShowsTitle(false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setShowsTitle(_ showsTitle: Bool) {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = kind.tintColor
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .capsule
        configuration.image = UIImage(systemName: kind.symbolName)
        configuration.imagePadding = 8
        configuration.title = showsTitle ? kind.title : nil
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14)
        self.configuration = configuration
    }
}

private extension AddTaskKind {

    var accessibilityID: String {
        switch self {
        case .event:
            return "event"
        case .simpleTask:
            return "simple"
        case .hardTask:
            return "hard"
        }
    }

    var tintColor: UIColor {
        switch self {
        case .event:
            return .appInfo
        case .simpleTask:
            return .main
        case .hardTask:
            return .appSleepPurple
        }
    }
}
