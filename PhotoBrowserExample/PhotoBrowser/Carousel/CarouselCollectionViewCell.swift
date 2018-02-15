//
//  CarouselCollectionViewCell.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/10/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var playImageView: UIImageView!

    @IBOutlet private weak var scrollView: UIScrollView!

    //TODO: calculate related on real resolution
    let minScale: CGFloat = 1
    let maxScale: CGFloat = 4

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        playImageView.isHidden = true
    }

    func configureCell(image: UIImage?, isVideo: Bool) {
        imageView.image = image
        playImageView.isHidden = !isVideo
        scrollView.maximumZoomScale = isVideo ? 1 : minScale
        scrollView.maximumZoomScale = isVideo ? 1 : maxScale
    }
}

extension CarouselCollectionViewCell: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}

extension CarouselCollectionViewCell: CarouselViewControllerDelegate {
    func didDoubleTap(_: CarouselViewController) {
        let scale = scrollView.zoomScale == minScale ? maxScale : minScale
        scrollView.setZoomScale(scale, animated: true)
    }
}

