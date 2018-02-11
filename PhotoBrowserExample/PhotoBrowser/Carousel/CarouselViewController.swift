//
//  CarouselViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class CarouselViewController: UIViewController {

    private weak var presentationInputOutput: PresentationInputOutput!
    @IBOutlet private weak var layout: UICollectionViewFlowLayout!

    @IBOutlet private weak var collectionView: UICollectionView!

    @IBOutlet weak var carouselView: UIView!
    @IBOutlet weak var toolbar: UIToolbar!

    override var prefersStatusBarHidden: Bool {
        return isFullScreen
    }

    private var isFullScreen: Bool = false


//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

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


    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setupCollectionView()
    }

    private func toggleFullScreen() {
        isFullScreen = !isFullScreen
        navigationController?.isNavigationBarHidden = isFullScreen
        carouselView.alpha = isFullScreen ? 0 : 1
        toolbar.alpha = isFullScreen ? 0 : 1
//        navigationController?.navigationBar.alpha = isFullScreen ? 0 : 1

        


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
//            cell.configure(network: network, index:indexPath.row)
//        }
        cell.configureCell(image: presentationInputOutput.item(at: indexPath)?.image) {
//            isFullScreen = !isFullScreen
        }

        return cell
    }

}

extension CarouselViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("didTap")
        toggleFullScreen()

    }
    
}

//extension CarouselViewController : PresentationOutput {
//    func deleteItems(indexPathes: Set<IndexPath>) {
//
//    }
//
//    func setItem(at index: IndexPath, isSelected: Bool) {
//
//    }
//
//    func setItemAsCurrent(at index: IndexPath) {
//
//    }
//
//
//}

