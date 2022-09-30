//
//  LiquidCollectionViewLayout.swift
//  Notes
//
//  Created by MAC BOOK on 15/09/22.
//

import UIKit

public protocol LiquidLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGSize
}

public class LiquidCollectionViewLayout: UICollectionViewLayout {

//    var delegate: LiquidLayoutDelegate!
    var cellPadding: CGFloat = 0
    var cellWidth: CGFloat = 150.0
    var cachedWidth: CGFloat = 0.0
    var notesArray = [Notes]()
    var isUpdateView = true

    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    fileprivate var contentHeight: CGFloat  = 0.0
    fileprivate var contentWidth: CGFloat {
        if let collectionView = collectionView {
            let insets = collectionView.contentInset
            return collectionView.bounds.width - (insets.left + insets.right)
        }
        return 0
    }
    fileprivate var numberOfItems = 0

    override public var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    public override func prepare() {
        guard let collectionView = collectionView else { return }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        var itemSize = [CGRect]()
        if (self.numberOfItems != numberOfItems) || isUpdateView {
            cache = []
            contentHeight = 0
            self.numberOfItems = numberOfItems
        }
        if cache.isEmpty {
            self.isUpdateView = false
            var totFrame = [CGRect]()
            var preFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
            for (id, note) in notesArray.enumerated() {
                let width = note.image == nil ? (collectionView.frame.width/2) : collectionView.frame.width
                var xOffset = CGFloat(0)
                if note.image == nil && (id) != 0{
                    let preNotes = notesArray[id-1]
                    if (preNotes.image == nil) && (totFrame[id-1].origin.x == CGFloat(0)){
                        xOffset = width
                    }
                    else {
                        xOffset = CGFloat(0)
                    }
                }
                else {
                    xOffset = CGFloat(0)
                }
                let titleHeight = CalclulateCellSize.shared.calculateSize(note.title ?? "", font: TITLE_FONT, width: note.image == nil ? (collectionView.frame.width/2)-30 : collectionView.frame.width-40)
                let timeHeight = CalclulateCellSize.shared.calculateSize("\(note.created_time ?? Date())", font: DATE_FONT, width: (collectionView.frame.width/2)-20)
                let height = titleHeight.height+timeHeight.height+40
                var yOffset = CGFloat(0)
                if id == 0 {
                    yOffset = CGFloat(0)
                }
                else {
                    let y = preFrame.origin.y+preFrame.height
                    yOffset = preFrame.origin.y
                    if note.image == nil && (id) != 0 {
                        let preNotes = notesArray[id-1]
                        if (preNotes.image == nil) && (totFrame[id-1].origin.x == CGFloat(0)){
                            if id > 1 && xOffset != 0{
                                let upperFrame = totFrame[id-2].origin.y+totFrame[id-2].height
                                yOffset = upperFrame
                            }
                        }
                        else {
                            yOffset = y
                            if totFrame[id-1].origin.x != CGFloat(0) && preNotes.image == nil && xOffset == 0 {
                                if id-2 > 0 {
                                    let y = totFrame[id-2].origin.y+totFrame[id-2].height
                                    yOffset = y
                                }
                            }
                        }
//                        if note.image != nil && id > 1 {
//                            let lastItem = notesArray[id-1]
//                            let preItem = notesArray[id-2]
//                            if lastItem.image == nil && preItem.image == nil {
//                                yOffset = totFrame[id-1].height > totFrame[id-2].height ? (totFrame[id-1].origin.y+totFrame[id-1].height) : (totFrame[id-2].origin.y+totFrame[id-2].height)
//                            }
//                        }
                    }
                    else {
                        yOffset = y
                        if note.image != nil && id > 1 {
                            let lastItem = notesArray[id-1]
                            let preItem = notesArray[id-2]
                            if lastItem.image == nil && preItem.image == nil {
                                yOffset = totFrame[id-1].height > totFrame[id-2].height ? (totFrame[id-1].origin.y+totFrame[id-1].height) : (totFrame[id-2].origin.y+totFrame[id-2].height)
                            }
                        }
                        
                    }
                }
                let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
                let insetFrame = frame.insetBy(dx: 0, dy: cellPadding)
                totFrame.append(insetFrame)
                preFrame = insetFrame
                let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: id, section: 0) as IndexPath) // #4
                attributes.frame = insetFrame // #5
                if id == (self.notesArray.count-1) {
                    contentHeight = yOffset+height
                }
                cache.append(attributes) // #6
            }
        }
    }
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()

        for attributes in cache { // #7
            if attributes.frame.intersects(rect) { // #8
                layoutAttributes.append(attributes) // #9
            }
        }
        return layoutAttributes
    }
}
