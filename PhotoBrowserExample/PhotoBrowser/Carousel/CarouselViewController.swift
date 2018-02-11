//
//  CarouselViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

protocol CarouselViewControllerDelegate {
    func didDoubleTap(_: CarouselViewController)
}

class CarouselViewController: UIViewController {

    private weak var presentationInputOutput: PresentationInputOutput!
    @IBOutlet private weak var layout: UICollectionViewFlowLayout!

    @IBOutlet private weak var collectionView: UICollectionView!

    @IBOutlet weak var carouselView: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var deleteBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var actionBarButtonItem: UIBarButtonItem!

    @IBOutlet var doubleTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var singleTapGestureRecognizer: UITapGestureRecognizer!

    private var delegate: CarouselViewControllerDelegate!

    var currentCellIndexPath = IndexPath(row: 0, section: 0) {
        didSet {
            setupToolBar()
            setupDelegate()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return isFullScreen
    }

    private var isFullScreen: Bool = false

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func makeCarouselViewController(presentationInputOutput: PresentationInputOutput) -> CarouselViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CarouselViewController") as! CarouselViewController
        newViewController.presentationInputOutput = presentationInputOutput

        return newViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupToolBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupDelegate()
        setupGestureRecognizers() 
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setupCollectionView()
    }

    private func setupGestureRecognizers() {
        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
    }

    private func setupDelegate() {
        delegate = collectionView.cellForItem(at: currentCellIndexPath) as! CarouselViewControllerDelegate
    }

    private func setupToolBar() {
        let isLiked = presentationInputOutput.isItemLiked(at: currentCellIndexPath)
        let size = CGSize(width: 25, height: 25)
        let image = isLiked ? #imageLiteral(resourceName: "likedYes") : #imageLiteral(resourceName: "likeNo")
        let sizedImage = imageWithImage(image: image, scaledToSize: size)
        let flaxibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let likeBarButtonItem = UIBarButtonItem(image: sizedImage, style: .plain, target: self, action: #selector(likeButtonDidTap(_:)))

        toolbar.items = [actionBarButtonItem, flaxibleSpace, likeBarButtonItem, flaxibleSpace, deleteBarButtonItem]
    }

    private func imageWithImage(image: UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    private func toggleFullScreen() {
        isFullScreen = !isFullScreen
       navigationController?.setNavigationBarHidden(isFullScreen, animated: true)
        carouselView.alpha = isFullScreen ? 0 : 1
        toolbar.alpha = isFullScreen ? 0 : 1


//        toolbarHeight.constant = isFullScreen ? 0 : 44

//        if isFullScreen {
//            if let navigationController = navigationController {
////                toolbarBottomContraint.constant = -(toolbar.frame.height + navigationController.navigationBar.intrinsicContentSize.height)
//            }
//        } else {
//            toolbarBottomContraint.constant = 0
//        }
        setNeedsStatusBarAppearanceUpdate()
    }

    private func setupCollectionView() {
        let width = view.frame.width - layout.minimumLineSpacing
        let height = view.frame.height + 20

        layout.itemSize = CGSize(width: width, height: height)
    }

    @IBAction func trashButtonDidTap(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let deleteForMeAction = UIAlertAction(title: "Delete For Me", style: .destructive) { [weak self] _ in
            guard let `self` = self else { return }
            self.presentationInputOutput.deleteItems(indexPathes: Set([self.currentCellIndexPath]))

        }
        alertController.addAction(deleteForMeAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            alertController.dismiss(animated: true, completion: nil)
        }

        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)

    }

    @IBAction func actionButtonDidTap(_ sender: Any) {
    }

    @IBAction func likeButtonDidTap(_ sender: Any) {
        let isCellLiked = presentationInputOutput.isItemLiked(at: currentCellIndexPath)
        presentationInputOutput.setItemAs(isLiked: !isCellLiked, at: currentCellIndexPath)
        setupToolBar()
    }

    @IBAction func collectionViewDidTap(_ sender: UITapGestureRecognizer) {
        toggleFullScreen()
    }

    @IBAction func collectionViewDidDubbleTap(_ sender: UITapGestureRecognizer) {
        delegate.didDoubleTap(self)
    }

    fileprivate func calculateCurrentCellIndexPath(_ contentOffset: CGFloat) {
        let cellWidth = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width
        let row = Int((contentOffset / cellWidth).rounded())
        currentCellIndexPath = IndexPath(row: row, section: 0)
    }


}

extension CarouselViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presentationInputOutput.numberOfItems()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCollectionViewCell",
                                                      for: indexPath) as! CarouselCollectionViewCell
//        cell.delegate = self
//        cell.isForPreviewOnly = isForPreviewOnly
//        if let network: SocialNetworkEntity = dataSourceArray?[indexPath.row]{
//            cell.configure(network: network, indexPath:indexPath.row)
//        }
        cell.configureCell(image: presentationInputOutput.item(at: indexPath)?.image) {
//            isFullScreen = !isFullScreen
        }

        return cell
    }

}

extension CarouselViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        toggleFullScreen()
    }



    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        calculateCurrentCellIndexPath(scrollView.contentOffset.x)
    }
    
}
