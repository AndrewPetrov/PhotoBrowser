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

    private weak var presentationInput: PresentationInput!

    @IBOutlet private weak var collectionView: UICollectionView!


//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func makeCarouselViewController(presentationInput: PresentationInput) -> CarouselViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CarouselViewController") as! CarouselViewController
        newViewController.presentationInput = presentationInput

        return newViewController
    }

//
//    init(presentationInput: PresentationInput) {
////        super.init(nibName: nil, bundle: nil)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    private func setupCollectionView() {
//        collectionView
//        collectionView?.register(UINib(nibName: "CarouselCollectionViewCell", bundle: nil),
//                                 forCellWithReuseIdentifier: "CarouselCollectionViewCell")

    }

}

extension CarouselViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presentationInput.numberOfItems()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCollectionViewCell",
                                                      for: indexPath) as! CarouselCollectionViewCell
//        cell.delegate = self
//        cell.isForPreviewOnly = isForPreviewOnly
//        if let network: SocialNetworkEntity = dataSourceArray?[indexPath.row]{
//            cell.configure(network: network, index:indexPath.row)
//        }
        cell.configureCell(image: presentationInput.item(at: indexPath)?.image)

        return cell
    }

}

extension CarouselViewController : PresentationOutput {
    func setItem(at index: IndexPath, isSelected: Bool) {

    }

    func setItemAsCurrent(at index: IndexPath) {
        
    }

    
}
