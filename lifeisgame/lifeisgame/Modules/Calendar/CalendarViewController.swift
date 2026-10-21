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
    private var didPositionDateStrip = false
    private var selectedDate = Date()

    private func headerTitle(for date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Сегодня" }
        if cal.isDateInTomorrow(date) { return "Завтра" }
        if cal.isDateInYesterday(date) { return "Вчера" }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }

    private func headerSubtitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"
        let text = formatter.string(from: date)
        return text.prefix(1).uppercased() + text.dropFirst()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupUI()

        taskListView.onAddItemSelected = { [weak self] kind in
            self?.viewModel.addItemTapped(kind: kind)
        }

        taskListView.onAddEventInGapTapped = { [weak self] date in
            self?.viewModel.addEventTapped(at: date)
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
                guard let self else { return }
                self.taskListView.configure(
                    with: tasks,
                    selectedDate: self.selectedDate
                )
            }
        }

        viewModel.onProgressUpdated = { [weak self] completed, total in
            DispatchQueue.main.async {
                self?.headerView.setProgress(completed: completed, total: total)
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
        guard !didPositionDateStrip else { return }
        didPositionDateStrip = true
        dateStripView.scrollToToday()
    }


    private func setupUI() {
        headerView.configure(
            title: headerTitle(for: selectedDate),
            subtitle: headerSubtitle(for: selectedDate)
        )

        view.addSubview(headerView)
        view.addSubview(dateStripView)
        view.addSubview(filterView)
        view.addSubview(taskListView)

        dateStripView.onDateSelected = { [weak self] date in
            guard let self else { return }
            self.selectedDate = date
            UIView.transition(with: self.headerView, duration: 0.2, options: .transitionCrossDissolve) {
                self.headerView.configure(
                    title: self.headerTitle(for: date),
                    subtitle: self.headerSubtitle(for: date)
                )
            }
            self.viewModel.dateSelected(date)
        }

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            dateStripView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 14),
            dateStripView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dateStripView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dateStripView.heightAnchor.constraint(equalToConstant: 84),

            filterView.topAnchor.constraint(equalTo: dateStripView.bottomAnchor, constant: 12),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterView.heightAnchor.constraint(equalToConstant: 38),

            taskListView.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 12),
            taskListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            taskListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            taskListView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
