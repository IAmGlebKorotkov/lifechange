//
//  ProfileViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit
import PhotosUI

final class ProfileViewController: UIViewController {


    private let viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Профиль"
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let avatarContainer: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 52
        v.backgroundColor = UIColor.main.withAlphaComponent(0.1)
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .center
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let avatarEditButton: UIButton = {
        let b = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        b.setImage(UIImage(systemName: "camera.fill", withConfiguration: cfg), for: .normal)
        b.tintColor = .white
        b.backgroundColor = .main
        b.layer.cornerRadius = 16
        b.layer.borderWidth = 2.5
        b.layer.borderColor = UIColor.background.cgColor
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.text = ""
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .label
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let levelCard = ProfileLevelCardView()

    private let loginField  = ProfileTextField(title: "Логин",  value: "")
    private let passwordField = ProfileTextField(title: "Пароль", value: "••••••••")

    private let logoutButton: UIButton = {
        let b = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        b.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right", withConfiguration: cfg), for: .normal)
        b.tintColor = .main
        b.backgroundColor = UIColor.main.withAlphaComponent(0.10)
        b.layer.cornerRadius = 22
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let faceIDRow = ProfileToggleRow(icon: "faceid", title: "Вход через Face ID")
    private let notificationsRow = ProfileToggleRow(icon: "bell.fill", title: "Уведомления")
    private var notificationsBelowFaceIDConstraint: NSLayoutConstraint?
    private var notificationsBelowPasswordConstraint: NSLayoutConstraint?

    private let changePasswordButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Изменить пароль", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor.main
        b.layer.cornerRadius = 14
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupUI()
        updateFaceIDRowVisibility()
        bindViewModel()
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        logoutButton.enablePressScale()
        changePasswordButton.enablePressScale()
        avatarEditButton.addTarget(self, action: #selector(avatarTapped), for: .touchUpInside)
        avatarEditButton.enablePressScale(to: 0.9)

        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarContainer.addGestureRecognizer(avatarTap)

        viewModel.loadProfile()

        faceIDRow.onValueChanged = { [weak self] isOn in
            self?.viewModel.setFaceIDEnabled(isOn)
        }
        notificationsRow.onValueChanged = { [weak self] isOn in
            self?.viewModel.setNotificationsEnabled(isOn)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadProfile()
    }

    private func bindViewModel() {
        viewModel.onProfileUpdated = { [weak self] profile in
            self?.nameLabel.text = profile.name
            self?.loginField.value = profile.email
            self?.passwordField.value = profile.passwordMask
            self?.faceIDRow.isOn = profile.isFaceIDEnabled
            self?.notificationsRow.isOn = profile.isNotificationsEnabled
        }

        viewModel.onAvatarUpdated = { [weak self] image in
            self?.applyAvatar(image)
        }

        viewModel.onLevelUpdated = { [weak self] progress in
            self?.levelCard.configure(with: progress)
        }

        viewModel.onFaceIDStateChanged = { [weak self] isEnabled in
            self?.faceIDRow.isOn = isEnabled
        }

        viewModel.onNotificationsStateChanged = { [weak self] isEnabled in
            self?.notificationsRow.isOn = isEnabled
        }

        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
    }

    private func applyAvatar(_ image: UIImage?) {
        if let image {
            avatarImageView.image = image
            avatarImageView.contentMode = .scaleAspectFill
        } else {
            let cfg = UIImage.SymbolConfiguration(pointSize: 52, weight: .light)
            avatarImageView.image = UIImage(systemName: "person.fill", withConfiguration: cfg)?
                .withTintColor(UIColor.main.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
            avatarImageView.contentMode = .center
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }


    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        avatarContainer.addSubview(avatarImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(logoutButton)
        contentView.addSubview(avatarContainer)
        contentView.addSubview(avatarEditButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(levelCard)
        contentView.addSubview(loginField)
        contentView.addSubview(passwordField)
        contentView.addSubview(faceIDRow)
        contentView.addSubview(notificationsRow)
        contentView.addSubview(changePasswordButton)

        applyAvatar(nil)

        let notificationsBelowFaceIDConstraint = notificationsRow.topAnchor.constraint(
            equalTo: faceIDRow.bottomAnchor,
            constant: 12
        )
        let notificationsBelowPasswordConstraint = notificationsRow.topAnchor.constraint(
            equalTo: passwordField.bottomAnchor,
            constant: 20
        )
        self.notificationsBelowFaceIDConstraint = notificationsBelowFaceIDConstraint
        self.notificationsBelowPasswordConstraint = notificationsBelowPasswordConstraint

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            logoutButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),

            avatarContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            avatarContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 104),
            avatarContainer.heightAnchor.constraint(equalToConstant: 104),

            avatarImageView.topAnchor.constraint(equalTo: avatarContainer.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: avatarContainer.leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor),

            avatarEditButton.widthAnchor.constraint(equalToConstant: 32),
            avatarEditButton.heightAnchor.constraint(equalToConstant: 32),
            avatarEditButton.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 2),
            avatarEditButton.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 2),

            nameLabel.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 12),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            levelCard.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            levelCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            levelCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            loginField.topAnchor.constraint(equalTo: levelCard.bottomAnchor, constant: 20),
            loginField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            loginField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            passwordField.topAnchor.constraint(equalTo: loginField.bottomAnchor, constant: 12),
            passwordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            faceIDRow.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
            faceIDRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            faceIDRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            notificationsBelowFaceIDConstraint,
            notificationsRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notificationsRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            changePasswordButton.topAnchor.constraint(equalTo: notificationsRow.bottomAnchor, constant: 20),
            changePasswordButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            changePasswordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            changePasswordButton.heightAnchor.constraint(equalToConstant: 54),
            changePasswordButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    private func updateFaceIDRowVisibility() {
        let supportsFaceID = viewModel.supportsFaceID
        faceIDRow.isHidden = !supportsFaceID

        if supportsFaceID {
            notificationsBelowPasswordConstraint?.isActive = false
            notificationsBelowFaceIDConstraint?.isActive = true
        } else {
            notificationsBelowFaceIDConstraint?.isActive = false
            notificationsBelowPasswordConstraint?.isActive = true
        }
    }


    @objc private func avatarTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func logoutTapped() {
        let sheet = LogoutBottomSheetViewController()
        sheet.onLogout = { [weak self] in
            self?.viewModel.onLogoutRequested?()
        }
        if let presenter = sheet.sheetPresentationController {
            presenter.detents = [.custom { _ in 260 }]
            presenter.prefersGrabberVisible = false
            presenter.preferredCornerRadius = 24
        }
        present(sheet, animated: true)
    }
}


extension ProfileViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider else { return }

        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                self?.preparePickedImage(object as? UIImage)
            }
        } else {
            provider.loadDataRepresentation(forTypeIdentifier: "public.image") { [weak self] data, _ in
                self?.preparePickedImage(data.flatMap(UIImage.init(data:)))
            }
        }
    }

    /// Фото с камеры — 12+ МП; уменьшаем в фоне, чтобы превью
    /// и сохранение не подвешивали главный поток.
    private func preparePickedImage(_ image: UIImage?) {
        guard let image else {
            DispatchQueue.main.async { [weak self] in
                self?.showError("Не удалось загрузить фото, попробуйте другое")
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let maxSide: CGFloat = 800
            let scaleFactor = min(1, maxSide / max(image.size.width, image.size.height))
            let targetSize = CGSize(
                width: image.size.width * scaleFactor,
                height: image.size.height * scaleFactor
            )
            let downscaled = UIGraphicsImageRenderer(size: targetSize).image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }

            DispatchQueue.main.async {
                self?.confirmAvatar(downscaled)
            }
        }
    }

    private func confirmAvatar(_ image: UIImage) {
        let confirm = AvatarConfirmViewController(image: image)
        confirm.onConfirm = { [weak self] in
            self?.viewModel.updateAvatar(image)
        }
        if let presenter = confirm.sheetPresentationController {
            presenter.detents = [.custom { _ in 380 }]
            presenter.prefersGrabberVisible = true
            presenter.preferredCornerRadius = 28
        }
        present(confirm, animated: true)
    }
}


