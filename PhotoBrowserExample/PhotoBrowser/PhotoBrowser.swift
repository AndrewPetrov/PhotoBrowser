//
//  PhotoBrowser.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoBrowserDelegate: class {
    func numberOfPhotos(in photoBrowser: PhotoBrowser) -> Int


//    - (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
//    - (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;
//
//    @optional
//
//    - (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
//    - (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
//    - (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
//    - (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
//    - (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;
//    - (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;
//    - (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;
//    - (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser;
}

protocol PhotoBrowserPresentationDataSouce {

}

protocol PhotoBrowserPresentationDelegate {

}


enum PhotoBrowserPresentation {
    case carousel
    case grid
    case table
}

enum SelectionState {
    case selection
    case notSelection
}

class PhotoBrowser: UIViewController {

    private weak var delegate: PhotoBrowserDelegate?
    var presentation: PhotoBrowserPresentation

    init(delegate: PhotoBrowserDelegate, presentation: PhotoBrowserPresentation = .carousel) {
        self.delegate = delegate
        self.presentation = presentation

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var carouselViewController: CarouselViewController {
        return CarouselViewController()
    }

    private var gridViewController: GridViewController {
        return GridViewController()
    }

    private var tableViewController: TableViewController {
        return TableViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()


    }





}
