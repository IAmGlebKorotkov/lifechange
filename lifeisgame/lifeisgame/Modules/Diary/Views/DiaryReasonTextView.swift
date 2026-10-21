//
//  DiaryReasonTextView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class DiaryReasonTextView: UIView {

    var text: String {
        textView.text
    }


    private let headerLabel: UILabel = {
        let l = UILabel()
        l.text = "Причина (необязательно)"
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(rgb: 0x3C3C43, alpha: 0.5)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    let textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.textColor = .label
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 4, left: 0, bottom: 8, right: 0)
        tv.textContainer.lineFragmentPadding = 0
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.text = "Спокойный вечер после прогулки…"
        l.font = .systemFont(ofSize: 16)
        l.textColor = UIColor(rgb: 0x3C3C43, alpha: 0.4)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 18
        applyCardShadow(strength: 0.7)

        addSubview(headerLabel)
        addSubview(textView)
        textView.addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            textView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 2),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64),

            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 4),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor)
        ])

        textView.delegate = self
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func reset() {
        textView.text = ""
        placeholderLabel.isHidden = false
    }
}


extension DiaryReasonTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
