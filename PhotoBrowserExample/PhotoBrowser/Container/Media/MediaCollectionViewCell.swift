//
//  GridCollectionViewCell.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/10/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class MediaCollectionViewCell: UICollectionViewCell {

    override var isSelected: Bool {
        didSet{
            updateSelectionImage(isSelected: isSelected)
        }
    }

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var selectionImageView: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
    }

    private func updateSelectionImage(isSelected: Bool) {
        selectionImageView.image = isSelected ? #imageLiteral(resourceName: "selected") : #imageLiteral(resourceName: "nonSelected")
    }

    func configureCell(image: UIImage?, isSelectionAllowed: Bool, isSelected: Bool) {
        imageView.image = image
        selectionImageView.isHidden = !isSelectionAllowed
        updateSelectionImage(isSelected: isSelected)
    }

}
