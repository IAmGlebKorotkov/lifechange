//
//  CalendarDateStripView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class CalendarDateStripView: UIView {

    var onDateSelected: ((Date) -> Void)?


    private var dates: [Date] = []
    private var selectedIndex: Int = 0


    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.decelerationRate = .fast
        cv.dataSource = self
        cv.delegate = self
        cv.register(DateCell.self, forCellWithReuseIdentifier: DateCell.reuseID)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private var slotWidth: CGFloat {
        let insets: CGFloat = 40
        let spacing: CGFloat = 40
        let cellWidth = floor((collectionView.bounds.width - insets - spacing) / 4.5)
        return cellWidth + 10
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        generateDates()
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func scrollToToday() {
        collectionView.scrollToItem(
            at: IndexPath(item: selectedIndex, section: 0),
            at: .centeredHorizontally,
            animated: false
        )
    }


    private func generateDates() {
        let calendar = Calendar.current
        let today = Date()
        dates = (-30...60).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today)
        }
        selectedIndex = 30
    }
}


extension CalendarDateStripView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DateCell.reuseID,
            for: indexPath
        ) as! DateCell
        cell.configure(date: dates[indexPath.item], isSelected: indexPath.item == selectedIndex)
        return cell
    }
}


extension CalendarDateStripView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != selectedIndex else { return }

        let previousIndex = IndexPath(item: selectedIndex, section: 0)
        selectedIndex = indexPath.item

        collectionView.reloadItems(at: [previousIndex, indexPath])
        onDateSelected?(dates[indexPath.item])
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let slot = slotWidth
        guard slot > 0 else { return }

        let rawIndex: CGFloat
        if velocity.x > 0.3 {
            rawIndex = ceil(targetContentOffset.pointee.x / slot)
        } else if velocity.x < -0.3 {
            rawIndex = floor(targetContentOffset.pointee.x / slot)
        } else {
            rawIndex = (targetContentOffset.pointee.x / slot).rounded()
        }

        let index = Int(max(0, min(CGFloat(dates.count - 1), rawIndex)))
        targetContentOffset.pointee = CGPoint(x: CGFloat(index) * slot, y: 0)
    }
}


extension CalendarDateStripView: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let insets: CGFloat = 20 * 2
        let spacing: CGFloat = 10 * 4
        let availableWidth = collectionView.bounds.width - insets - spacing
        let cellWidth = floor(availableWidth / 4.5)
        return CGSize(width: cellWidth, height: 102)
    }
}
