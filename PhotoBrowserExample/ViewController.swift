//
//  ViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var items: [Item]!
    lazy var photoBrowser: PhotoBrowser = PhotoBrowser(dataSource: self, delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        items = [
            ImageItem(image: UIImage(named: "11")!),
            ImageItem(image: UIImage(named: "2")!),
            ImageItem(image: UIImage(named: "3")!),
            ImageItem(image: UIImage(named: "4")!),
            ImageItem(image: UIImage(named: "5")!),
            ImageItem(image: UIImage(named: "6")!),
            ImageItem(image: UIImage(named: "7")!),
            ImageItem(image: UIImage(named: "8")!),
            ImageItem(image: UIImage(named: "9")!),
            ImageItem(image: UIImage(named: "10")!),
            ImageItem(image: UIImage(named: "1")!)
        ]
        (items[2] as! ImageItem).isLiked = true
        (items[4] as! ImageItem).isLiked = true
        (items[7] as! ImageItem).isLiked = true

        (items[7] as! ImageItem).deliveryStatus = .nonDelivered
        (items[4] as! ImageItem).deliveryStatus = .delivered
        (items[2] as! ImageItem).deliveryStatus = .seen

        if let path = Bundle.main.path(forResource: "small", ofType:"mp4") {
            let url = URL(fileURLWithPath: path)
            let videoItem = VideoItem(url: url, thumbnail: nil)
            items.append(videoItem)
        } else {
            debugPrint("small.mp4 not found")
        }
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

    func numberOfItems(withTypes types: [ItemType]) -> Int {
        return filtredItems(withTypes: types).count
    }

    func item(withTypes types: [ItemType], at indexPath: IndexPath) -> Item? {
        return filtredItems(withTypes: types)[indexPath.row]
    }

    func numberOfItems() -> Int {
        return items?.count ?? 0
    }

    func startingItemIndexPath() -> IndexPath {
        return IndexPath(item: 0, section: 0)
    }

    func item(at indexPath: IndexPath) -> Item? {
        return items?[indexPath.row]
    }

    private func filtredItems(withTypes types: [ItemType]) -> [Item] {
        let filteredItems = items.filter { imageItem -> Bool in
            types.contains { $0 == imageItem.type }
        }
        return filteredItems
    }


}

extension ViewController: PhotoBrowserDelegate {
    func setItemAs(isLiked: Bool, at indexPath: IndexPath) {
        if var item = items[indexPath.row] as? Likable {
            item.isLiked = isLiked
        }
    }

    func deleteItems(indexPathes: Set<IndexPath>) {
        for indexPath in indexPathes {
            items.remove(at: indexPath.row)
        }
    }


}


