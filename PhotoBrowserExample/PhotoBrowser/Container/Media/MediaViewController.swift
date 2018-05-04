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
    var cachedDataSource = [Int: [Item]]()

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var layout: UICollectionViewFlowLayout!

    private weak var modelInputOutput: ModelInputOutput!
    private weak var containerInputOutput: ContainerViewControllerInputOutput!
    private let footerView: MediaCollectionViewFooter = UIView.fromNib()

    // MARK: - Life cycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func make(modelInputOutput: ModelInputOutput, containerInputOutput: ContainerViewControllerInputOutput) -> MediaViewController {
        let newViewController = UIStoryboard(name: "PhotoBrowser", bundle: nil).instantiateViewController(
            withIdentifier: "MediaViewController"
        ) as! MediaViewController
        newViewController.modelInputOutput = modelInputOutput
        newViewController.containerInputOutput = containerInputOutput

        return newViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateCacheInBackground()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupCollectionView()
    }

    // MARK: - Setup controls

    private func setupCollectionView() {
        let space: CGFloat = 2
        collectionView.allowsMultipleSelection = true
        let minSize = min((collectionView.frame.width - space * 5) / 4, (collectionView.frame.height - space * 5 / 4))
        layout.itemSize = CGSize(width: minSize, height: minSize)
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        layout.sectionHeadersPinToVisibleBounds = true
        layout.headerReferenceSize = CGSize(width: 30, height: 44)

        addFooter(space: space)
        layout.invalidateLayout()
    }

    private func addFooter(space: CGFloat) {
        let footerHeight: CGFloat = 50
        collectionView.contentInset = UIEdgeInsets(top: space, left: space, bottom: footerHeight, right: space)
        collectionView.addSubview(footerView)
        footerView.frame = CGRect(origin:
                                  CGPoint(x: 0, y: collectionView.contentSize.height),
                                  size: CGSize(width: collectionView.contentSize.width, height: footerHeight)
        )

        var assetsString = ""
        if containerInputOutput.currentlySupportedTypes()
               .contains(.image) {
            let count = cachedDataSource.reduce([Item]()) { (result: [Item], arg1) -> [Item] in
                    let (_, value) = arg1
                    var newArray = result
                    newArray.append(contentsOf: value)

                    return newArray
                }
                .filter { $0.type == .image }.count
            assetsString += "\(count) Images "
        }
        if containerInputOutput.currentlySupportedTypes()
               .contains(.video) {
            let count = cachedDataSource.reduce([Item]()) { (result: [Item], arg1) -> [Item] in
                    let (_, value) = arg1
                    var newArray = result
                    newArray.append(contentsOf: value)

                    return newArray
                }
                .filter { $0.type == .video }.count

            assetsString += "\(count) Videos"
        }
        footerView.configureView(text: assetsString)
    }

    private func updateCacheInBackground() {
        DispatchQueue.global()
            .async {
                self.cacheDataSource()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
    }

    private func cacheDataSource() {
        cachedDataSource = [Int: [Item]]()
        let calendar = Calendar.current
        for index in 0..<modelInputOutput.numberOfItems(withTypes: containerInputOutput.currentlySupportedTypes()) {
            if let item = modelInputOutput.item(
                withTypes: containerInputOutput.currentlySupportedTypes(),
                at: IndexPath(item: index, section: 0)) {

                let itemDate = calendar.dateComponents([.year, .month], from: item.sentTime)
                let currentDate = calendar.dateComponents([.year, .month], from: Date())

                let monthDelta = currentDate.month! - itemDate.month! + (currentDate.year! - itemDate.year!) * 12

                if cachedDataSource[monthDelta] == nil {
                    cachedDataSource[monthDelta] = [Item]()
                }
                cachedDataSource[monthDelta]!.append(item)
            }
        }
    }

    private func presentationIndexPath(for sectionedIndexPath: IndexPath) -> IndexPath {
        if let sections = cachedDataSource[sectionedIndexPath.section], sectionedIndexPath.row < sections.count {
            let item = sections[sectionedIndexPath.row]
            return modelInputOutput.indexPath(for: item, withTypes: containerInputOutput.currentlySupportedTypes())
        }
        return IndexPath()
    }

    private func sectionedIndexPath(for presentationIndexPath: IndexPath) -> IndexPath {
        let targetItem = modelInputOutput.item(
            withTypes: containerInputOutput.currentlySupportedTypes(),
            at: presentationIndexPath
        )
        for section in cachedDataSource.keys {
            for index in 0..<cachedDataSource[section]!.count {
                if cachedDataSource[section]![index] == targetItem {
                    return IndexPath(item: index, section: section)
                }
            }
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

    func setItem(at indexPath: IndexPath, selected: Bool) {
        let targetIndexPath = sectionedIndexPath(for: indexPath)
        if selected {
            collectionView.selectItem(at: targetIndexPath, animated: false, scrollPosition: .left)
        } else {
            collectionView.deselectItem(at: targetIndexPath, animated: false)
        }
    }

    func reloadUI() {
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }

}

extension MediaViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section < cachedDataSource.count, let monthItems = cachedDataSource[section] {
            return monthItems.count
        }
        return 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cachedDataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCollectionViewCell",
                                                      for: indexPath) as! MediaCollectionViewCell
        let isSelectionAllowed = containerInputOutput.isSelectionAllowed()
        if let section = cachedDataSource[indexPath.section], indexPath.row <= section.endIndex {
            let item = section[indexPath.row]
            var videoDuration = ""
            if item is VideoItem {
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
        let headerView =
            collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "MediaCollectionViewHeader",
                for: indexPath
            ) as! MediaCollectionViewHeader

        let monthDelta = Array(cachedDataSource.keys).sorted()[indexPath.section]
        var sectionDateString: String

        if let sectionMonthAndYear = Calendar.current.date(byAdding: .month, value: 0 - monthDelta, to: Date()) {
            switch monthDelta {
            case 0:
                sectionDateString = "This Month"

            case let monthDelta where monthDelta < 12:
                sectionDateString = MediaViewController.monthFormatter.string(from: sectionMonthAndYear)

            default:
                sectionDateString = MediaViewController.monthAndYearFormatter.string(from: sectionMonthAndYear)
            }
            headerView.configureView(text: sectionDateString)
        }

        return headerView
    }

}

extension MediaViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if containerInputOutput.isSelectionAllowed() {
            containerInputOutput.didSetItemAs(isSelected: true, at: indexPath)
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            containerInputOutput.setItemAsCurrent(
                at: presentationIndexPath(for: indexPath),
                withTypes: containerInputOutput.currentlySupportedTypes()
            )
            containerInputOutput.switchTo(presentation: .carousel)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        containerInputOutput.didSetItemAs(isSelected: false, at: indexPath)
    }

}

