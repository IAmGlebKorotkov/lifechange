//
//  PinterestLayout.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ cv: UICollectionView, heightForItemAt indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat
}

final class PinterestLayout: UICollectionViewLayout {

    weak var delegate: PinterestLayoutDelegate?

    var columnCount: Int = 2
    var spacing: CGFloat = 12
    var insets: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 32, right: 16)

    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let cv = collectionView else { return 0 }
        return cv.bounds.width - insets.left - insets.right
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        guard cache.isEmpty, let cv = collectionView, cv.bounds.width > 0 else { return }

        let colWidth = (contentWidth - spacing * CGFloat(columnCount - 1)) / CGFloat(columnCount)
        let xOffsets: [CGFloat] = (0..<columnCount).map { insets.left + CGFloat($0) * (colWidth + spacing) }
        var yOffsets = [CGFloat](repeating: insets.top, count: columnCount)
        contentHeight = 0

        for item in 0..<cv.numberOfItems(inSection: 0) {
            let ip = IndexPath(item: item, section: 0)
            let col = yOffsets[0] <= yOffsets[1] ? 0 : 1
            let h = delegate?.collectionView(cv, heightForItemAt: ip, columnWidth: colWidth) ?? colWidth
            let frame = CGRect(x: xOffsets[col], y: yOffsets[col], width: colWidth, height: h)
            let attrs = UICollectionViewLayoutAttributes(forCellWith: ip)
            attrs.frame = frame.integral
            cache.append(attrs)
            yOffsets[col] += h + spacing
            contentHeight = max(contentHeight, yOffsets[col])
        }
        contentHeight += insets.bottom
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cache.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item < cache.count else { return nil }
        return cache[indexPath.item]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView else { return false }
        return newBounds.width != cv.bounds.width
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache = []
        contentHeight = 0
    }
}
