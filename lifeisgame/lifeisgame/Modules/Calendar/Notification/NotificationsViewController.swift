//
//  NotificationsViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 12.05.2026.
//

import UIKit

final class NotificationsViewController: UIViewController {

    private let viewModel: NotificationsViewModel
    private var items: [NotificationViewData] = []

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 96
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let emptyStateView = EmptyStateView(
        iconSystemName: "bell.slash",
        title: "Пока нет уведомлений",
        subtitle: "Здесь появятся уведомления после доставки."
    )

    private let refreshControl = UIRefreshControl()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "HH:mm"
        return f
    }()

    init(viewModel: NotificationsViewModel = NotificationsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        title = "Уведомления"
        setupNavigation()
        setupLayout()
        bindViewModel()
        viewModel.loadNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        viewModel.loadNotifications()
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
        view.addSubview(emptyStateView)

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

            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36)
        ])
    }

    private func bindViewModel() {
        viewModel.onNotificationsLoaded = { [weak self] items in
            self?.items = items
            self?.refreshControl.endRefreshing()
            self?.updateState()
        }
    }

    private func updateState() {
        tableView.isHidden = items.isEmpty
        emptyStateView.isHidden = !items.isEmpty

        if viewModel.areNotificationsEnabled {
            emptyStateView.configure(
                title: "Пока нет уведомлений",
                subtitle: "Здесь появятся уведомления после доставки.",
                iconSystemName: "bell.slash"
            )
        } else {
            emptyStateView.configure(
                title: "Уведомления выключены",
                subtitle: "Включить их можно в профиле.",
                iconSystemName: "bell.slash"
            )
        }

        tableView.reloadData()
    }

    private func dateText(for item: NotificationViewData) -> String {
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
        return DateFormatter.appDateTimeString(from: date)
    }

    @objc private func refreshPulled() {
        viewModel.loadNotifications()
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
