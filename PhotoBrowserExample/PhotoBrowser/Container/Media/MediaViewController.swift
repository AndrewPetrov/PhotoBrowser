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

    @IBOutlet private weak var collectionView: UICollectionView!
    private weak var presentationInputOutput: PresentationInputOutput!


    //    required init?(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }

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
        //        collectionView
        //        collectionView?.register(UINib(nibName: "CarouselCollectionViewCell", bundle: nil),
        //                                 forCellWithReuseIdentifier: "CarouselCollectionViewCell")

    }




    
}

extension MediaViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presentationInputOutput.numberOfItems()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCollectionViewCell",
                                                      for: indexPath) as! MediaCollectionViewCell
        //        cell.delegate = self
        //        cell.isForPreviewOnly = isForPreviewOnly
        //        if let network: SocialNetworkEntity = dataSourceArray?[indexPath.row]{
        //            cell.configure(network: network, indexPath:indexPath.row)
        //        }
        cell.configureCell(image: presentationInputOutput.item(at: indexPath)?.image)

        return cell
    }

}

//extension MediaViewController : PresentationOutput {
//    func deleteItems(indexPathes: Set<IndexPath>) {
//        print("delete", indexPathes)
//    }
//
//
//    func setItem(at indexPath: IndexPath, isSelected: Bool) {
//
//    }
//
//    func setItemAsCurrent(at indexPath: IndexPath) {
//        
//    }
//
//
//}

