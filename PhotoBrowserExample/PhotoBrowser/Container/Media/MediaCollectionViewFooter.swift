//
//  MediaCollectionViewFooter.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/18/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class MediaCollectionViewFooter: UICollectionReusableView {

    @IBOutlet weak var countLabel: UILabel!

    func configureView(text: String) {
        countLabel.text = text
    }
}

