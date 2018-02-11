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
    case photo
    case video
    case link
    case document

    static func ==(lhs: ItemType, rhs: ItemType) -> Bool {
        switch (lhs, rhs) {
        case (.photo, .photo):
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

}

enum DeliveryStatus {
    case nonDelivered
    case delivered
    case seen
}

class Item {
    var image: UIImage
    var name = ""
    var sentTime: Date = Date()
    var type: ItemType
    var deliveryStatus: DeliveryStatus = .nonDelivered

    init(image: UIImage, name: String = "", sentTime: Date = Date(), type: ItemType, deliveryStatus: DeliveryStatus = .nonDelivered) {
        self.image = image
        self.name = name
        self.sentTime = sentTime
        self.type = type
        self.deliveryStatus = deliveryStatus
    }

}

class ImageItem: Item, Likable {
    var isLiked: Bool = false

    init(image: UIImage, name: String = "", sentTime: Date = Date(), deliveryStatus: DeliveryStatus = .nonDelivered) {
        super.init(image: image, name: name, sentTime: sentTime, type: .photo, deliveryStatus: deliveryStatus)

    }
}

class VideoItem: Item, Likable {
    var isLiked: Bool = false
    let videoAsset: AVURLAsset

    init(videoAsset: AVURLAsset,
         thumbnail: UIImage?,
         name: String = "",
         sentTime: Date = Date(),
         deliveryStatus: DeliveryStatus = .nonDelivered) {
        self.videoAsset = videoAsset

        super.init(image: thumbnail ?? VideoItem.getThumbnailFrom(videoAsset: videoAsset) ?? UIImage(),
                   name: name,
                   sentTime: sentTime,
                   type: .video,
                   deliveryStatus: deliveryStatus)
    }

    private static func getThumbnailFrom(videoAsset: AVURLAsset) -> UIImage? {
        do {
            let imgGenerator = AVAssetImageGenerator(asset: videoAsset)
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

