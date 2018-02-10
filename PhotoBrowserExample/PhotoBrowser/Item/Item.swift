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

enum DeliveryStatus {
    case nonDelivered
    case delivered
    case seen
}

protocol Item: class {
    var image: UIImage {get}
    var name: String {get}
//    var isSelected: Bool {get}
    var isLiked: Bool {get}
    var sentTime: Date {get}
    var itemType: ItemType {get}
    var deliveryStatus: DeliveryStatus {get}
}

class ImageItem: Item {
//    var isSelected: Bool = false
    var isLiked: Bool = false
    var sentTime: Date = Date()
    var image: UIImage
    var name: String = ""
    var itemType: ItemType = .photo(UIImage())
    var deliveryStatus: DeliveryStatus = .seen

    init(image: UIImage) {
        self.image = image
        itemType = ItemType.photo(image)
    }
}

