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

    var gapSpace: CGFloat = 0
    
    private weak var presentationInputOutput: PresentationInputOutput!

    init(presentationInputOutput: PresentationInputOutput, supportedTypes: [ItemType]) {
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
}

extension CarouselControlAdapter: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }




}

extension CarouselControlAdapter: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isFirstCell(indexPath: indexPath) || isLastCell(indexPath: indexPath) {
            return CGSize(width: 30 + gapSpace, height: 50)
        } else {
            return CGSize(width: 30, height: 50)
        }

    }

}



//extension CarouselControlAdapter: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if indexPath == presentationInputOutput.currentItemIndex() {
//            return CGSize(width: 100, height: 50)
//        }
//        return CGSize(width: 50, height: 50)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        if indexPath == presentationInputOutput.currentItemIndex() {
//            return 10
//        }
//        return 0
//
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
//
//}


