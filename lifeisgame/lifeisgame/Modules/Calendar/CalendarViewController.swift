//
//  CalendarViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class CalendarViewController: UIViewController {


    private let viewModel: CalendarViewModel

    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    private let headerView    = CalendarHeaderView()
    private let dateStripView = CalendarDateStripView()
    private let filterView    = CalendarFilterView()
    private let taskListView  = CalendarTaskListView()

    private let selectedDateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "EEEE, d MMMM"
        return f
    }()

    private func formattedDate(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date)    { return "Сегодня, \(Self.dayFormatter.string(from: date).components(separatedBy: ", ").last ?? "")" }
        if cal.isDateInTomorrow(date) { return "Завтра, \(Self.dayFormatter.string(from: date).components(separatedBy: ", ").last ?? "")" }
        if cal.isDateInYesterday(date){ return "Вчера, \(Self.dayFormatter.string(from: date).components(separatedBy: ", ").last ?? "")" }
        let raw = Self.dayFormatter.string(from: date)
        return raw.prefix(1).uppercased() + raw.dropFirst()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupUI()

        taskListView.onAddTapped = { [weak self] in
            self?.viewModel.addTaskTapped()
        }

        headerView.onBellTapped = { [weak self] in
            self?.viewModel.notificationsTapped()
        }

        taskListView.onTaskToggled = { [weak self] id in
            self?.viewModel.toggleTask(id: id)
        }

        taskListView.onTaskSelected = { [weak self] task in
            self?.viewModel.editTaskTapped(task)
        }

        taskListView.onTaskDeleteRequested = { [weak self] id in
            self?.viewModel.deleteTask(id: id)
        }

        filterView.onFilterChanged = { [weak self] filter in
            self?.viewModel.filterSelected(filter)
        }

        viewModel.onTasksUpdated = { [weak self] tasks in
            DispatchQueue.main.async {
                self?.taskListView.configure(with: tasks)
            }
        }

        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        let mainTab = navigationController?.parent as? MainTabBarController
        mainTab?.setTabBarHidden(false, animated: animated)
        viewModel.refresh()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dateStripView.scrollToToday()
    }


    private func setupUI() {
        selectedDateLabel.text = formattedDate(Date())

        view.addSubview(headerView)
        view.addSubview(dateStripView)
        view.addSubview(selectedDateLabel)
        view.addSubview(filterView)
        view.addSubview(taskListView)

        dateStripView.onDateSelected = { [weak self] date in
            guard let self else { return }
            UIView.transition(with: self.selectedDateLabel, duration: 0.2, options: .transitionCrossDissolve) {
                self.selectedDateLabel.text = self.formattedDate(date)
            }
            self.viewModel.dateSelected(date)
        }

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            dateStripView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            dateStripView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dateStripView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dateStripView.heightAnchor.constraint(equalToConstant: 110),

            selectedDateLabel.topAnchor.constraint(equalTo: dateStripView.bottomAnchor, constant: 10),
            selectedDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectedDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            filterView.topAnchor.constraint(equalTo: selectedDateLabel.bottomAnchor, constant: 10),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterView.heightAnchor.constraint(equalToConstant: 48),

            taskListView.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 16),
            taskListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            taskListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            taskListView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
