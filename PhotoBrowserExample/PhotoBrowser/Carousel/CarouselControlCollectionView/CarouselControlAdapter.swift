//
//  CarouselAdapter.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/13/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class CarouselControlAdapter: NSObject {

    private let supportedTypes: [ItemType]

    private weak var collectionView: UICollectionView!
    private var gapSpace: CGFloat {
        return (collectionView.frame.width - itemSize.width) / 2
    }
    let itemSize = CGSize(width: 30, height: 50)

    private weak var presentationInputOutput: PresentationInputOutput!

    init(collectionView: UICollectionView, presentationInputOutput: PresentationInputOutput, supportedTypes: [ItemType]) {
        self.collectionView = collectionView
        self.presentationInputOutput = presentationInputOutput
        self.supportedTypes = supportedTypes
    }

    private func isFirstCell(indexPath: IndexPath) -> Bool {
        return indexPath.row == 0
    }

    private func isLastCell(indexPath: IndexPath) -> Bool {
        return indexPath.row == presentationInputOutput.numberOfItems(withType: supportedTypes) - 1
    }

}


extension CarouselControlAdapter: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return presentationInputOutput.numberOfItems(withType: supportedTypes)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselControlCollectionViewCell",
                                                      for: indexPath) as! CarouselControlCollectionViewCell

        let leftOffset: CGFloat = isFirstCell(indexPath: indexPath) ? gapSpace : 0
        let rightOffset: CGFloat = isLastCell(indexPath: indexPath) ? gapSpace : 0

        if let item = presentationInputOutput.item(withType: supportedTypes, at: indexPath) {
            cell.configureCell(image: item.image, leftOffset: leftOffset, rightOffset: rightOffset)
        }

        return cell
    }

    private func updateCurrentCellIndexPath(_ contentOffset: CGFloat) {
        let centerPoint = CGPoint(x: collectionView.frame.width / 2 , y: 0)
        let convertedPoint = collectionView.convert(centerPoint, from: collectionView.backgroundView)
        if let currentIndex = collectionView.indexPathForItem(at: CGPoint(x: convertedPoint.x, y: 0)) {
            presentationInputOutput.setItemAsCurrent(at: currentIndex)
        }
    }
    
}

extension CarouselControlAdapter: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            updateCurrentCellIndexPath(scrollView.contentOffset.x)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentationInputOutput.setItemAsCurrent(at: indexPath)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        collectionView.scrollToItem(at: presentationInputOutput.currentItemIndex(), at: .centeredHorizontally, animated: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        collectionView.scrollToItem(at: presentationInputOutput.currentItemIndex(), at: .centeredHorizontally, animated: true)
    }

}

extension CarouselControlAdapter: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemWidth = itemSize.width
        if isFirstCell(indexPath: indexPath) || isLastCell(indexPath: indexPath) {
            itemWidth += gapSpace
        }

        return CGSize(width: itemWidth, height: itemSize.height)
    }

}
