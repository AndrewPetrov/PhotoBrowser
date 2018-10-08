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
        didSet {
            selectionImageView.image = isSelected ? #imageLiteral(resourceName: "iOSPhotoBrowser_selected") : nil
        }
    }
    
    @IBOutlet private weak var selectionImagView: UIImageView!
    @IBOutlet private weak var videoImagView: UIImageView!
    @IBOutlet private weak var videoDurationLabel: UILabel!
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var selectionImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    func configureCell(image: UIImage?,
                       isSelectionAllowed: Bool,
                       isVideo: Bool,
                       videoDuration: String = "",
                       isLiked: Bool) {
        imageView.image = image
        selectionImageView.isHidden = !isSelectionAllowed
        videoImagView.isHidden = !isVideo
        videoDurationLabel.text = videoDuration
    }
    
}
