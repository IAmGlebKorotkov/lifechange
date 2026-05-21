//
//  NotificationsViewController.swift
//  lifeisgame
//
//  Created by Codex on 19.05.2026.
//

import UIKit
import UserNotifications

final class NotificationsViewController: UIViewController {

    private struct NotificationItem {
        let id: String
        let title: String
        let body: String
        let date: Date?
    }

    private var items: [NotificationItem] = []

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 96
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let emptyStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .center
        s.spacing = 12
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let emptyIconView: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 38, weight: .regular)
        let iv = UIImageView(image: UIImage(systemName: "bell.slash", withConfiguration: cfg))
        iv.tintColor = UIColor.main.withAlphaComponent(0.65)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let emptyTitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.textColor = .label
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emptySubtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let refreshControl = UIRefreshControl()

    private static let relativeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMMM, HH:mm"
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "HH:mm"
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        title = "Уведомления"
        setupNavigation()
        setupLayout()
        loadNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        loadNotifications()
    }

    private func setupNavigation() {
        let backButton = UIBarButtonItem(
            image: UIImage(named: "Arrow - Left") ?? UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyStack)
        emptyStack.addArrangedSubview(emptyIconView)
        emptyStack.addArrangedSubview(emptyTitleLabel)
        emptyStack.addArrangedSubview(emptySubtitleLabel)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseIdentifier)

        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyIconView.widthAnchor.constraint(equalToConstant: 48),
            emptyIconView.heightAnchor.constraint(equalToConstant: 48),

            emptyStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            emptyStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            emptyStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36)
        ])
    }

    private func loadNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { notifications in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.items = notifications
                    .map(self.makeItem)
                    .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
                self.refreshControl.endRefreshing()
                self.updateState()
            }
        }
    }

    private func makeItem(from notification: UNNotification) -> NotificationItem {
        NotificationItem(
            id: notification.request.identifier,
            title: titleText(from: notification.request.content.title),
            body: bodyText(from: notification.request.content.body),
            date: notification.date
        )
    }

    private func titleText(from value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Уведомление" : value
    }

    private func bodyText(from value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Без описания" : value
    }

    private func updateState() {
        tableView.isHidden = items.isEmpty
        emptyStack.isHidden = !items.isEmpty

        if LocalNotificationService.shared.isEnabled {
            emptyTitleLabel.text = "Пока нет уведомлений"
            emptySubtitleLabel.text = "Здесь появятся уведомления после доставки."
        } else {
            emptyTitleLabel.text = "Уведомления выключены"
            emptySubtitleLabel.text = "Включить их можно в профиле."
        }

        tableView.reloadData()
    }

    private func dateText(for item: NotificationItem) -> String {
        guard let date = item.date else { return "Время не задано" }

        let time = Self.timeFormatter.string(from: date)
        if Calendar.current.isDateInToday(date) {
            return "Сегодня, \(time)"
        }
        if Calendar.current.isDateInTomorrow(date) {
            return "Завтра, \(time)"
        }
        if Calendar.current.isDateInYesterday(date) {
            return "Вчера, \(time)"
        }
        return Self.relativeFormatter.string(from: date)
    }

    @objc private func refreshPulled() {
        loadNotifications()
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NotificationCell.reuseIdentifier,
            for: indexPath
        ) as? NotificationCell else {
            return UITableViewCell()
        }

        let item = items[indexPath.row]
        cell.configure(
            title: item.title,
            body: item.body,
            dateText: dateText(for: item)
        )
        return cell
    }
}

private final class NotificationCell: UITableViewCell {

    static let reuseIdentifier = "NotificationCell"

    private let iconBackgroundView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.main.withAlphaComponent(0.1)
        v.layer.cornerRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let iconView: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        let iv = UIImageView(image: UIImage(systemName: "bell.fill", withConfiguration: cfg))
        iv.tintColor = UIColor.main
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let bodyLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 3
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor.main
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, body: String, dateText: String) {
        titleLabel.text = title
        bodyLabel.text = body
        dateLabel.text = dateText
    }

    private func setupLayout() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 14
        contentView.layer.masksToBounds = true

        contentView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            iconBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            iconBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 40),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 40),

            iconView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            dateLabel.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        ])
    }
}
