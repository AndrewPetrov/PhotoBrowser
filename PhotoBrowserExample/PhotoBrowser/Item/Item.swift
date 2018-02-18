//
//  Item.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/10/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

struct ItemTypes: OptionSet, Equatable, Hashable {

    var hashValue: Int {
        return self.rawValue
    }

    let rawValue: Int

     static let image = ItemTypes(rawValue: 1)
     static let video = ItemTypes(rawValue: 2)
     static let link = ItemTypes(rawValue: 4)
     static let document = ItemTypes(rawValue: 8)

    static func ==(lhs: ItemTypes, rhs: ItemTypes) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    func description(isPlural: Bool) -> String {
        switch self {
        case .image:
            return isPlural ? "Images" : "Image"
        case .video:
            return isPlural ? "Videos" : "Video"
        case .link:
            return isPlural ? "Links" : "Link"
        case .document:
            return isPlural ? "Documents" : "Document"
        default:
             return isPlural ? "Items" : "Item"
        }
    }

}

enum DeliveryStatus {
    case nonDelivered
    case delivered
    case seen
}
typealias Id = Int

class Item: Equatable {

    //Discuss what will be ID
    var id: Id
    var image: UIImage
    var name: String
    var sentTime: Date
    var type: ItemTypes
    var deliveryStatus: DeliveryStatus
    var isLiked: Bool
    //goes from Chat
    var messageIndexPath: IndexPath

    init(id: Id,
         image: UIImage,
         name: String = "",
         sentTime: Date = Date(),
         type: ItemTypes,
         deliveryStatus: DeliveryStatus = .nonDelivered,
         isLiked: Bool = false,
         messageIndexPath: IndexPath = IndexPath(row: 100500, section: 42)) {

        self.id = id
        self.image = image
        self.name = name
        self.sentTime = sentTime
        self.type = type
        self.deliveryStatus = deliveryStatus
        self.isLiked = isLiked
        self.messageIndexPath = messageIndexPath
    }

    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id &&
            lhs.image == rhs.image &&
            lhs.name == rhs.name &&
            lhs.sentTime == rhs.sentTime &&
            lhs.type == rhs.type &&
            lhs.deliveryStatus == rhs.deliveryStatus &&
            lhs.isLiked == rhs.isLiked &&
            lhs.messageIndexPath == rhs.messageIndexPath
    }

}

class ImageItem: Item {

    init(id: Id, image: UIImage, name: String = "", sentTime: Date = Date(), deliveryStatus: DeliveryStatus = .nonDelivered) {
        super.init(id: id, image: image, name: name, sentTime: sentTime, type: .image, deliveryStatus: deliveryStatus)
    }
}

class VideoItem: Item {

    let url: URL

    init(id: Id,
         url: URL,
         thumbnail: UIImage?,
         name: String = "",
         sentTime: Date = Date(),
         deliveryStatus: DeliveryStatus = .nonDelivered) {
        self.url = url

        super.init(id: id, image: thumbnail ?? VideoItem.getThumbnailFrom(url: url) ?? UIImage(),
                   name: name,
                   sentTime: sentTime,
                   type: .video,
                   deliveryStatus: deliveryStatus)
    }

    private static func getThumbnailFrom(url: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: url , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)

            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }

}

class LinkItem: Item {

    let url: URL

    init(id: Id,
         url: URL,
         thumbnail: UIImage,
         name: String = "",
         sentTime: Date = Date(),
         deliveryStatus: DeliveryStatus = .nonDelivered) {

        self.url = url
        super.init(id: id,
                   image: thumbnail,
                   name: name,
                   sentTime: sentTime,
                   type: .link,
                   deliveryStatus: deliveryStatus)
    }

}

class DocumentItem: Item {
    let url: URL

    init(id: Id,
         url: URL,
         name: String = "",
         sentTime: Date = Date(),
         deliveryStatus: DeliveryStatus = .nonDelivered) {

        self.url = url
        super.init(id: id,
                   image: DocumentItem.getThumbnailFrom(url: url),
                   name: name,
                   sentTime: sentTime,
                   type: .document,
                   deliveryStatus: deliveryStatus)
    }

    private static func getThumbnailFrom(url: URL) -> UIImage {
        switch url.deletingPathExtension().lastPathComponent {
        case "jpg":
            return #imageLiteral(resourceName: "docPicture")
        case "txt":
            return #imageLiteral(resourceName: "docText")
        default:
            return #imageLiteral(resourceName: "docUnknown")
        }
    }

}

