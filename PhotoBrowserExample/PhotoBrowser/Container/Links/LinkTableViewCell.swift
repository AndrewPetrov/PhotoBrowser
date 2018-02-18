//
//  LinkCollectionViewCell.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/11/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class LinkTableViewCell: UITableViewCell {

    @IBOutlet private weak var mainImageView: UIImageView!
    @IBOutlet private weak var linkLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var selectionImageView: UIImageView!
    @IBOutlet private weak var selectionViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var likedImageView: UIImageView!
    
    private var goToMessageHandler: (() -> ())?

    @IBAction func goToMessageButtonDidTap(_ sender: UIButton) {
        goToMessageHandler?()
    }

    func configureCell(with item: LinkItem, isSelectionAllowed: Bool, isLiked: Bool, goToMessageHandler: @escaping () -> ()) {
        mainImageView.image = item.image
        self.goToMessageHandler = goToMessageHandler
        linkLabel.text = item.url.absoluteString
        descriptionLabel.text = item.name
        likedImageView.isHidden = !isLiked

        selectionImageView.alpha = !isSelectionAllowed ? 1 : 0
        selectionViewWidth.constant = isSelectionAllowed ? 50 : 0
        UIView.animate(withDuration: 0.33) {
            self.selectionImageView.alpha = isSelectionAllowed ? 1 : 0
            self.layoutIfNeeded()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        mainImageView.image = nil
        selectionImageView.image = nil
        likedImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        selectionImageView.image = isSelected ? #imageLiteral(resourceName: "selected") : #imageLiteral(resourceName: "nonSelected")

    }

}
