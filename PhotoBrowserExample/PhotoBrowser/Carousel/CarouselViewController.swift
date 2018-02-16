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

class CarouselViewController: UIViewController, Presentatable {


    private static var dateFormatter = DateFormatter()
    let presentation: Presentation = .carousel
    private let supportedTypes: [ItemType] = [.image, .video]
    private weak var presentationInputOutput: PresentationInputOutput!
    @IBOutlet private weak var imageViewOnTopOfCollectionView: UIImageView!
    @IBOutlet private weak var layout: UICollectionViewFlowLayout!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var carouselControlCollectionView: UICollectionView!
    @IBOutlet private weak var toolbarBottomConstraint: NSLayoutConstraint!

    lazy private var carouselControlAdapter: CarouselControlAdapter =
        CarouselControlAdapter(collectionView: carouselControlCollectionView, presentationInputOutput: presentationInputOutput, supportedTypes: supportedTypes)
    @IBOutlet private weak var carouselView: UIView!
    @IBOutlet private weak var toolbar: UIToolbar!
    @IBOutlet private weak var deleteBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var actionBarButtonItem: UIBarButtonItem!
    
    @IBOutlet private var doubleTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet private var singleTapGestureRecognizer: UITapGestureRecognizer!
    private var titleView: TitleView?

    //caching scaled images
    private let uiBarButtonImageSize = CGSize(width: 25, height: 25)
    private lazy var likedYesSizedImage = UIImageHelper.imageWithImage(image: #imageLiteral(resourceName: "likedYes"), scaledToSize: uiBarButtonImageSize)
    private lazy var likedNoSizedImage = UIImageHelper.imageWithImage(image: #imageLiteral(resourceName: "likeNo"), scaledToSize: uiBarButtonImageSize)
    private lazy var flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)


    private var needToScroll = true
    
    private var delegate: CarouselViewControllerDelegate!
    
    private var currentCellIndexPath : IndexPath {
        return presentationInputOutput.currentItemIndex()
    }

    override var prefersStatusBarHidden: Bool {
        return isFullScreen
    }
    
    private var isFullScreen: Bool = false

    // MARK: - Life cycle

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

        CarouselViewController.dateFormatter.dateFormat = "[MMM d, h:mm a]"
        updateToolBar()
        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        carouselControlCollectionView.reloadData()
        setupCarouselControlCollectionView()
        collectionView.reloadData()
        //crolls only once each time after screen appears
        needToScroll = true
        //force viewDidLayoutSubviews always after viewWillAppear
        carouselControlCollectionView.scrollToItem(at: presentationInputOutput.currentItemIndex(), at: .centeredHorizontally, animated: false)
        view.setNeedsLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupDelegate()
        setupGestureRecognizers()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setupCollectionView()
        carouselControlAdapter.collectionViewSize = carouselControlCollectionView.frame.size
        carouselControlCollectionView.reloadData()
        if needToScroll {
            collectionView.scrollToItem(at: presentationInputOutput.currentItemIndex(), at: .centeredHorizontally, animated: false)
            needToScroll = false
        }
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

        setupNavigationBar()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        imageViewOnTopOfCollectionView.image = presentationInputOutput.item(withType: supportedTypes, at: presentationInputOutput.currentItemIndex())?.image
        imageViewOnTopOfCollectionView.isHidden = false
        collectionView.isHidden = true

        coordinator.animate(alongsideTransition: { [weak self] (context) -> Void in
            guard let `self` = self else { return }
            self.carouselControlAdapter.collectionViewSize = size
            self.carouselControlCollectionView.reloadData()
            self.carouselControlCollectionView.scrollToItem(
                at: self.presentationInputOutput.currentItemIndex(),
                at: .centeredHorizontally,
                animated: true)
            self.imageViewOnTopOfCollectionView.frame.size = size
            }, completion: { [weak self] (context) -> Void in
                guard let `self` = self else { return }

                self.collectionView.reloadData()
                self.collectionView.layoutIfNeeded()
                self.collectionView.scrollToItem(
                    at: self.presentationInputOutput.currentItemIndex(),
                    at: .centeredHorizontally,
                    animated: false)
                self.collectionView.isHidden = false
                self.imageViewOnTopOfCollectionView.isHidden = true
        })
    }

    // MARK: - Setup controls

    private func setupGestureRecognizers() {
        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
    }
    
    private func setupDelegate() {
        if let cell = collectionView.cellForItem(at: currentCellIndexPath) as? CarouselViewControllerDelegate {
            delegate = cell
        }
    }

