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

    private let supportedTypes: ItemTypes
    var collectionViewSize: CGSize
    private weak var presentationInputOutput: PresentationInputOutput!

    private weak var collectionView: UICollectionView!
    private var gapSpace: CGFloat {
        return (collectionViewSize.width - itemSize.width) / 2
    }
    let itemSize = CGSize(width: 30, height: 50)

    private weak var modelInputOutput: ModelInputOutput!
    private let touchAction: () -> Void

    init(collectionView: UICollectionView, modelInputOutput: ModelInputOutput, presentationInputOutput: PresentationInputOutput, supportedTypes: ItemTypes, touchAction: @escaping () -> Void) {
        self.collectionView = collectionView
        self.modelInputOutput = modelInputOutput
        self.supportedTypes = supportedTypes
        self.presentationInputOutput = presentationInputOutput
        collectionViewSize = collectionView.frame.size
        self.touchAction = touchAction
    }

    private func isFirstCell(indexPath: IndexPath) -> Bool {
        return indexPath.row == 0
    }

    private func isLastCell(indexPath: IndexPath) -> Bool {
        return indexPath.row == modelInputOutput.numberOfItems(withTypes: supportedTypes) - 1
    }

}

extension CarouselControlAdapter: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return modelInputOutput.numberOfItems(withTypes: supportedTypes)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselControlCollectionViewCell",
                                                      for: indexPath) as! CarouselControlCollectionViewCell

        let leftOffset: CGFloat = isFirstCell(indexPath: indexPath) ? gapSpace : 0
        let rightOffset: CGFloat = isLastCell(indexPath: indexPath) ? gapSpace : 0

        if let item = modelInputOutput.item(withTypes: supportedTypes, at: indexPath) {
            if let cachedImage = ImageCache.shared.sizedImage(forKey: item.id) {
                cell.configureCell(image: cachedImage, leftOffset: leftOffset, rightOffset: rightOffset)
            } else {
                cell.configureCell(image: nil, leftOffset: leftOffset, rightOffset: rightOffset)
                DispatchQueue.global()
                    .async {
                        //to avoid task for same item in "willDisplay cell"
                        ImageCache.shared.setSized(UIImage(), forKey: item.id)
                        let sizedImage = UIImageHelper.imageWithImage(image: item.image, scaledToSize: self.itemSize)
                        ImageCache.shared.setSized(sizedImage, forKey: item.id)
                        DispatchQueue.main.async {
                            cell.image = sizedImage
                        }
                    }
            }
        }

        return cell
    }

    private func updateCurrentCellIndexPath(_ contentOffset: CGFloat) {
        let centerPoint = CGPoint(x: collectionView.frame.width / 2, y: 0)
        let convertedPoint = collectionView.convert(centerPoint, from: collectionView.backgroundView)
        if let currentIndex = collectionView.indexPathForItem(at: CGPoint(x: convertedPoint.x, y: 0)) {
            presentationInputOutput.setItemAsCurrent(at: currentIndex, withTypes: supportedTypes)
        }
    }

}

extension CarouselControlAdapter: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking {
            touchAction()
        }
        if scrollView.isTracking {
            scrollView.setContentOffset(scrollView.contentOffset, animated: false)

        }
        if scrollView.isDragging {
            updateCurrentCellIndexPath(scrollView.contentOffset.x)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentationInputOutput.setItemAsCurrent(at: indexPath, withTypes: supportedTypes)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        collectionView.scrollToItem(
            at: presentationInputOutput.currentItemIndex(withTypes: supportedTypes),
            at: .centeredHorizontally,
            animated: true
        )
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        collectionView.scrollToItem(
            at: presentationInputOutput.currentItemIndex(withTypes: supportedTypes),
            at: .centeredHorizontally,
            animated: true
        )
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let start = -20
        let count = 20

        for delta in start..<count {
            if let item = modelInputOutput.item(
                withTypes: supportedTypes,
                at: IndexPath(item: max(indexPath.row + delta, 0), section: 0)
            ),
               ImageCache.shared.sizedImage(forKey: item.id) == nil {
                ImageCache.shared.setSized(UIImage(), forKey: item.id)
                DispatchQueue.global()
                    .async {
                        let sizedImage = UIImageHelper.imageWithImage(image: item.image, scaledToSize: self.itemSize)
                        ImageCache.shared.setSized(sizedImage, forKey: item.id)
                    }
            }
        }
    }

}

extension CarouselControlAdapter: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemWidth = itemSize.width
        if isFirstCell(indexPath: indexPath) {
            itemWidth += gapSpace
        }
        if isLastCell(indexPath: indexPath) {
            itemWidth += gapSpace
        }

        return CGSize(width: itemWidth, height: itemSize.height)
    }

}
