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

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
        items = [Item]()
    }

    private func appendPhotos(count: Int, startIndex: Int) {
        let namesArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]

        for index in 0..<count {
            items.append(
                ImageItem(id: index + startIndex,
                          image: UIImage(named: namesArray[index % namesArray.count])!,
                          sentTime: getPastDay(index),
                          deliveryStatus: .delivered)
            )
        }
    }

    func getPastDay(_ by: Int) -> Date {
        let today = Date()
        return Calendar.current.date(byAdding: .day, value: -by, to: today)!
    }

    private func populateGalleryDataSource() {
        items = [Item]()
        //add video

//        if let path = Bundle.main.path(forResource: "small", ofType:"mp4") {
//            let url = URL(fileURLWithPath: path)
//            let videoItem = VideoItem(id: 1, url: url, thumbnail: nil)
//            items.append(videoItem)
//        } else {
//            debugPrint("small.mp4 not found")
//        }
//
//        //add photo
//        items.append(ImageItem(id: 2, image: UIImage(named: "11")!, sentTime: getPastDay(1), deliveryStatus: .delivered))
//        items.append(ImageItem(id: 3, image: UIImage(named: "2")!, sentTime: getPastDay(2), deliveryStatus: .delivered))
//        if let path = Bundle.main.path(forResource: "Cock - 10685", ofType:"mp4") {
//            let url = URL(fileURLWithPath: path)
//            let videoItem = VideoItem(id: 4, url: url, thumbnail: nil)
//            items.append(videoItem)
//        } else {
//            debugPrint("small.mp4 not found")
//        }
//
//        if let path = Bundle.main.path(forResource: "Roast - 11620", ofType:"mp4") {
//            let url = URL(fileURLWithPath: path)
//            let videoItem = VideoItem(id: 7, url: url, thumbnail: nil)
//            items.append(videoItem)
//        } else {
//            debugPrint("small.mp4 not found")
//        }
//
//        if let path = Bundle.main.path(forResource: "Runner - 10809", ofType:"mp4") {
//            let url = URL(fileURLWithPath: path)
//            let videoItem = VideoItem(id: 8, url: url, thumbnail: nil)
//            items.append(videoItem)
//        } else {
//            debugPrint("small.mp4 not found")
//        }
//
//
//        //add links
//        items.append(LinkItem(id: 9, url: URL(string: "https://developer.apple.com/")!, thumbnail: #imageLiteral(resourceName: "linkAppDev"), name: "apple.com", deliveryStatus: .delivered))
//        items.append(LinkItem(id: 10, url: URL(string: "https://www.google.com/")!, thumbnail: #imageLiteral(resourceName: "linkGoogle"), name: "google.com", deliveryStatus: .seen))
//
//        //add docs
//
//        let fm = FileManager.default
//        let docsurl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//        let myurl = docsurl.appendingPathComponent("small.mp4")
//
//
//        //add links
//        items.append(LinkItem(id: 11, url: URL(string: "https://developer.apple.com/")!, thumbnail: #imageLiteral(resourceName: "linkAppDev"), name: "apple.com", deliveryStatus: .delivered))
//        items.append(LinkItem(id: 12, url: URL(string: "https://www.google.com/")!, thumbnail: #imageLiteral(resourceName: "linkGoogle"), name: "google.com", deliveryStatus: .seen))
//
//        //add docs
//        items.append(DocumentItem(id: 13, url: myurl, name: "Doc 1", sentTime: getPastDay(18), deliveryStatus: .seen))
//        items.append(DocumentItem(id: 14, url: myurl, name: "Doc 2", sentTime: getPastDay(2), deliveryStatus: .seen))
//        items.append(DocumentItem(id: 15, url: myurl, name: "Doc 3", sentTime: getPastDay(4), deliveryStatus: .seen))
//        items.append(DocumentItem(id: 16, url: myurl, name: "Doc 4", sentTime: getPastDay(6), deliveryStatus: .seen))
//        items.append(DocumentItem(id: 17, url: myurl, name: "Doc 5", sentTime: getPastDay(9), deliveryStatus: .seen))
//

        appendPhotos(count: 30, startIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapOnGroupedPhoto(_ sender: Any) {
        populateGalleryDataSource()
        DispatchQueue.main.async {
            let photoBrowserModel = PhotoBrowserModel.make(dataSource: self, delegate: self)
            let photoBrowser = PhotoBrowser(modelInputOutput: photoBrowserModel, presentation: .table)
            self.navigationController?.pushViewController(photoBrowser, animated: true)
        }
        
    }

    @IBAction func didTapOnSinglePhoto(_ sender: Any) {
        populateGalleryDataSource()
        let photoBrowserModel = PhotoBrowserModel.make(dataSource: self, delegate: self)
        let photoBrowser = PhotoBrowser(modelInputOutput: photoBrowserModel, presentation: .carousel)
        navigationController?.pushViewController(photoBrowser, animated: true)
    }

}

extension ViewController: PhotoBrowserDataSouce {

    func items(for indexPaths: [IndexPath]) -> [Item] {
        var tempItems = [Item]()
        for indexPath in indexPaths {
            if indexPath.row <= items.endIndex {
                tempItems.append(items[indexPath.row])
            }
        }
        return tempItems
    }

    func itemsCount() -> Int {
        return items.count
    }


//    func typesOfItems() -> ItemTypes {
//        var itemTypes = ItemTypes()
//        _ = items.map { itemTypes.insert($0.type) }
//
//        return itemTypes
//    }

    func senderName() -> String {
        return "Some your friend"
    }

//    func numberOfItems(withTypes types: ItemTypes) -> Int {
//        return filtredItems(withTypes: types).count
//    }

//    func item(withTypes types: ItemTypes, at indexPath: IndexPath) -> Item? {
//        if indexPath.row < filtredItems(withTypes: types).count {
//            return filtredItems(withTypes: types)[indexPath.row]
//        }
//        return nil
//    }

    func numberOfItems() -> Int {
        return items.count
    }

    func startingItemIndexPath() -> IndexPath {
        return IndexPath(item: 0, section: 0)
    }
    
}

extension ViewController: PhotoBrowserDelegate {

    func setItemAs(at indexPaths: [IndexPath], isLiked: Bool) {
        for indexPath in indexPaths {
            items[indexPath.row].isLiked = isLiked
        }
    }

    func deleteItems(at indexPaths: [IndexPath]) {
        //when remove in straight forward direction items array gets smaller and there aren't mambers for second half of indexPaths
        for indexPath in indexPaths.reversed() {
            items.remove(at: indexPath.row)
        }
    }

    func scrollToMessage(at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Scrolled to message", message: "\(indexPath)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Clear", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func saveItem(at indexPaths: [IndexPath]) {
        print("saved item with indexPath = \(indexPaths)")
    }

    func forwardItem(at indexPaths: [IndexPath]) {
        print("forward item with indexPath = \(indexPaths)")
    }

    func shareItem(at indexPaths: [IndexPath]) {
        print("shared item with indexPath = \(indexPaths)")
    }

    func setAsMyProfilePhoto(indexPath: IndexPath) {
        print("set As My Profile Photo item with indexPath = \(indexPath)")
    }


//    func saveItem(indexPaths: [IndexPath]) {
//        print("saved item with indexPath = \(indexPaths)")
//    }

//    func forwardItem(withTypes types: ItemTypes, indexPaths: [IndexPath]) {
//        print("forward item with indexPath = \(indexPaths)")
//    }

//    func shareItem(withTypes types: ItemTypes, indexPaths: [IndexPath]) {
//        print("shared item with indexPath = \(indexPaths)")
//    }

//    func setAsMyProfilePhoto(withTypes types: ItemTypes, indexPath: IndexPath) {
//        print("set As My Profile Photo item with indexPath = \(indexPath)")
//    }



//    func setItemAs(withTypes types: ItemTypes, isLiked: Bool, at indexPaths: [IndexPath]) {
////        var filtredItemsArray = filtredItems(withTypes: types)
//
//        for indexPath in indexPaths {
//            let itemForLike = filtredItemsArray[indexPath.row]
//            print(items.index(of: itemForLike))
//            if let indexForLike = items.index(of: itemForLike), indexForLike >= 0, indexForLike < items.count {
//                items[indexForLike].isLiked = isLiked
//            } else {
//                dump(itemForLike)
//                print("------------")
//                dump(items)
//            }
//        }
//    }

//    func deleteItems(withTypes types: ItemTypes, indexPaths: [IndexPath]) {
//        let indexPaths = indexPaths.sorted()
//        var filtredItemsArray = filtredItems(withTypes: types)
//
//        for indexPath in indexPaths {
//            let itemForDeletion = filtredItemsArray[indexPath.row]
//            if let indexForDetetion = items.index(of: itemForDeletion), indexForDetetion >= 0, indexForDetetion < items.count {
//                items.remove(at: indexForDetetion)
//            }
//        }
//        itemsCache = [ItemTypes: [Item]]()
//    }

}


