//
//  CarouselViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

protocol CarouselViewControllerDelegate {
    func didDoubleTap(_: CarouselViewController)
}

class CarouselViewController: UIViewController {
    
    private weak var presentationInputOutput: PresentationInputOutput!
    @IBOutlet private weak var layout: UICollectionViewFlowLayout!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var carouselView: UIView!
    @IBOutlet private weak var toolbar: UIToolbar!
    @IBOutlet private weak var deleteBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var actionBarButtonItem: UIBarButtonItem!
    
    @IBOutlet private var doubleTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet private var singleTapGestureRecognizer: UITapGestureRecognizer!
    
    private var delegate: CarouselViewControllerDelegate!
    
    private var currentCellIndexPath = IndexPath(row: 0, section: 0) {
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
    
    static func make(presentationInputOutput: PresentationInputOutput) -> CarouselViewController {
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
        collectionView.scrollToItem(at: presentationInputOutput.currentItemIndex(), at: .centeredHorizontally, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupCollectionView()
    }
    
    private func setupGestureRecognizers() {
        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
    }
    
    private func setupDelegate() {
        if let cell = collectionView.cellForItem(at: currentCellIndexPath) as? CarouselViewControllerDelegate {
            delegate = cell
        }
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
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setupCollectionView() {
        let width = view.frame.width - layout.minimumLineSpacing
        let height = view.frame.height + 20
        
        layout.itemSize = CGSize(width: width, height: height)
    }
    
    @IBAction private func trashButtonDidTap(_ sender: Any) {
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
    
    @IBAction private func actionButtonDidTap(_ sender: Any) {
        //TODO: add action here
    }
    
    @objc func likeButtonDidTap(_ sender: Any) {
        let isCellLiked = presentationInputOutput.isItemLiked(at: currentCellIndexPath)
        presentationInputOutput.setItemAs(isLiked: !isCellLiked, at: currentCellIndexPath)
        setupToolBar()
    }
    
    @IBAction func collectionViewDidTap(_ sender: UITapGestureRecognizer) {
        if let videoItem = presentationInputOutput.item(at: currentCellIndexPath) as? VideoItem {
            let player = AVPlayer(url: videoItem.url)
            let playerController = AVPlayerViewController()
            playerController.player = player
            present(playerController, animated: true) {
                player.play()
            }
        } else {
            toggleFullScreen()
        }
    }
    
    @IBAction func collectionViewDidDubbleTap(_ sender: UITapGestureRecognizer) {
        delegate.didDoubleTap(self)
    }
    
    private func calculateCurrentCellIndexPath(_ contentOffset: CGFloat) {
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
        let item = presentationInputOutput.item(at: indexPath)
        cell.configureCell(image: item?.image, isVideo: item?.type == .video)
        
        return cell
    }
    
}

extension CarouselViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        calculateCurrentCellIndexPath(scrollView.contentOffset.x)
    }
    
}
