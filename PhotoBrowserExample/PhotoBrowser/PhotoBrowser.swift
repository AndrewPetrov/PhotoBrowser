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

    func setItemAs(isLiked: Bool, at indexPath: IndexPath)
    func deleteItems(indexPathes: Set<IndexPath>)

//    func setItem(at indexPath: IndexPath, isSelected: Bool)
//    func setItemAsCurrent(at indexPath: IndexPath)



//    - (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
//    - (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtindexPath:(NSUInteger)index;
//
//    @optional
//
//    - (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtindexPath:(NSUInteger)index;
//    - (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtindexPath:(NSUInteger)index;
//    - (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtindexPath:(NSUInteger)index;
//    - (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtindexPath:(NSUInteger)index;
//    - (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtindexPath:(NSUInteger)index;
//    - (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtindexPath:(NSUInteger)index;
//    - (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtindexPath:(NSUInteger)index selectedChanged:(BOOL)selected;
//    - (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser;
}


protocol PhotoBrowserDataSouce: class {
    func numberOfItems() -> Int
    func currentItemIndex() -> IndexPath
    func item(at indexPath: IndexPath) -> Item?
}



//--------------------


typealias PresentationInputOutput = PresentationInput & PresentationOutput

protocol PresentationInput: AnyObject {
    func currentItemIndex() -> IndexPath
    func isItemLiked(at indexPath: IndexPath) -> Bool
    func numberOfItems() -> Int
    func item(at indexPath: IndexPath) -> Item?
}

protocol PresentationOutput: AnyObject {
    func setItemAsCurrent(at indexPath: IndexPath)
    func setItemAs(isLiked: Bool, at indexPath: IndexPath)
    func deleteItems(indexPathes: Set<IndexPath>)
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
    private weak var photoBrowserInput: PresentationOutput!

    init(dataSource: PhotoBrowserDataSouce?, delegate: PhotoBrowserDelegate?, presentation: Presentation = .carousel) {
        self.dataSource = dataSource
        self.delegate = delegate
        self.presentation = presentation

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var carouselViewController = CarouselViewController.makeCarouselViewController(presentationInputOutput: self)
    private lazy var gridViewController = GridViewController.makeGridViewController (presentationInputOutput: self)
    private lazy var tableViewController = TableViewController.makeTableViewController(presentationInputOutput: self)

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
    func isItemLiked(at indexPath: IndexPath) -> Bool {
         return dataSource?.item(at: indexPath)?.isLiked ?? false
    }


    func currentItemIndex() -> IndexPath {
        return IndexPath()
    }

    func numberOfItems() -> Int {
        return dataSource?.numberOfItems() ?? 0
    }

    func item(at indexPath: IndexPath) -> Item? {
        return dataSource?.item(at: indexPath)
    }
}

extension PhotoBrowser: PresentationOutput {
    func setItemAs(isLiked: Bool, at indexPath: IndexPath) {
         print("like = ", isLiked,  indexPath)
        delegate?.setItemAs(isLiked: isLiked, at: indexPath)
    }

    func deleteItems(indexPathes: Set<IndexPath>) {
        print("delete", indexPathes)

    }

    func setItemAsCurrent(at indexPath: IndexPath) {

    }

}


