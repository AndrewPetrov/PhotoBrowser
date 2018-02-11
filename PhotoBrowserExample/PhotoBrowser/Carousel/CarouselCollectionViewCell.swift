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

    @IBOutlet weak var imageView: UIImageView!
    private var tapHandler: (()->())?

    @IBOutlet weak var scrollView: UIScrollView!

    let minScale: CGFloat = 1
    let maxScale: CGFloat = 4

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
    }

    func configureCell(image: UIImage?, tapHandler: @escaping ()->()) {
        self.tapHandler = tapHandler
        imageView.image = image

        scrollView.maximumZoomScale = 1
        scrollView.maximumZoomScale = 4
    }

//    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
//        tapHandler?()
//    }
//    @IBAction func handleLongTap(_ sender: Any) {
//        tapHandler?()
//    }
    //        let translation = recognizer.translation(in: self.view)
//        if let view = recognizer.view {
//            view.center = CGPoint(x:view.center.x + translation.x,
//                                  y:view.center.y + translation.y)
//        }
//        recognizer.setTranslation(CGPoint.zero, in: self.view)

    
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



//    @IBAction func didTap(_ sender: Any) {
//        tapHandler?()
//    }

//    private func addGestureRecognizers() {
//        // add pinch gesture
//        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchView))
//
//
//        // add pan gesture
//
//
//
//
//    }

//    @objc private func pinchView() {
//
//    }
//
//    objc private func panView() {
//
//    }

//}
/*
- (void) addGestureRecognizers
    {
        // add pinch gesture
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
        [self.view addGestureRecognizer:pinchGestureRecognizer];
        
        // add pan gesture
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
        [self.view addGestureRecognizer:panGestureRecognizer];
    }


- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = self.showImgView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
            }];
    }
    }

    // pan gesture handler
    - (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = self.showImgView;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // calculate accelerator
        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        CGFloat scaleRatio = self.showImgView.frame.size.width / self.cropFrame.size.width;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
            }];
    }
 }*/
