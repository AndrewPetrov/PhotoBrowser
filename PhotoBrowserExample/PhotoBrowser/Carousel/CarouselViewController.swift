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

protocol CarouselViewControllerDelegate: class {
    func didDoubleTap(_: CarouselViewController)
}

class CarouselViewController: UIViewController, Presentatable {

    private static var dateFormatter = DateFormatter()
    let presentation: Presentation = .carousel
    private let supportedTypes: ItemTypes = [.image, .video]
    private weak var modelInputOutput: ModelInputOutput!
    private weak var presentationInputOutput: PresentationInputOutput!
    @IBOutlet private weak var imageViewOnTopOfCollectionView: UIImageView!
    @IBOutlet private weak var layout: UICollectionViewFlowLayout!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var carouselControlCollectionView: UICollectionView!
    @IBOutlet private weak var toolbarBottomConstraint: NSLayoutConstraint!

    lazy private var carouselControlAdapter: CarouselControlAdapter =
        CarouselControlAdapter(collectionView: carouselControlCollectionView, modelInputOutput: modelInputOutput, presentationInputOutput: presentationInputOutput, supportedTypes: supportedTypes)
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

    private var isFirstAppearing = true
    
    private weak var delegate: CarouselViewControllerDelegate?
    
    private var currentCellIndexPath : IndexPath {
        return presentationInputOutput.currentItemIndex(withTypes: supportedTypes)
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

    deinit {
        print("-CarouselViewController")
    }
    
    static func make(modelInputOutput: ModelInputOutput, presentationInputOutput: PresentationInputOutput) -> CarouselViewController {
        let newViewController = UIStoryboard(name: "PhotoBrowser", bundle: nil).instantiateViewController(withIdentifier: "CarouselViewController") as! CarouselViewController
        newViewController.modelInputOutput = modelInputOutput
        newViewController.presentationInputOutput = presentationInputOutput

        return newViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CarouselViewController.dateFormatter.dateFormat = "[MMM d, h:mm a]"
        setupNavigationBar()
        cacheFirstImagesForCarouselViewAdapter()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        carouselControlCollectionView.reloadData()
        setupCarouselControlCollectionView()
        collectionView.reloadData()

        if presentationInputOutput.currentItemIndex(withTypes: supportedTypes).row <
            modelInputOutput.numberOfItems(withTypes: supportedTypes) {
            carouselControlCollectionView.scrollToItem(at: presentationInputOutput.currentItemIndex(withTypes: supportedTypes), at: .centeredHorizontally, animated: false)
        }

        updateToolBar()
        //force viewDidLayoutSubviews always after viewWillAppear
        view.setNeedsLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupDelegate()
        setupGestureRecognizers()

        if let videoItem = modelInputOutput.item(withTypes: supportedTypes, at: currentCellIndexPath) as? VideoItem, isFirstAppearing {
            playVideo(videoItem)
        }
        isFirstAppearing = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setupCollectionView()
        carouselControlAdapter.collectionViewSize = carouselControlCollectionView.frame.size
        carouselControlCollectionView.reloadData()
        if isFirstAppearing, presentationInputOutput.currentItemIndex(withTypes: supportedTypes).row < modelInputOutput.numberOfItems(withTypes: supportedTypes) {
            collectionView.scrollToItem(at: presentationInputOutput.currentItemIndex(withTypes: supportedTypes), at: .centeredHorizontally, animated: false)
        }
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

        setupNavigationBar()
    }

    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)

        isFirstAppearing = true
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        imageViewOnTopOfCollectionView.image = modelInputOutput.item(withTypes: supportedTypes, at: presentationInputOutput.currentItemIndex(withTypes: supportedTypes))?.image
        imageViewOnTopOfCollectionView.isHidden = false
        collectionView.isHidden = true

