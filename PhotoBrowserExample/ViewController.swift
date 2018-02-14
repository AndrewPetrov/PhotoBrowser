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
    private var photoBrowser: PhotoBrowser?

    override func viewDidLoad() {
        super.viewDidLoad()

        populateGalleryDataSource()
    }

    private func populateGalleryDataSource() {
        //add video
        if let path = Bundle.main.path(forResource: "small", ofType:"mp4") {
            let url = URL(fileURLWithPath: path)
            let videoItem = VideoItem(url: url, thumbnail: nil)
            items.append(videoItem)
        } else {
            debugPrint("small.mp4 not found")
        }
        //add photo
        items.append(ImageItem(image: UIImage(named: "11")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "2")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "3")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "4")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "5")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "6")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "7")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "8")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "9")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "10")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "1")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "2")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "3")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "4")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "5")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "6")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "7")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "8")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "9")!, deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "10")!, deliveryStatus: .delivered))

        //add links
        items.append(LinkItem(url: URL(string: "https://developer.apple.com/")!, thumbnail: #imageLiteral(resourceName: "linkAppDev"), name: "apple.com", deliveryStatus: .delivered))
        items.append(LinkItem(url: URL(string: "https://www.google.com/")!, thumbnail: #imageLiteral(resourceName: "linkGoogle"), name: "google.com", deliveryStatus: .seen))

        //add docs
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didTapOnGroupedPhoto(_ sender: Any) {
        photoBrowser = PhotoBrowser(dataSource: self, delegate: self, presentation: .table)
        if let photoBrowser = photoBrowser {
            navigationController?.pushViewController(photoBrowser, animated: true)
        }
    }

    @IBAction func didTapOnSinglePhoto(_ sender: Any) {
        photoBrowser = PhotoBrowser(dataSource: self, delegate: self, presentation: .carousel)
        if let photoBrowser = photoBrowser {
            navigationController?.pushViewController(photoBrowser, animated: true)
        }
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

    func scrollToMessage(at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Scrolled to message", message: "\(indexPath)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Clear", style: .default) { [weak self] _ in
             alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

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


