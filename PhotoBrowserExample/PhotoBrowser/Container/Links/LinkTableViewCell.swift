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
    private var goToMessageHandler: (() -> ())?

    @IBAction func goToMessageButtonDidTap(_ sender: UIButton) {
        goToMessageHandler?()
    }

    func configureCell(with item: LinkItem, goToMessageHandler: @escaping () -> ()) {
        mainImageView.image = item.image
        self.goToMessageHandler = goToMessageHandler
        linkLabel.text = item.url.absoluteString
        descriptionLabel.text = item.name
    }

}
