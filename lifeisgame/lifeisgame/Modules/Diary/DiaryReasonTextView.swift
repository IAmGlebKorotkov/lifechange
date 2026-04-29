//
//  DiaryReasonTextView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class DiaryReasonTextView: UIView {


    private let headerLabel: UILabel = {
        let l = UILabel()
        l.text = "Причина"
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = UIColor.main
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.textColor = .label
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.text = "Опишите причину вашего состояния..."
        l.font = .systemFont(ofSize: 15)
        l.textColor = .tertiaryLabel
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 14

        addSubview(headerLabel)
        addSubview(divider)
        addSubview(textView)
        textView.addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            divider.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            textView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 4),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),

            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 4),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -4)
        ])

        textView.delegate = self
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
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
