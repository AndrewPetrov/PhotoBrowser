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
        let namesArray = (1...11).map { String($0) }//["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
        
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
        
        if let path = Bundle.main.path(forResource: "small", ofType: "mp4") {
            let url = URL(fileURLWithPath: path)
            let videoItem = VideoItem(id: 1, url: url, thumbnail: nil)
            items.append(videoItem)
        } else {
            debugPrint("small.mp4 not found")
        }
        
        //add photo
        items.append(
            ImageItem(id: 2, image: UIImage(named: "11")!, sentTime: getPastDay(1), deliveryStatus: .delivered)
        )
        items.append(ImageItem(id: 3, image: UIImage(named: "2")!, sentTime: getPastDay(2), deliveryStatus: .delivered))
        if let path = Bundle.main.path(forResource: "Cock - 10685", ofType: "mp4") {
            let url = URL(fileURLWithPath: path)
            let videoItem = VideoItem(id: 4, url: url, thumbnail: nil)
            items.append(videoItem)
        } else {
            debugPrint("Cock - 10685.mp4 not found")
        }
        
        if let path = Bundle.main.path(forResource: "Roast - 11620", ofType: "mp4") {
            let url = URL(fileURLWithPath: path)
            let videoItem = VideoItem(id: 7, url: url, thumbnail: nil)
            items.append(videoItem)
        } else {
            debugPrint("Roast - 11620.mp4 not found")
        }
        
        if let path = Bundle.main.path(forResource: "Runner - 10809", ofType: "mp4") {
            let url = URL(fileURLWithPath: path)
            let videoItem = VideoItem(id: 8, url: url, thumbnail: nil)
            items.append(videoItem)
        } else {
            debugPrint("Runner - 10809.mp4 not found")
        }
        
        //add links
        items.append(
            LinkItem(
                id: 9,
                url: URL(string: "https://developer.apple.com/")!,
                thumbnail: #imageLiteral(resourceName: "linkAppDev"),
                name: "apple.com",
                deliveryStatus: .delivered
            )
        )
        items.append(
            LinkItem(
                id: 10,
                url: URL(string: "https://www.google.com/")!,
                thumbnail: #imageLiteral(resourceName: "linkGoogle"),
                name: "google.com",
                deliveryStatus: .seen
            )
        )
        
        //add links
        items.append(
            LinkItem(
                id: 11,
                url: URL(string: "https://developer.apple.com/")!,
                thumbnail: #imageLiteral(resourceName: "linkAppDev"),
                name: "apple.com",
                deliveryStatus: .delivered
            )
        )
        items.append(
            LinkItem(
                id: 12,
                url: URL(string: "https://www.google.com/")!,
                thumbnail: #imageLiteral(resourceName: "linkGoogle"),
                name: "google.com",
                deliveryStatus: .seen
            )
        )
        
        //add docs
        
        let myUrl2 = Bundle.main.path(forResource: "NSPredicateCheatsheet", ofType: "pdf")
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileManager = FileManager.default
        debugPrint(fileManager.fileExists(atPath: myUrl2!))
        
        items.append(
            DocumentItem(
                id: 13,
                url: URL(fileURLWithPath: myUrl2!),
                name: "PDF",
                sentTime: getPastDay(18),
                deliveryStatus: .seen
            )
        )
        
        appendPhotos(count: 200, startIndex: 40)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapOnGroupedPhoto(_ sender: Any) {
        populateGalleryDataSource()
        DispatchQueue.main.async {
            let photoBrowserModel = PhotoBrowserModel.make(dataSource: self, delegate: self, allowedActions: .onlyShare)
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
    
    @IBAction func showOnlyOnePhoto(_ sender: Any) {
        populateGalleryDataSource()
        let photoBrowserModel = PhotoBrowserModel.make(dataSource: self, delegate: self)
        let photoBrowser = PhotoBrowser(modelInputOutput: photoBrowserModel, presentation: .single)
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
    
    func senderName() -> String {
        return "Some your friend"
    }
    
    func numberOfItems() -> Int {
        return items.count
    }
    
    func startingItemIndexPath() -> IndexPath {
        return IndexPath(item: 2, section: 0)
    }
    
}

extension ViewController: PhotoBrowserDelegate {
    
    func setItemAs(at indexPaths: [IndexPath], isLiked: Bool) {
        for indexPath in indexPaths {
            items[indexPath.row].isLiked = isLiked
        }
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        //when remove in straight forward direction items array gets smaller and there aren't members for second half of indexPaths
        for indexPath in indexPaths.reversed() {
            items.remove(at: indexPath.row)
        }
    }
    
    func scrollToMessage(at indexPath: IndexPath) {
        let alertController = UIAlertController(
            title: "Scrolled to message",
            message: "\(indexPath)",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Clear", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func saveItem(at indexPaths: [IndexPath]) {
        debugPrint("saved item with indexPath = \(indexPaths)")
    }
    
    func forwardItem(at indexPaths: [IndexPath]) {
        debugPrint("forward item with indexPath = \(indexPaths)")
    }
    
    func shareItem(at indexPaths: [IndexPath]) {
        debugPrint("shared item with indexPath = \(indexPaths)")
    }
    
    func setAsMyProfilePhoto(indexPath: IndexPath) {
        debugPrint("set As My Profile Photo item with indexPath = \(indexPath)")
    }
    
}


