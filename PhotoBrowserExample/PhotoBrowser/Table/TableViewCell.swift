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

    override func prepareForReuse() {
        super.prepareForReuse()

        mainImageView.image = nil
    }

    func configureCell(image: UIImage?) {
        mainImageView.image = image
    }
    
}
