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

    @IBOutlet private weak var mainImageView: UIImageView!

    @IBOutlet private weak var buttomInset: NSLayoutConstraint!

    @IBOutlet private weak var selectionButton: UIButton!
    @IBOutlet private weak var likeImageView: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var deliveryStatusImageView: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()

        mainImageView.image = nil
    }

    func configureCell(item: Item, hasInset: Bool) {
        if hasInset {
            buttomInset.constant = TableViewController.inset
        }
        else {
            buttomInset.constant = 0
        }
        mainImageView.image = item.image
        switch item.deliveryStatus {
        case .nonDelivered:
            deliveryStatusImageView.image = nil
        case .delivered:
            deliveryStatusImageView.image = #imageLiteral(resourceName: "tick")
        case .seen:
            deliveryStatusImageView.image = #imageLiteral(resourceName: "doubleTick")
        }

        dateLabel.text = TableViewController.dateFormatter.string(from: item.sentTime)
        likeImageView.image = item.isLiked ? #imageLiteral(resourceName: "star") : nil

        selectionButton.isHidden = true
    }
    
}