        coordinator.animate(alongsideTransition: { [weak self] (context) -> Void in
            guard let `self` = self else { return }
            self.carouselControlAdapter.collectionViewSize = size
            self.carouselControlCollectionView.reloadData()
            self.carouselControlCollectionView.scrollToItem(
                at: self.presentationInputOutput.currentItemIndex(withTypes: self.supportedTypes),
                at: .centeredHorizontally,
                animated: true)
            self.imageViewOnTopOfCollectionView.frame.size = size
            }, completion: { [weak self] (context) -> Void in
                guard let `self` = self else { return }

                self.collectionView.reloadData()
                self.collectionView.layoutIfNeeded()
                self.collectionView.scrollToItem(
                    at: self.presentationInputOutput.currentItemIndex(withTypes: self.supportedTypes),
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
        let layout = CarouselControlCollectionLayout(modelInputOutput: modelInputOutput, supportedTypes: supportedTypes)

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
        let isLiked = modelInputOutput.isItemLiked(withTypes: supportedTypes, at: currentCellIndexPath)
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
        if let date = modelInputOutput.item(
            withTypes: supportedTypes,
            at: presentationInputOutput.currentItemIndex(withTypes: supportedTypes))?.sentTime {
            info = CarouselViewController.dateFormatter.string(from: date)
        }
        
        titleView?.setup(
            sender: modelInputOutput.senderName(),
            info:  info
        )
    }

    // MARK: - User actions

    @IBAction private func trashButtonDidTap(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteForMeAction = UIAlertAction(title: "Delete For Me", style: .destructive) { [weak self] _ in
            guard let `self` = self else { return }
            self.modelInputOutput.deleteItems(
                withTypes: self.supportedTypes,
                indexPaths: [self.currentCellIndexPath]
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
            self.modelInputOutput.saveItem(
                withTypes: self.supportedTypes,
                indexPaths: [self.presentationInputOutput.currentItemIndex(withTypes: self.supportedTypes)]
            )
        }
        alertController.addAction(saveAction)

        let forwardAction = UIAlertAction(title: "Forward", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.modelInputOutput.forwardItem(
                withTypes: self.supportedTypes,
                indexPaths: [self.presentationInputOutput.currentItemIndex(withTypes: self.supportedTypes)]
            )
        }
        alertController.addAction(forwardAction)

        let shareAction = UIAlertAction(title: "Share", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.modelInputOutput.shareItem(
                withTypes: self.supportedTypes,
                indexPaths: [self.presentationInputOutput.currentItemIndex(withTypes: self.supportedTypes)]
            )
        }
        alertController.addAction(shareAction)

        let setAsProfilePictureAction = UIAlertAction(title: "Set As Profile Picture", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.modelInputOutput.setAsMyProfilePhoto(
                withTypes: self.supportedTypes,
                indexPath: self.presentationInputOutput.currentItemIndex(withTypes: self.supportedTypes)
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
        let isCellLiked = modelInputOutput.isItemLiked(withTypes: supportedTypes, at: currentCellIndexPath)
        modelInputOutput.setItemAs(withTypes: supportedTypes, isLiked: !isCellLiked, at: [currentCellIndexPath])
        updateToolBar()
    }
    
    fileprivate func playVideo(_ videoItem: VideoItem) {
        let player = AVPlayer(url: videoItem.url)
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }

    @IBAction func collectionViewDidTap(_ sender: UITapGestureRecognizer) {
        if let videoItem = modelInputOutput.item(withTypes: supportedTypes, at: currentCellIndexPath) as? VideoItem {
            playVideo(videoItem)
        } else {
            toggleFullScreen()
        }
    }

    @IBAction func collectionViewDidDubbleTap(_ sender: UITapGestureRecognizer) {
        delegate?.didDoubleTap(self)
    }
    
    private func updateCurrentCellIndexPath(_ contentOffset: CGFloat) {
        let cellWidth = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width
        let row = Int((contentOffset / cellWidth).rounded())
        presentationInputOutput.setItemAsCurrent(at: IndexPath(row: row, section: 0), withTypes: supportedTypes)
    }

    // MARK: - Misc

    private func cacheFirstImagesForCarouselViewAdapter() {
        let start = -10
        let count = 10

        var currentIndexPath = IndexPath(item: 0, section: 0)
        if presentationInputOutput.currentItemIndex(withTypes: supportedTypes).row < modelInputOutput.numberOfItems(withTypes: supportedTypes) {
            currentIndexPath = presentationInputOutput.currentItemIndex(withTypes: supportedTypes)
        }

        for delta in start..<count {
            //avoid going out of bounds
            let safeIndex = min(max(currentIndexPath.row + delta, 0), modelInputOutput.numberOfItems(withTypes: supportedTypes) - 1)
            if let item = modelInputOutput.item(
                withTypes: supportedTypes,
                at: IndexPath(item: safeIndex, section: 0)),
                ImageCache.shared.sizedImage(forKey: item.id) == nil {
                ImageCache.shared.setSized(UIImage(), forKey: item.id)
                DispatchQueue.global().async {
                    let sizedImage = UIImageHelper.imageWithImage(image: item.image, scaledToSize: CGSize(width: 30, height: 50))
                    ImageCache.shared.setSized(sizedImage, forKey: item.id)
                }
            }
        }
    }
    
}

extension CarouselViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelInputOutput.numberOfItems(withTypes: supportedTypes)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCollectionViewCell",
                                                      for: indexPath) as! CarouselCollectionViewCell
        let item = modelInputOutput.item(withTypes: supportedTypes, at: indexPath)
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
                at: presentationInputOutput.currentItemIndex(withTypes: supportedTypes),
                at: .centeredHorizontally,
                animated: false)
        }
        if !(carouselControlCollectionView.isTracking || carouselControlCollectionView.isDecelerating) {
            carouselControlCollectionView.scrollToItem(
                at: presentationInputOutput.currentItemIndex(withTypes: supportedTypes),
                at: .centeredHorizontally,
                animated: true)
        }
    }

    func getSupportedTypes() -> ItemTypes {
        return supportedTypes
    }

}
