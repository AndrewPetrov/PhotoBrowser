//
//  TableViewCell.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/10/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var mainImageView: UIImageView!

    @IBOutlet weak var buttomInset: NSLayoutConstraint!

    override func prepareForReuse() {
        super.prepareForReuse()

        mainImageView.image = nil
    }

    func configureCell(image: UIImage?, hasInset: Bool) {
        if hasInset {
            buttomInset.constant = TableViewController.inset
        }
        else {
            buttomInset.constant = 0
        }
        mainImageView.image = image
    }
    
}
