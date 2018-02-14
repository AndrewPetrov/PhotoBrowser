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

protocol Likable {
    var isLiked: Bool { get set }
}

enum ItemType: Equatable {
    case image
    case video
    case link
    case document

    static func ==(lhs: ItemType, rhs: ItemType) -> Bool {
        switch (lhs, rhs) {
        case (.image, .image):
            return true
        case (.video, .video):
            return true
        case (.link, .link):
            return true
        case (.document, .document):
            return true

        default:
            return false
        }
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
        }
    }

}

enum DeliveryStatus {
    case nonDelivered
    case delivered
    case seen
}

class Item: Equatable {

    //Discuss what will be ID
    var id: String
    var image: UIImage
    var name: String
    var sentTime: Date
    var type: ItemType
    var deliveryStatus: DeliveryStatus
    //goes from Chat
    var messageIndexPath: IndexPath

    init(id: String = "",
         image: UIImage,
         name: String = "",
         sentTime: Date = Date(),
         type: ItemType,
         deliveryStatus: DeliveryStatus = .nonDelivered,
         messageIndexPath: IndexPath = IndexPath(row: 100500, section: 42)) {

        self.id = id
        self.image = image
        self.name = name
        self.sentTime = sentTime
        self.type = type
        self.deliveryStatus = deliveryStatus
        self.messageIndexPath = messageIndexPath
    }

    static func ==(lhs: Item, rhs: Item) -> Bool {

//for testing
        return lhs.image == rhs.image
//        return lhs.id == rhs.id
    }

}

class ImageItem: Item, Likable {
    var isLiked: Bool = false

    init(image: UIImage, name: String = "", sentTime: Date = Date(), deliveryStatus: DeliveryStatus = .nonDelivered) {
        super.init(image: image, name: name, sentTime: sentTime, type: .image, deliveryStatus: deliveryStatus)
    }
}

class VideoItem: Item, Likable {
    var isLiked: Bool = false
    let url: URL

    init(url: URL,
         thumbnail: UIImage?,
         name: String = "",
         sentTime: Date = Date(),
         deliveryStatus: DeliveryStatus = .nonDelivered) {
        self.url = url

        super.init(image: thumbnail ?? VideoItem.getThumbnailFrom(url: url) ?? UIImage(),
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

    init(url: URL,
         thumbnail: UIImage,
         name: String = "",
         sentTime: Date = Date(),
         deliveryStatus: DeliveryStatus = .nonDelivered) {

        self.url = url
        super.init(image: thumbnail,
                   name: name,
                   sentTime: sentTime,
                   type: .link,
                   deliveryStatus: deliveryStatus)
    }

}

class DocumentItem: Item {
    let url: URL

    init(url: URL,
         name: String = "",
         sentTime: Date = Date(),
         deliveryStatus: DeliveryStatus = .nonDelivered) {

        self.url = url
        super.init(image: DocumentItem.getThumbnailFrom(url: url),
                   name: name,
                   sentTime: sentTime,
                   type: .document,
                   deliveryStatus: deliveryStatus)
    }

    private static func getThumbnailFrom(url: URL) -> UIImage {
        print(url, url.deletingPathExtension().lastPathComponent)

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

