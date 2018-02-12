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

    override var isSelected: Bool {
        didSet{
            updateSelectionImage(isSelected: isSelected)
        }
    }

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
        updateSelectionImage(isSelected: isSelected)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        mainImageView.image = nil
    }
    //FIXME: fix the bug with selection
    private func updateSelectionImage(isSelected: Bool) {
        print(self, isSelected)
        selectionImageView.image = isSelected ? #imageLiteral(resourceName: "selected") : #imageLiteral(resourceName: "nonSelected")
    }

}
