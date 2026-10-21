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
        var iconName: String { self == .emotions ? "Lol" : "Time_sleep" }
        var title: String    { self == .emotions ? "Эмоции" : "Сон" }
    }


    private var selectedDiary: DiaryType = .emotions
    private let viewModel: DiaryViewModel
    private let maximumHeaderCollapse: CGFloat = 48


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Дневник"
        l.font = .systemFont(ofSize: 30, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let diaryPickerView = DiaryPickerView(sectionTitle: "Дневник")
    private let emotionDiaryView = EmotionDiaryView()
    private let sleepDiaryView   = SleepDiaryView()


    init(viewModel: DiaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupUI()
        setupScrollTracking()
        setupKeyboardDismissGesture()
        bindActions()
        bindViewModel()
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
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),

            diaryPickerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 9),
            diaryPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            diaryPickerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            emotionDiaryView.topAnchor.constraint(equalTo: diaryPickerView.bottomAnchor, constant: 12),
            emotionDiaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emotionDiaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emotionDiaryView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: maximumHeaderCollapse
            ),

            sleepDiaryView.topAnchor.constraint(equalTo: diaryPickerView.bottomAnchor, constant: 12),
            sleepDiaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sleepDiaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sleepDiaryView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: maximumHeaderCollapse
            )
        ])
    }

    private func setupScrollTracking() {
        emotionDiaryView.onVerticalScroll = { [weak self] offset in
            guard self?.selectedDiary == .emotions else { return }
            self?.updateHeader(for: offset, animated: false)
        }
        sleepDiaryView.onVerticalScroll = { [weak self] offset in
            guard self?.selectedDiary == .sleep else { return }
            self?.updateHeader(for: offset, animated: false)
        }
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
        updateHeader(
            for: showEmotions
                ? emotionDiaryView.verticalScrollOffset
                : sleepDiaryView.verticalScrollOffset,
            animated: true
        )
        UIView.animate(withDuration: 0.2) {
            appearing.alpha    = 1
            disappearing.alpha = 0
        } completion: { _ in
            disappearing.isHidden = true
        }
    }

    private func updateHeader(for scrollOffset: CGFloat, animated: Bool) {
        let collapse = min(max(0, scrollOffset), maximumHeaderCollapse)
        let progress = collapse / maximumHeaderCollapse
        let changes = {
            let translation = CGAffineTransform(translationX: 0, y: -collapse)
            self.titleLabel.transform = translation
            self.titleLabel.alpha = 1 - progress
            self.diaryPickerView.transform = translation
            self.emotionDiaryView.transform = translation
            self.sleepDiaryView.transform = translation
            self.emotionDiaryView.applyHeaderCompensation(collapse)
            self.sleepDiaryView.applyHeaderCompensation(collapse)
        }

        guard animated, !UIAccessibility.isReduceMotionEnabled else {
            changes()
            return
        }

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseInOut],
            animations: changes
        )
    }


    private func bindActions() {
        emotionDiaryView.onSaveRequested = { [weak self] entries in
            self?.viewModel.saveEmotionEntries(entries)
        }
        sleepDiaryView.onSaveRequested = { [weak self] bedtime, wakeTime in
            self?.viewModel.saveSleepEntry(bedtime: bedtime, wakeTime: wakeTime)
        }
    }

    private func bindViewModel() {
        viewModel.onEmotionEntriesSaved = { [weak self] in
            self?.emotionDiaryView.resetAfterSave()
        }
        viewModel.onSleepEntrySaved = { [weak self] in
            self?.sleepDiaryView.showSavedState()
        }
        viewModel.onSaveFailed = { [weak self] message in
            self?.showAlert(title: "Не удалось сохранить", message: message)
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
