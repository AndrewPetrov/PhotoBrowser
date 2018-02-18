//
//  UIImageHelper.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/15/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class UIImageHelper {
    //temporal helper due there are real icons
    static func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        let originalSize = image.size
        let horizontalScale = newSize.width / originalSize.width
        let verticalScale = newSize.height / originalSize.height
        let maxScale = max(horizontalScale, verticalScale)

        let targetSize = CGSize(width: originalSize.width * maxScale, height: originalSize.height * maxScale)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: targetSize))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }
}


class ImageCache {

    private static  let _shared = ImageCache()

    private var sizedImages = [Id: UIImage]()

    static var shared: ImageCache {
        return _shared
    }

}

extension ImageCache {

    func setSized(_ image: UIImage, forKey key: Id) {
        sizedImages[key] = image
    }

    func sizedImage(forKey key: Id) -> UIImage? {
        return sizedImages[key]
    }
}
