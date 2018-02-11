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

    var items = [Item]()
    lazy var photoBrowser: PhotoBrowser = PhotoBrowser(dataSource: self, delegate: self, presentation: .table)

    override func viewDidLoad() {
        super.viewDidLoad()


        if let path = Bundle.main.path(forResource: "small", ofType:"mp4") {
            let url = URL(fileURLWithPath: path)
            let videoItem = VideoItem(url: url, thumbnail: nil)
            items.append(videoItem)
        } else {
            debugPrint("small.mp4 not found")
        }
        items.append(ImageItem(image: UIImage(named: "11")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "3")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "5")!, deliveryStatus: .delivered))
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
        return items.count
    }

    func startingItemIndexPath() -> IndexPath {
        return IndexPath(item: 0, section: 0)
    }

    func item(at indexPath: IndexPath) -> Item? {
        return items[indexPath.row]
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


