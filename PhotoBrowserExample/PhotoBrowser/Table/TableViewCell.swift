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
    @IBOutlet private weak var likeImageView: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var deliveryStatusImageView: UIImageView!
    @IBOutlet private weak var selectionImageView: UIImageView!

    private weak var item: Item!

    override func prepareForReuse() {
        super.prepareForReuse()

        mainImageView.image = nil
        likeImageView.image = nil
        isSelected = false
    }

    func configureCell(item: Item & Likable, hasInset: Bool, isSelectionAllowed: Bool, isSelected: Bool) {
        self.item = item

        buttomInset.constant = hasInset ? TableViewController.inset : 0
        mainImageView.image = item.image
        var image = UIImage()
        switch item.deliveryStatus {
        case .delivered:
            image = #imageLiteral(resourceName: "tick")
        case .seen:
            image = #imageLiteral(resourceName: "doubleTick")
        case .nonDelivered:
            break
        }
        deliveryStatusImageView.image = image

        dateLabel.text = TableViewController.dateFormatter.string(from: item.sentTime)
        likeImageView.image = item.isLiked ? #imageLiteral(resourceName: "star") : nil

        selectionImageView.isHidden = !isSelectionAllowed
        self.isSelected = isSelected
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        selectionImageView.image = selected ? #imageLiteral(resourceName: "selected") : #imageLiteral(resourceName: "nonSelected")
    }

}
