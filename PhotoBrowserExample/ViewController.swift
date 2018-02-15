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
        func getPastDay(_ by: Int) -> Date {
            let today = Date()
            return Calendar.current.date(byAdding: .day, value: -by, to: today)!
        }

        if let path = Bundle.main.path(forResource: "small", ofType:"mp4") {
            let url = URL(fileURLWithPath: path)
            let videoItem = VideoItem(url: url, thumbnail: nil)
            items.append(videoItem)
        } else {
            debugPrint("small.mp4 not found")
        }

        //add photo
        items.append(ImageItem(image: UIImage(named: "11")!, sentTime: getPastDay(1), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "2")!, sentTime: getPastDay(2), deliveryStatus: .delivered))
        if let path = Bundle.main.path(forResource: "Cock - 10685", ofType:"mp4") {
            let url = URL(fileURLWithPath: path)
            let videoItem = VideoItem(url: url, thumbnail: nil)
            items.append(videoItem)
        } else {
            debugPrint("small.mp4 not found")
        }
        items.append(ImageItem(image: UIImage(named: "3")!, sentTime: getPastDay(4), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "4")!, sentTime: getPastDay(5), deliveryStatus: .delivered))

        if let path = Bundle.main.path(forResource: "Roast - 11620", ofType:"mp4") {
            let url = URL(fileURLWithPath: path)
            let videoItem = VideoItem(url: url, thumbnail: nil)
            items.append(videoItem)
        } else {
            debugPrint("small.mp4 not found")
        }
        items.append(ImageItem(image: UIImage(named: "5")!, sentTime: getPastDay(6), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "6")!, sentTime: getPastDay(7), deliveryStatus: .delivered))

        if let path = Bundle.main.path(forResource: "Runner - 10809", ofType:"mp4") {
            let url = URL(fileURLWithPath: path)
            let videoItem = VideoItem(url: url, thumbnail: nil)
            items.append(videoItem)
        } else {
            debugPrint("small.mp4 not found")
        }
        items.append(ImageItem(image: UIImage(named: "7")!, sentTime: getPastDay(8), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "8")!, sentTime: getPastDay(9), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "9")!, sentTime: getPastDay(10), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "10")!, sentTime: getPastDay(11), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "1")!, sentTime: getPastDay(12), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "2")!, sentTime: getPastDay(13), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "3")!, sentTime: getPastDay(14), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "4")!, sentTime: getPastDay(15), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "5")!, sentTime: getPastDay(16), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "6")!, sentTime: getPastDay(17), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "7")!, sentTime: getPastDay(18), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "8")!, sentTime: getPastDay(19), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "9")!, sentTime: getPastDay(20), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "10")!, sentTime: getPastDay(21), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "7")!, sentTime: getPastDay(8), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "8")!, sentTime: getPastDay(9), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "9")!, sentTime: getPastDay(10), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "10")!, sentTime: getPastDay(11), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "1")!, sentTime: getPastDay(12), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "2")!, sentTime: getPastDay(13), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "3")!, sentTime: getPastDay(14), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "4")!, sentTime: getPastDay(15), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "5")!, sentTime: getPastDay(16), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "6")!, sentTime: getPastDay(17), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "7")!, sentTime: getPastDay(18), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "8")!, sentTime: getPastDay(19), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "9")!, sentTime: getPastDay(20), deliveryStatus: .delivered))
        items.append(ImageItem(image: UIImage(named: "10")!, sentTime: getPastDay(21), deliveryStatus: .delivered))

        //add links
        items.append(LinkItem(url: URL(string: "https://developer.apple.com/")!, thumbnail: #imageLiteral(resourceName: "linkAppDev"), name: "apple.com", deliveryStatus: .delivered))
        items.append(LinkItem(url: URL(string: "https://www.google.com/")!, thumbnail: #imageLiteral(resourceName: "linkGoogle"), name: "google.com", deliveryStatus: .seen))

        //add docs

        let fm = FileManager.default
        let docsurl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let myurl = docsurl.appendingPathComponent("small.mp4")

        items.append(DocumentItem(url: myurl, name: "Doc 1", sentTime: getPastDay(18), deliveryStatus: .seen))
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

    func typesOfItems() -> [ItemType] {
        var itemTypes = Set<ItemType>()
        _ = items.map { itemTypes.insert($0.type) }

        return Array(itemTypes)
    }

    func senderName() -> String {
        return "Some your friend"
    }

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
        let filteredItems = items.filter { item -> Bool in
            types.contains { $0 == item.type }
        }
        return filteredItems
    }
    
}

extension ViewController: PhotoBrowserDelegate {

    func saveItem(withTypes types: [ItemType], indexPathes: [IndexPath]) {
        print("saved item with indexPath = \(indexPathes)")
    }

    func forwardItem(withTypes types: [ItemType], indexPathes: [IndexPath]) {
        print("forward item with indexPath = \(indexPathes)")
    }

    func shareItem(withTypes types: [ItemType], indexPathes: [IndexPath]) {
        print("shared item with indexPath = \(indexPathes)")
    }

    func setAsMyProfilePhoto(withTypes types: [ItemType], indexPath: IndexPath) {
        print("set As My Profile Photo item with indexPath = \(indexPath)")
    }

    func scrollToMessage(at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Scrolled to message", message: "\(indexPath)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Clear", style: .default) { [weak self] _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func setItemAs(withTypes types: [ItemType], isLiked: Bool, at indexPathes: [IndexPath]) {
        let indexPathes = indexPathes.sorted()
        var filtredItemsArray = filtredItems(withTypes: types)

        for indexPath in indexPathes {
            let itemForLike = filtredItemsArray[indexPath.row]
            if let indexForLike = items.index(of: itemForLike), indexForLike >= 0, indexForLike < items.count {
                if var item = items[indexForLike] as? Likable {
                    item.isLiked = isLiked
                }
            }
        }
    }

    func deleteItems(withTypes types: [ItemType], indexPathes: [IndexPath]) {
        let indexPathes = indexPathes.sorted()
        var filtredItemsArray = filtredItems(withTypes: types)

        for indexPath in indexPathes {
            let itemForDeletion = filtredItemsArray[indexPath.row]
            if let indexForDetetion = items.index(of: itemForDeletion), indexForDetetion >= 0, indexForDetetion < items.count {
                items.remove(at: indexForDetetion)
            }
        }
    }

}


