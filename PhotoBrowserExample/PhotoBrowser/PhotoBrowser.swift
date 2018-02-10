//
//  PhotoBrowser.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit



//@interface MWPhoto : NSObject <MWPhoto>
//
//@property (nonatomic, strong) NSString *caption;
//@property (nonatomic, strong) NSURL *videoURL;
//@property (nonatomic) BOOL emptyImage;
//@property (nonatomic) BOOL isVideo;
//
//+ (MWPhoto *)photoWithImage:(UIImage *)image;
//+ (MWPhoto *)photoWithURL:(NSURL *)url;
//+ (MWPhoto *)photoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
//+ (MWPhoto *)videoWithURL:(NSURL *)url; // Initialise video with no poster image
//
//- (id)init;
//- (id)initWithImage:(UIImage *)image;
//- (id)initWithURL:(NSURL *)url;
//- (id)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
//- (id)initWithVideoURL:(NSURL *)url;






protocol PhotoBrowserDelegate: class {

//    func setItem(at index: IndexPath, isSelected: Bool)
//    func setItemAsCurrent(at index: IndexPath)



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


protocol PhotoBrowserDataSouce: class {
    func numberOfItems() -> Int
    func currentItemIndex() -> IndexPath
    func item(at index: IndexPath) -> Item?
}

//protocol PhotoBrowserPresentationDataSouce: class {
//    func numberOfItems() -> Int
//    func currentItemIndex() -> IndexPath
//    func item(at index: IndexPath) -> Item?
//}

protocol PhotoBrowserPresentationDelegate: class {
    func viewController(viewController: UIViewController, indexPath: IndexPath, selecled: Bool)

}

protocol PresentationInput: AnyObject {
    func currentItemIndex() -> IndexPath
    func numberOfItems() -> Int
    func item(at index: IndexPath) -> Item?
}

protocol PresentationOutput: AnyObject {
    func setItem(at index: IndexPath, isSelected: Bool)
    func setItemAsCurrent(at index: IndexPath)
}


enum Presentation {
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
    private weak var dataSource: PhotoBrowserDataSouce?
    private var presentation: Presentation

    init(dataSource: PhotoBrowserDataSouce?, delegate: PhotoBrowserDelegate?, presentation: Presentation = .table) {
        self.dataSource = dataSource
        self.delegate = delegate
        self.presentation = presentation

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var carouselViewController = CarouselViewController.makeCarouselViewController(presentationInput: self)
    private lazy var gridViewController = GridViewController.makeGridViewController (presentationInput: self)
    private lazy var tableViewController = TableViewController.makeTableViewController(presentationInput: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        switchToCurrentPresentation()
    }

    func switchToCurrentPresentation() {

        switch presentation {
        case .carousel:
            navigationController?.pushViewController(carouselViewController, animated: true)
        case .grid:
            navigationController?.pushViewController(gridViewController, animated: true)
        case .table:
            navigationController?.pushViewController(tableViewController, animated: true)
        }

    }





}

extension PhotoBrowser: PresentationInput {
    func currentItemIndex() -> IndexPath {
        return IndexPath()
    }

    func numberOfItems() -> Int {
        return dataSource?.numberOfItems() ?? 0
    }

    func item(at index: IndexPath) -> Item? {
        return dataSource?.item(at:index)
    }
}

extension PhotoBrowser: PresentationOutput {
    func setItem(at index: IndexPath, isSelected: Bool) {
//        delegate?.setItem(at: index, isSelected: isSelected)
    }
    func setItemAsCurrent(at index: IndexPath) {

    }
}

