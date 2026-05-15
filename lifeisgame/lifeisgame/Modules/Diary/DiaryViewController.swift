//
//  DiaryViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class DiaryViewController: UIViewController {


    private enum DiaryType: CaseIterable {
        case emotions, sleep
        var iconName: String { self == .emotions ? "Lol"            : "Time_sleep" }
        var title: String    { self == .emotions ? "Дневник эмоций" : "Дневник сна" }
    }


    private var selectedDiary: DiaryType = .emotions
    private let repository: DiaryRepositoryProtocol


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Дневник эмоций и сна"
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let diaryPickerView = DiaryPickerView(sectionTitle: "Дневник")
    private let emotionDiaryView = EmotionDiaryView()
    private let sleepDiaryView   = SleepDiaryView()


    init(repository: DiaryRepositoryProtocol) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupUI()
        setupKeyboardDismissGesture()
        bindActions()
        refreshDiaryPicker()
    }


    private func setupUI() {
        sleepDiaryView.isHidden = true
        sleepDiaryView.alpha    = 0

        view.addSubview(titleLabel)
        view.addSubview(diaryPickerView)
        view.addSubview(emotionDiaryView)
        view.addSubview(sleepDiaryView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            diaryPickerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            diaryPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            diaryPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            diaryPickerView.heightAnchor.constraint(equalToConstant: 63),

            emotionDiaryView.topAnchor.constraint(equalTo: diaryPickerView.bottomAnchor, constant: 12),
            emotionDiaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emotionDiaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emotionDiaryView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            sleepDiaryView.topAnchor.constraint(equalTo: diaryPickerView.bottomAnchor, constant: 12),
            sleepDiaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sleepDiaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sleepDiaryView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }


    private func refreshDiaryPicker() {
        let diary = selectedDiary
        let icon  = UIImage(named: diary.iconName)?.withRenderingMode(.alwaysOriginal)
        diaryPickerView.update(icon: icon, selectionText: diary.title, menu: makeDiaryMenu())
    }

    private func makeDiaryMenu() -> UIMenu {
        let actions = DiaryType.allCases.map { type in
            UIAction(
                title: type.title,
                image: UIImage(named: type.iconName)?.withRenderingMode(.alwaysOriginal),
                state: type == selectedDiary ? .on : .off
            ) { [weak self] _ in
                guard let self, type != self.selectedDiary else { return }
                self.selectedDiary = type
                self.refreshDiaryPicker()
                self.switchContent(to: type)
            }
        }
        return UIMenu(title: "", children: actions)
    }


    private func switchContent(to type: DiaryType) {
        let showEmotions = type == .emotions
        let appearing  = showEmotions ? emotionDiaryView : sleepDiaryView
        let disappearing = showEmotions ? sleepDiaryView : emotionDiaryView

        appearing.isHidden = false
        UIView.animate(withDuration: 0.2) {
            appearing.alpha    = 1
            disappearing.alpha = 0
        } completion: { _ in
            disappearing.isHidden = true
        }
    }


    private func bindActions() {
        emotionDiaryView.onSaveRequested = { [weak self] entries in
            self?.saveEmotionEntries(entries)
        }
        sleepDiaryView.onSaveRequested = { [weak self] bedtime, wakeTime in
            self?.saveSleepEntry(bedtime: bedtime, wakeTime: wakeTime)
        }
    }

    private func saveEmotionEntries(_ entries: [EmotionDiaryInput]) {
        guard let userID = SessionManager.shared.currentUserID else {
            showAlert(title: "Не удалось сохранить", message: "Пользователь не найден.")
            return
        }

        do {
            try repository.saveEmotionEntries(entries, forUserID: userID, on: Date())
            LocalNotificationService.shared.cancelEmotionDiaryReminders(on: Date())
            emotionDiaryView.resetAfterSave()
        } catch {
            showAlert(title: "Не удалось сохранить", message: error.localizedDescription)
        }
    }

    private func saveSleepEntry(bedtime: Date, wakeTime: Date) {
        guard let userID = SessionManager.shared.currentUserID else {
            showAlert(title: "Не удалось сохранить", message: "Пользователь не найден.")
            return
        }

        do {
            try repository.saveSleepEntry(bedtime: bedtime, wakeTime: wakeTime, forUserID: userID, on: Date())
            LocalNotificationService.shared.cancelSleepDiaryReminders(on: Date())
            sleepDiaryView.showSavedState()
        } catch {
            showAlert(title: "Не удалось сохранить", message: error.localizedDescription)
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension DiaryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !isTextViewOrDescendant(touch.view)
    }

    private func isTextViewOrDescendant(_ touchedView: UIView?) -> Bool {
        var currentView = touchedView
        while let view = currentView {
            if view is UITextView {
                return true
            }
            currentView = view.superview
        }
        return false
    }
}
