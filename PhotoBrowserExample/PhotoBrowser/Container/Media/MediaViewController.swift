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

    let supportedTypes: [ItemType] = [.image, .video]
    @IBOutlet private weak var collectionView: UICollectionView!
    private weak var presentationInputOutput: PresentationInputOutput!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func make(presentationInputOutput: PresentationInputOutput) -> MediaViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MediaViewController") as! MediaViewController
        newViewController.presentationInputOutput = presentationInputOutput

        return newViewController
    }

    private func setupCollectionView() {
    }

}

extension MediaViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presentationInputOutput.numberOfItems(withType: supportedTypes)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCollectionViewCell",
                                                      for: indexPath) as! MediaCollectionViewCell
        cell.configureCell(image: presentationInputOutput.item(withType: supportedTypes, at: indexPath)?.image)

        return cell
    }

}

extension MediaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentationInputOutput.setItemAsCurrent(at: indexPath)
        presentationInputOutput.switchTo(presentation: .carousel)
    }
}

