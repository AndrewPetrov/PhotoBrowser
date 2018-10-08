//
//  DocsTableViewCell.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/15/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class DocsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var mainImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var sizeLabel: UILabel!
    @IBOutlet private weak var extensionLabel: UILabel!
    @IBOutlet private weak var selectionImageView: UIImageView!
    @IBOutlet private weak var selectionViewWidth: NSLayoutConstraint!
    
    func configureCell(with item: DocumentItem, size: String, extensionText: String, isSelectionAllowed: Bool) {
        mainImageView.image = item.image
        nameLabel.text = item.name
        sizeLabel.text = size
        extensionLabel.text = extensionText
        
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
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        selectionImageView.image = isSelected ? #imageLiteral(resourceName: "iOSPhotoBrowser_selected") : nil
    }
    
}
