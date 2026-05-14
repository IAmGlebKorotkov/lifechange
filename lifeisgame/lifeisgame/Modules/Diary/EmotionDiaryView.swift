//
//  EmotionDiaryView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class EmotionDiaryView: UIView {


    var onSaveRequested: (([EmotionDiaryInput]) -> Void)?


    private struct Emotion {
        let name: String
        let sfSymbol: String
    }

    private let emotions: [Emotion] = [
        Emotion(name: "Радость", sfSymbol: "sun.max"),
        Emotion(name: "Грусть",  sfSymbol: "cloud.rain"),
        Emotion(name: "Злость",  sfSymbol: "flame"),
        Emotion(name: "Тревога", sfSymbol: "wind"),
        Emotion(name: "Покой",   sfSymbol: "leaf"),
        Emotion(name: "Любовь",  sfSymbol: "heart")
    ]

    private var selectedEmotionIndex: Int = 0


    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .onDrag
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let emotionsTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Эмоции"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = UIColor.main
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emotionPickerView = DiaryPickerView(sectionTitle: "Эмоция")

    private let reasonTextView = DiaryReasonTextView()
    private let intensityView  = DiaryIntensityView()

    private let saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Сохранить", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor.main
        b.layer.cornerRadius = 14
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 54).isActive = true
        return b
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
        refreshEmotionPicker()
        saveButton.enablePressScale()
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    private func setupLayout() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        emotionPickerView.heightAnchor.constraint(equalToConstant: 63).isActive = true

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        contentStack.addArrangedSubview(emotionsTitleLabel)
        contentStack.addArrangedSubview(emotionPickerView)
        contentStack.addArrangedSubview(reasonTextView)
        contentStack.addArrangedSubview(intensityView)
        contentStack.addArrangedSubview(saveButton)
    }


    private func refreshEmotionPicker() {
        let emotion = emotions[selectedEmotionIndex]
        let icon = UIImage(systemName: emotion.sfSymbol,
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .medium))
        emotionPickerView.update(
            icon: icon?.withTintColor(UIColor.main, renderingMode: .alwaysOriginal),
            selectionText: "\(emotion.name)",
            menu: makeEmotionMenu()
        )
    }

    private func makeEmotionMenu() -> UIMenu {
        let actions = emotions.enumerated().map { i, emotion in
            UIAction(
                title: "\(emotion.name)",
                image: UIImage(systemName: emotion.sfSymbol),
                state: i == selectedEmotionIndex ? .on : .off
            ) { [weak self] _ in
                guard let self, i != self.selectedEmotionIndex else { return }
                self.selectedEmotionIndex = i
                self.refreshEmotionPicker()
            }
        }
        return UIMenu(title: "", children: actions)
    }

    @objc private func saveTapped() {
        onSaveRequested?([currentInput()])
    }

    func resetAfterSave() {
        resetCurrentInput()
        endEditing(true)
        showSavedFeedback()
    }

    private func currentInput() -> EmotionDiaryInput {
        let emotion = emotions[selectedEmotionIndex]
        return EmotionDiaryInput(
            emotionName: emotion.name,
            sfSymbol: emotion.sfSymbol,
            reason: reasonTextView.text,
            intensity: intensityView.value
        )
    }

    private func resetCurrentInput() {
        reasonTextView.reset()
        intensityView.reset()
    }

    private func showSavedFeedback() {
        saveButton.setTitle("Сохранено", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.saveButton.setTitle("Сохранить", for: .normal)
        }
    }
}
