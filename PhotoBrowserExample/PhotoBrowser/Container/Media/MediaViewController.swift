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

    static var monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"

        return formatter
    }()

    static var monthAndYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        return formatter
    }()

    // [number_of_month_ago: [Item]]
    var cachedDetaSource = [Int: [Item]]()

    @IBOutlet private weak var collectionView: UICollectionView!
    private weak var presentationInputOutput: PresentationInputOutput!
    private weak var containerInputOutput: ContainerViewControllerInputOutput!
    @IBOutlet private weak var layout: UICollectionViewFlowLayout!

    // MARK: - Life cycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func make(presentationInputOutput: PresentationInputOutput, containerInputOutput: ContainerViewControllerInputOutput) -> MediaViewController {
        let newViewController = UIStoryboard(name: "PhotoBrowser", bundle: nil).instantiateViewController(withIdentifier: "MediaViewController") as! MediaViewController
        newViewController.presentationInputOutput = presentationInputOutput
        newViewController.containerInputOutput = containerInputOutput

        return newViewController
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        updateCacheInBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupCollectionView()
    }

    // MARK: - Setup controls

    private func setupCollectionView() {
        collectionView.allowsMultipleSelection = true
        let minSize = min(collectionView.frame.width / 4, collectionView.frame.height / 4)
        layout.itemSize = CGSize(width: minSize, height: minSize)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionHeadersPinToVisibleBounds = true
        layout.headerReferenceSize = CGSize(width: 30, height: 44)
        layout.footerReferenceSize = CGSize(width: 30, height: 44)
        layout.invalidateLayout()
    }

    private func updateCacheInBackground() {
        DispatchQueue.global(qos: .background).async {
            self.cacheDataSource()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    private func cacheDataSource() {
        cachedDetaSource = [Int: [Item]]()
        let calendar = Calendar.current
        for index in 0..<presentationInputOutput.countOfItems(withType: containerInputOutput.currentlySupportedTypes()) {
            if let item = presentationInputOutput.item(
                withType: containerInputOutput.currentlySupportedTypes(),
                at: IndexPath(item: index, section: 0)) {

                let itemDate = calendar.dateComponents([.year, .month], from: item.sentTime)
                let currentDate = calendar.dateComponents([.year, .month], from: Date())

                let monthDelta = currentDate.month! - itemDate.month! + (currentDate.year! - itemDate.year!) * 12

                if cachedDetaSource[monthDelta] == nil {
                    cachedDetaSource[monthDelta] = [Item]()
                }
                cachedDetaSource[monthDelta]!.append(item)
            }
        }
    }

    private func presentationIndexPath(for sectionedIndexPath: IndexPath) -> IndexPath {
        if let sections = cachedDetaSource[sectionedIndexPath.section], sectionedIndexPath.row < sections.count {
            let item = sections[sectionedIndexPath.row]
            return presentationInputOutput.indexPath(for: item, withTypes: containerInputOutput.currentlySupportedTypes())
        }
        return IndexPath()
    }

}

extension MediaViewController: ContainerViewControllerDelegate {

    func updateCache() {
        updateCacheInBackground()
    }

    func getSelectedIndexPaths() -> [IndexPath] {
        if let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems {
          return indexPathsForSelectedItems.map { presentationIndexPath(for: $0) }
        }
        return [IndexPath]()
    }

    func setItem(at indexPath: IndexPath, slected: Bool) {
        if slected {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }

    func reloadUI() {
        collectionView.reloadData()
    }


}

extension MediaViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section < cachedDetaSource.count, let monthItems = cachedDetaSource[section] {
            return monthItems.count
        }
        return 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cachedDetaSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCollectionViewCell",
                                                      for: indexPath) as! MediaCollectionViewCell
        let isSelectionAllowed = containerInputOutput.isSelectionAllowed()
        if let section = cachedDetaSource[indexPath.section], indexPath.row < section.count {
            let item = section[indexPath.row]
            var videoDuration = ""
            if let item = item as? VideoItem {
                //TODO: calculate duration
                videoDuration = "1:02"
            }
            cell.configureCell(
                image: item.image,
                isSelectionAllowed: isSelectionAllowed,
                isVideo: item.type == .video,
                videoDuration: videoDuration,
                isLiked: item.isLiked
            )
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "MediaCollectionViewHeader",
                                                                             for: indexPath) as! MediaCollectionViewHeader

            let monthDelta = Array(cachedDetaSource.keys).sorted()[indexPath.section]
            var sectionDateSrting: String

            if let sectionMonthAndYear = Calendar.current.date(byAdding: .month, value: 0 - monthDelta, to: Date()) {
                switch monthDelta {
                case 0:
                    sectionDateSrting = "This Month"

                case let monthDelta where monthDelta < 12:
                    sectionDateSrting = MediaViewController.monthFormatter.string(from: sectionMonthAndYear)

                default:
                    sectionDateSrting = MediaViewController.monthAndYearFormatter.string(from: sectionMonthAndYear)
                }
                headerView.configureView(text: sectionDateSrting)
            }

            return headerView

        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "MediaCollectionViewFooter",
                for: indexPath) as! MediaCollectionViewFooter
            var assetsString = ""

            //TODO: conform ItemTypes to Sequence protocol and refactor
            if containerInputOutput.currentlySupportedTypes().contains(.image) {
                let count = cachedDetaSource[indexPath.section]?.filter { $0.type == .image }.count
                assetsString += "\(count!) Images "
            }
            if containerInputOutput.currentlySupportedTypes().contains(.video) {
                let count = cachedDetaSource[indexPath.section]?.filter { $0.type == .video }.count
                assetsString += "\(count!) Videos"
            }
            footerView.configureView(text: assetsString)

            return footerView

        default:
             assert(false, "Unexpected element kind")
        }

    }

}

extension MediaViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if containerInputOutput.isSelectionAllowed() {
            containerInputOutput.didSetItemAs(isSelected: true, at: indexPath)
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            presentationInputOutput.setItemAsCurrent(at: presentationIndexPath(for: indexPath))
            presentationInputOutput.switchTo(presentation: .carousel)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        containerInputOutput.didSetItemAs(isSelected: false, at: indexPath)
    }

}

