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
    @IBOutlet private weak var playImageView: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()

        mainImageView.image = nil
    }

    func configureCell(image: UIImage, isLiked: Bool, isVideo: Bool, hasInset: Bool, isSelectionAllowed: Bool, deliveryStatus: DeliveryStatus, sentTime: Date) {

        buttomInset.constant = hasInset ? TableViewController.inset : 0
        mainImageView.image = image
        var image = UIImage()
        switch deliveryStatus {
        case .delivered:
            image = #imageLiteral(resourceName: "tick")
        case .seen:
            image = #imageLiteral(resourceName: "doubleTick")
        case .nonDelivered:
            break
        }
        deliveryStatusImageView.image = image

        dateLabel.text = TableViewController.dateFormatter.string(from: sentTime)
        likeImageView.image = isLiked ? #imageLiteral(resourceName: "star") : nil

        selectionImageView.isHidden = !isSelectionAllowed
        playImageView.isHidden = !isVideo
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionImageView.image = selected ? #imageLiteral(resourceName: "selected") : #imageLiteral(resourceName: "nonSelected")
    }

}
