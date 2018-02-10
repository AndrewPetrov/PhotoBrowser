//
//  ViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var images: [ImageItem]?
    lazy var photoBrowser: PhotoBrowser = PhotoBrowser(dataSource: self, delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        images = [
            ImageItem(image: UIImage(named: "1")!),
            ImageItem(image: UIImage(named: "2")!),
            ImageItem(image: UIImage(named: "3")!),
            ImageItem(image: UIImage(named: "4")!),
            ImageItem(image: UIImage(named: "5")!),
            ImageItem(image: UIImage(named: "6")!),
            ImageItem(image: UIImage(named: "7")!),
            ImageItem(image: UIImage(named: "8")!),
            ImageItem(image: UIImage(named: "9")!),
            ImageItem(image: UIImage(named: "10")!)
        ]
        images![2].isLiked = true

    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.pushViewController(photoBrowser, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: PhotoBrowserDataSouce {
    func numberOfItems() -> Int {
        return images?.count ?? 0
    }

    func currentItemIndex() -> IndexPath {
        return IndexPath(item: 0, section: 0)
    }

    func item(at index: IndexPath) -> Item? {
        return images?[index.row]
    }


}

extension ViewController: PhotoBrowserDelegate {

}


