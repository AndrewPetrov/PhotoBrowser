//
//  CarouselControlCollectionLayout.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/13/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class CarouselControlCollectionLayout: UICollectionViewFlowLayout {

    private let supportedTypes: [ItemType]

    private weak var presentationInputOutput: PresentationInputOutput!

    init(presentationInputOutput: PresentationInputOutput, supportedTypes: [ItemType]) {
        self.presentationInputOutput = presentationInputOutput
        self.supportedTypes = supportedTypes

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    

//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
////        return super.layoutAttributesForItem(at: indexPath)
//
//        let currentIndexPath = presentationInputOutput.currentItemIndex()
//
//        let height = 40
//        let width = 40
//
//        let row = indexPath.row
//        var layoutAttributes = UICollectionViewLayoutAttributes()
////        layoutAttributes.frame = CGRect(x: width * row, y: 0, width: width, height: height)
//        if currentIndexPath == indexPath {
//            layoutAttributes.size = CGSize(width: width * 2, height: height)
//        }
//
//        return layoutAttributes
//    }
//
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        print(rect)
//        return super.layoutAttributesForElements(in: rect)
//    }


}
