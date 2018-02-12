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

    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
    }

    func configureCell(image: UIImage?) {
        imageView.image = image
    }

    @IBAction func selectButtonDidTap(_ sender: UIButton) {
        selectionButton.isSelected = !selectionButton.isSelected
//        selectionHandler(selectionButton.isSelected)
    }

}
