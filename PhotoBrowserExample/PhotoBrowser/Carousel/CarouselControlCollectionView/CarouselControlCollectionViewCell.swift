//
//  CarouselControlCollectionViewCell.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/13/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class CarouselControlCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightConstraint: NSLayoutConstraint!

    weak var image: UIImage? {
        didSet {
            imageView.image = image
            imageView.alpha = 0
            UIView.animate(withDuration: 0.2) {
                self.imageView.alpha = 1
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
    }

    func configureCell(image: UIImage?, leftOffset: CGFloat, rightOffset: CGFloat) {
        imageView.image = image
        leftConstraint.constant = leftOffset
        rightConstraint.constant = rightOffset
    }
}
