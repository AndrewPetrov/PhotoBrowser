//
//  Item.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/10/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

enum ItemType {
    case photo (UIImage)
    //    case video ()
    //    case link (URL)
    //    case document
}

protocol Item: class {
    var image: UIImage {get}
    var name: String {get}
    var isDelivered: Bool {get}
    var isSeen: Bool {get}
    var isSelected: Bool {get}
    var isLiked: Bool {get}
    var sentTime: Date {get}
    var itemType: ItemType {get}
}

class ImageItem: Item {

    var isDelivered: Bool = true
    var isSeen: Bool = false
    var isSelected: Bool = false
    var isLiked: Bool = false
    var sentTime: Date = Date()
    var image: UIImage
    var name: String = ""
    var itemType: ItemType = .photo(UIImage())

    init(image: UIImage) {
        self.image = image
        itemType = ItemType.photo(image)
    }
}

