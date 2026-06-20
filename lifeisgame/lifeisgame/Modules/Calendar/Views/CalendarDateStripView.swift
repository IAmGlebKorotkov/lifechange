//
//  CalendarDateStripView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class CalendarDateStripView: UIView {

    var onDateSelected: ((Date) -> Void)?

    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date())
    private let todayIndex = 36_500
    private let dateCount = 73_001
    private var selectedIndex = 36_500


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

    private var cellWidth: CGFloat {
        let insets = collectionLayout.sectionInset.left + collectionLayout.sectionInset.right
        let spacing = collectionLayout.minimumLineSpacing * 4
        return max(44, floor((collectionView.bounds.width - insets - spacing) / 4.5))
    }

    private var slotWidth: CGFloat {
        cellWidth + collectionLayout.minimumLineSpacing
    }

    private var collectionLayout: UICollectionViewFlowLayout {
        collectionView.collectionViewLayout as? UICollectionViewFlowLayout ?? UICollectionViewFlowLayout()
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
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
        selectedIndex = todayIndex
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(
            at: IndexPath(item: selectedIndex, section: 0),
            at: .centeredHorizontally,
            animated: false
        )
    }

    private func date(for index: Int) -> Date {
        calendar.date(byAdding: .day, value: index - todayIndex, to: today) ?? today
    }

    private func centeredContentOffsetX(for index: Int) -> CGFloat {
        let itemCenterX = collectionLayout.sectionInset.left
            + CGFloat(index) * slotWidth
            + cellWidth / 2
        let maxOffsetX = max(0, collectionView.contentSize.width - collectionView.bounds.width)
        return min(max(0, itemCenterX - collectionView.bounds.width / 2), maxOffsetX)
    }

    private func nearestIndex(for contentOffsetX: CGFloat, velocityX: CGFloat) -> Int {
        let centeredX = contentOffsetX
            + collectionView.bounds.width / 2
            - collectionLayout.sectionInset.left
            - cellWidth / 2
        let rawIndex = centeredX / slotWidth
        let roundedIndex: CGFloat

        if velocityX > 0.3 {
            roundedIndex = ceil(rawIndex)
        } else if velocityX < -0.3 {
            roundedIndex = floor(rawIndex)
        } else {
            roundedIndex = rawIndex.rounded()
        }

        return Int(max(0, min(CGFloat(dateCount - 1), roundedIndex)))
    }
}


extension CalendarDateStripView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dateCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DateCell.reuseID,
            for: indexPath
        ) as? DateCell else {
            return UICollectionViewCell()
        }
        cell.configure(date: date(for: indexPath.item), isSelected: indexPath.item == selectedIndex)
        return cell
    }
}


extension CalendarDateStripView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != selectedIndex else { return }

        let previousIndex = IndexPath(item: selectedIndex, section: 0)
        selectedIndex = indexPath.item

        collectionView.reloadItems(at: [previousIndex, indexPath])
        onDateSelected?(date(for: indexPath.item))
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard slotWidth > 0 else { return }

        let index = nearestIndex(for: targetContentOffset.pointee.x, velocityX: velocity.x)
        targetContentOffset.pointee = CGPoint(x: centeredContentOffsetX(for: index), y: 0)
    }
}


extension CalendarDateStripView: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: cellWidth, height: 102)
    }
}