// MARK: - Подтверждение аватарки

private final class AvatarConfirmViewController: UIViewController {

    var onConfirm: (() -> Void)?

    private let image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background

        let titleLabel = UILabel()
        titleLabel.text = "Установить это фото?"
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let preview = UIImageView(image: image)
        preview.contentMode = .scaleAspectFill
        preview.layer.cornerRadius = 70
        preview.clipsToBounds = true
        preview.translatesAutoresizingMaskIntoConstraints = false

        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Установить фото", for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = .main
        confirmButton.layer.cornerRadius = 16
        confirmButton.applyPrimaryButtonShadow()
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        confirmButton.enablePressScale()

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.textSecondaryToken, for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(preview)
        view.addSubview(confirmButton)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            preview.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            preview.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            preview.widthAnchor.constraint(equalToConstant: 140),
            preview.heightAnchor.constraint(equalToConstant: 140),

            confirmButton.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 22),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 54),

            cancelButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 8),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func confirmTapped() {
        dismiss(animated: true) { [onConfirm] in
            onConfirm?()
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}


// MARK: - Карточка уровня достижений

final class ProfileLevelCardView: UIView {

    private let trophyTile: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.main
        v.layer.cornerRadius = 13
        v.translatesAutoresizingMaskIntoConstraints = false

        let cfg = UIImage.SymbolConfiguration(pointSize: 19, weight: .semibold)
        let icon = UIImageView(image: UIImage(systemName: "trophy.fill", withConfiguration: cfg))
        icon.tintColor = .white
        icon.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: v.centerYAnchor)
        ])
        return v
    }()

    private let levelLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 19, weight: .bold)
        l.textColor = .white
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.8
        return l
    }()

    private let rankLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.6)
        return l
    }()

    private let xpLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .right
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        return l
    }()

    private let collectedLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.55)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let progressTrack: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        v.layer.cornerRadius = 4
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let progressFill: UIView = {
        let v = UIView()
        v.backgroundColor = .main
        v.layer.cornerRadius = 4
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private var fillFraction: CGFloat = 0
    private var fillWidthConstraint: NSLayoutConstraint?

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .inkDark
        layer.cornerRadius = 20

        let titleStack = UIStackView(arrangedSubviews: [levelLabel, rankLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 1

        let topRow = UIStackView(arrangedSubviews: [trophyTile, titleStack, xpLabel])
        topRow.axis = .horizontal
        topRow.spacing = 12
        topRow.alignment = .center
        topRow.translatesAutoresizingMaskIntoConstraints = false

        progressTrack.addSubview(progressFill)
        addSubview(topRow)
        addSubview(progressTrack)
        addSubview(collectedLabel)

        fillWidthConstraint = progressFill.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 118),

            trophyTile.widthAnchor.constraint(equalToConstant: 42),
            trophyTile.heightAnchor.constraint(equalToConstant: 42),

            topRow.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            topRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            topRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            progressTrack.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 13),
            progressTrack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            progressTrack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            progressTrack.heightAnchor.constraint(equalToConstant: 8),

            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),
            fillWidthConstraint!,

            collectedLabel.topAnchor.constraint(equalTo: progressTrack.bottomAnchor, constant: 9),
            collectedLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            collectedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            collectedLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])

        configure(with: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with progress: AchievementLevelProgress?) {
        let level = progress?.level ?? 1
        let rank = progress?.rank ?? AchievementLevelProgress.ranks[0]
        let xpInLevel = progress?.xpInLevel ?? 0

        levelLabel.text = "Уровень \(level)"
        rankLabel.text = rank
        xpLabel.text = "\(xpInLevel) / \(AchievementLevelProgress.xpPerLevel) XP"

        if let progress {
            collectedLabel.text = "Собрано достижений: \(progress.collected) из \(progress.total)"
            fillFraction = CGFloat(progress.levelFraction)
        } else {
            collectedLabel.text = "Открывайте достижения, чтобы расти в уровне"
            fillFraction = 0
        }

        setNeedsLayout()
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let targetWidth = progressTrack.bounds.width * fillFraction
        guard abs((fillWidthConstraint?.constant ?? 0) - targetWidth) > 0.5 else { return }
        fillWidthConstraint?.constant = targetWidth
        progressTrack.layoutIfNeeded()
    }
}
