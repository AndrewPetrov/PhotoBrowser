//
//  MediaCollectionViewHeader.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/18/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class MediaCollectionViewHeader: UICollectionReusableView {

    @IBOutlet weak var dateLabel: UILabel!

    func configureView(text: String) {
        dateLabel.text = text
    }
}

