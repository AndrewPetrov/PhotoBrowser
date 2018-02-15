//
//  MediaViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class MediaViewController: UIViewController {

//    private let supportedTypes: [ItemType] = [.image, .video]
    @IBOutlet private weak var collectionView: UICollectionView!
    private weak var presentationInputOutput: PresentationInputOutput!
    private weak var containerInputOutput: ContainerViewControllerInputOutput!
    @IBOutlet private weak var layout: UICollectionViewFlowLayout!

    // MARK: - Life cycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func make(presentationInputOutput: PresentationInputOutput, containerInputOutput: ContainerViewControllerInputOutput) -> MediaViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MediaViewController") as! MediaViewController
        newViewController.presentationInputOutput = presentationInputOutput
        newViewController.containerInputOutput = containerInputOutput

        return newViewController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupCollectionView()
    }

    // MARK: - Setup controls

    private func setupCollectionView() {
        collectionView.allowsMultipleSelection = true
            let minSize = min(collectionView.frame.width / 4, collectionView.frame.height / 4)
            print(view.frame, minSize)
            layout.itemSize = CGSize(width: minSize, height: minSize)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.invalidateLayout()
    }

}

extension MediaViewController: ContainerViewControllerDelegate {
    
    func reloadUI() {
        collectionView.reloadData()
    }

}

extension MediaViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presentationInputOutput.numberOfItems(withType: containerInputOutput.currentlySupportedTypes())
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCollectionViewCell",
                                                      for: indexPath) as! MediaCollectionViewCell
        let isSelectionAllowed = containerInputOutput.isSelectionAllowed()
        let isSelected = containerInputOutput.selectedIndexPathes().contains(indexPath)
        if let item = presentationInputOutput.item(withType: containerInputOutput.currentlySupportedTypes(), at: indexPath) {
            var videoDuration = ""
            if let item = item as? VideoItem {
                //TODO: calculate duration
                videoDuration = "1:02"
            }
        cell.configureCell(
            image: presentationInputOutput.item(withType: containerInputOutput.currentlySupportedTypes(), at: indexPath)?.image,
            isSelectionAllowed: isSelectionAllowed,
            isSelected: isSelected,
            isVideo: item.type == .video,
            videoDuration: videoDuration,
            isLiked: item.isLiked
            )
        }

        return cell
    }

}

extension MediaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if containerInputOutput.isSelectionAllowed() {
            containerInputOutput.didSetItemAs(isSelected: true, at: indexPath)
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            presentationInputOutput.setItemAsCurrent(at: indexPath)
            presentationInputOutput.switchTo(presentation: .carousel)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        containerInputOutput.didSetItemAs(isSelected: false, at: indexPath)
    }

}
