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
    private var goToMessageHandler: (() -> ())?

    @IBAction func goToMessageButtonDidTap(_ sender: UIButton) {
        goToMessageHandler?()
    }

    func configureCell(with item: LinkItem, isSelectionAllowed: Bool, isSelected: Bool, goToMessageHandler: @escaping () -> ()) {
        mainImageView.image = item.image
        self.goToMessageHandler = goToMessageHandler
        linkLabel.text = item.url.absoluteString
        descriptionLabel.text = item.name

        selectionImageView.isHidden = !isSelectionAllowed
        self.isSelected = isSelected
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        mainImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        selectionImageView.image = isSelected ? #imageLiteral(resourceName: "selected") : #imageLiteral(resourceName: "nonSelected")
    }

}