    private func setupNavigationBar() {
        let allMediaBarButtonItem = UIBarButtonItem(title: "AllMedia", style: .plain, target: self, action: #selector(switchToContainerPresentation))
        parent?.navigationItem.rightBarButtonItem = allMediaBarButtonItem

        titleView = TitleView.init(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        parent?.navigationItem.titleView = titleView
        updateTitleView()
    }

    private func setupCarouselControlCollectionView() {
        carouselControlCollectionView.delegate = carouselControlAdapter
        carouselControlCollectionView.dataSource = carouselControlAdapter
        let layout = CarouselControlCollectionLayout(presentationInputOutput: presentationInputOutput, supportedTypes: supportedTypes)

        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0

        carouselControlCollectionView.collectionViewLayout = layout
        carouselControlCollectionView.collectionViewLayout.invalidateLayout()
    }

    private func setupCollectionView() {
        let width = view.frame.width - layout.minimumLineSpacing
        let height = view.frame.height + 20

        layout.itemSize = CGSize(width: width, height: height)
    }

    // MARK: - Update controls

    private func updateToolBar() {
        let isLiked = presentationInputOutput.isItemLiked(withTypes: supportedTypes, at: currentCellIndexPath)
        let sizedImage = isLiked ? likedYesSizedImage : likedNoSizedImage
        let likeBarButtonItem = UIBarButtonItem(image: sizedImage, style: .plain, target: self, action: #selector(likeButtonDidTap(_:)))
        toolbar.items = [actionBarButtonItem, flexibleSpace, likeBarButtonItem, flexibleSpace, deleteBarButtonItem]
    }

    private func toggleFullScreen() {
        isFullScreen = !isFullScreen

        parent?.navigationController?.setNavigationBarHidden(isFullScreen, animated: true)
        setNeedsStatusBarAppearanceUpdate()

        toolbarBottomConstraint.constant = 0
        if isFullScreen {
            if let navigationController = parent?.navigationController {
                toolbarBottomConstraint.constant = -(toolbar.frame.height + navigationController.navigationBar.intrinsicContentSize.height +
                    carouselControlCollectionView.frame.height)
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func switchToContainerPresentation() {
        presentationInputOutput.switchTo(presentation: .container)
    }

    private func updateTitleView() {
        var info = ""
        if let date = presentationInputOutput.item(
            withType: supportedTypes,
            at: presentationInputOutput.currentItemIndex())?.sentTime {
            info = CarouselViewController.dateFormatter.string(from: date)
        }
        
        titleView?.setup(
            sender: presentationInputOutput.senderName(),
            info:  info
        )
    }

    // MARK: - User actions

    @IBAction private func trashButtonDidTap(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteForMeAction = UIAlertAction(title: "Delete For Me", style: .destructive) { [weak self] _ in
            guard let `self` = self else { return }
            self.presentationInputOutput.deleteItems(
                withTypes: self.supportedTypes,
                indexPathes: [self.currentCellIndexPath]
            )
            self.collectionView.reloadData()
            self.carouselControlCollectionView.reloadData()
        }
        alertController.addAction(deleteForMeAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction private func actionButtonDidTap(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.presentationInputOutput.saveItem(
                withTypes: self.supportedTypes,
                indexPathes: [self.presentationInputOutput.currentItemIndex()]
            )
        }
        alertController.addAction(saveAction)

        let forwardAction = UIAlertAction(title: "Forward", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.presentationInputOutput.forwardItem(
                withTypes: self.supportedTypes,
                indexPathes: [self.presentationInputOutput.currentItemIndex()]
            )
        }
        alertController.addAction(forwardAction)

        let shareAction = UIAlertAction(title: "Share", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.presentationInputOutput.shareItem(
                withTypes: self.supportedTypes,
                indexPathes: [self.presentationInputOutput.currentItemIndex()]
            )
        }
        alertController.addAction(shareAction)

        let setAsProfilePictureAction = UIAlertAction(title: "Set As Profile Picture", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.presentationInputOutput.setAsMyProfilePhoto(
                withTypes: self.supportedTypes,
                indexPath: self.presentationInputOutput.currentItemIndex()
            )
        }
        alertController.addAction(setAsProfilePictureAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @objc func likeButtonDidTap(_ sender: Any) {
        let isCellLiked = presentationInputOutput.isItemLiked(withTypes: supportedTypes, at: currentCellIndexPath)
        presentationInputOutput.setItemAs(withTypes: supportedTypes, isLiked: !isCellLiked, at: [currentCellIndexPath])
        updateToolBar()
    }
    
    @IBAction func collectionViewDidTap(_ sender: UITapGestureRecognizer) {
        if let videoItem = presentationInputOutput.item(withType: supportedTypes, at: currentCellIndexPath) as? VideoItem {
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
    
    private func updateCurrentCellIndexPath(_ contentOffset: CGFloat) {
        let cellWidth = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width
        let row = Int((contentOffset / cellWidth).rounded())
        presentationInputOutput.setItemAsCurrent(at: IndexPath(row: row, section: 0))
    }
    
}

extension CarouselViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presentationInputOutput.numberOfItems(withType: supportedTypes)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCollectionViewCell",
                                                      for: indexPath) as! CarouselCollectionViewCell
        let item = presentationInputOutput.item(withType: supportedTypes, at: indexPath)
        cell.configureCell(image: item?.image, isVideo: item?.type == .video)
        
        return cell
    }
    
}

extension CarouselViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if collectionView.isDragging {
            updateCurrentCellIndexPath(scrollView.contentOffset.x)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {

    }
    
}

extension CarouselViewController: PhotoBrowserInternalDelegate {

    func currentItemIndexDidChange() {
        updateToolBar()
        setupDelegate()
        updateTitleView()
        if !collectionView.isTracking {
            collectionView.scrollToItem(
                at: presentationInputOutput.currentItemIndex(),
                at: .centeredHorizontally,
                animated: false)
        }
        if !(carouselControlCollectionView.isTracking || carouselControlCollectionView.isDecelerating) {
            carouselControlCollectionView.scrollToItem(
                at: presentationInputOutput.currentItemIndex(),
                at: .centeredHorizontally,
                animated: true)
        }
    }

}
