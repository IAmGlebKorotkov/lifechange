//
//  EmotionDiaryView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class EmotionDiaryView: UIView {


    var onSaveRequested: (([EmotionDiaryInput]) -> Void)?
    var onVerticalScroll: ((CGFloat) -> Void)?

    var verticalScrollOffset: CGFloat {
        max(0, scrollView.contentOffset.y + scrollView.adjustedContentInset.top)
    }


    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .onDrag
        sv.clipsToBounds = true
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

    private let bottomScrollSpacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 96).isActive = true
        return view
    }()

    private let questionLabel: UILabel = {
        let l = UILabel()
        l.text = "Как вы себя чувствуете?"
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = UIColor(rgb: 0x3C3C43, alpha: 0.6)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emotionGridView = EmotionGridView()
    private let reasonTextView = DiaryReasonTextView()
    private let intensityView  = DiaryIntensityView()

    private let saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Сохранить", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor.main
        b.layer.cornerRadius = 16
        b.applyPrimaryButtonShadow()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 54).isActive = true
        return b
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
        scrollView.delegate = self
        saveButton.enablePressScale()
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    private func setupLayout() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        contentStack.addArrangedSubview(questionLabel)
        contentStack.setCustomSpacing(13, after: questionLabel)
        contentStack.addArrangedSubview(emotionGridView)
        contentStack.addArrangedSubview(reasonTextView)
        contentStack.addArrangedSubview(intensityView)
        contentStack.setCustomSpacing(22, after: intensityView)
        contentStack.addArrangedSubview(saveButton)
        contentStack.addArrangedSubview(bottomScrollSpacer)
    }

    func applyHeaderCompensation(_ offset: CGFloat) {
        contentStack.transform = CGAffineTransform(translationX: 0, y: offset)
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
        let emotion = emotionGridView.selectedEmotion
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

extension EmotionDiaryView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onVerticalScroll?(verticalScrollOffset)
    }
}
