//
//  AchievementsViewController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class AchievementsViewController: UIViewController {


    private var items: [AchievementItem] = AchievementItem.samples


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Достижения"
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dismissButton: UIButton = {
        let b = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        b.tintColor = .label
        b.backgroundColor = UIColor.systemGray5
        b.layer.cornerRadius = 20
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = PinterestLayout()
        layout.delegate = self
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(AchievementCell.self, forCellWithReuseIdentifier: AchievementCell.reuseID)
        cv.dataSource = self
        return cv
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupLayout()
    }


    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(dismissButton)
        view.addSubview(collectionView)

        dismissButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        dismissButton.enablePressScale(to: 0.90)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            dismissButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dismissButton.widthAnchor.constraint(equalToConstant: 40),
            dismissButton.heightAnchor.constraint(equalToConstant: 40),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }


    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}


extension AchievementsViewController: UICollectionViewDataSource {

    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(
            withReuseIdentifier: AchievementCell.reuseID, for: indexPath
        ) as! AchievementCell

        cell.configure(with: items[indexPath.item])

        cell.onOpened = { [weak self] in
            self?.items[indexPath.item].state = .opened
        }

        return cell
    }
}


extension AchievementsViewController: PinterestLayoutDelegate {

    func collectionView(_ cv: UICollectionView, heightForItemAt indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat {
        items[indexPath.item].cellHeight
    }
}
