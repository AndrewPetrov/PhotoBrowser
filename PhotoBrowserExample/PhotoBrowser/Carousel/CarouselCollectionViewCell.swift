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
    private var zoomOutHandler: (() -> ())?
    private var isVideo = false

    //TODO: calculate related on real resolution
    let minScale: CGFloat = 1
    let maxScale: CGFloat = 4

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        playImageView.isHidden = true
        scrollView.setZoomScale(minScale, animated: false)
    }

    func configureCell(image: UIImage?, isVideo: Bool, zoomOutHandler: (() -> ())?) {
        imageView.image = image
        playImageView.isHidden = !isVideo
        scrollView.maximumZoomScale = minScale
        scrollView.minimumZoomScale = minScale
        self.zoomOutHandler = zoomOutHandler
        scrollView.delegate = self
        self.isVideo = isVideo
    }
}

extension CarouselCollectionViewCell: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale <= minScale {
            zoomOutHandler?()
            scrollView.maximumZoomScale = minScale
        }
    }

}

extension CarouselCollectionViewCell: CarouselViewControllerDelegate {

    func didDoubleTap(_: CarouselViewController) {
        guard !isVideo else { return }
        scrollView.maximumZoomScale = scrollView.maximumZoomScale == maxScale ? minScale : maxScale
        let scale = scrollView.zoomScale == minScale ? maxScale : minScale

        scrollView.setZoomScale(scale, animated: true)
    }

}

