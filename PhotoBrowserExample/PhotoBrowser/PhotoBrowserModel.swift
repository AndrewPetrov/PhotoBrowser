//
//  PhotoBrowserModel.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/19/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation


//relations to someone who has created browser
protocol PhotoBrowserDelegate: class {

    func setItemAs(at indexPaths: [IndexPath], isLiked: Bool)
    func deleteItems(at indexPaths: [IndexPath])
    func scrollToMessage(at indexPath: IndexPath)
    func saveItem(at indexPaths: [IndexPath])
    func forwardItem(at indexPaths: [IndexPath])
    func shareItem(at indexPaths: [IndexPath])
    func setAsMyProfilePhoto(indexPath: IndexPath)

}

protocol PhotoBrowserDataSouce: class {

    func startingItemIndexPath() -> IndexPath
    func items(for indexPaths: [IndexPath]) -> [Item]
    func itemsCount() -> Int
    func senderName() -> String

}

typealias ModelInputOutput = ModelInput & ModelOutput

//relations to browser
protocol ModelInput: class {

    func setItemAs(withTypes types: ItemTypes, isLiked: Bool, at indexPaths: [IndexPath])
    func deleteItems(withTypes types: ItemTypes, indexPaths: [IndexPath])
    func saveItem(withTypes types: ItemTypes, indexPaths: [IndexPath])
    func forwardItem(withTypes types: ItemTypes, indexPaths: [IndexPath])
    func shareItem(withTypes types: ItemTypes, indexPaths: [IndexPath])
    func setAsMyProfilePhoto(withTypes types: ItemTypes, indexPath: IndexPath)
    func scrollToMessage(at indexPath: IndexPath)

}

protocol ModelOutput: class {

    func numberOfItems(withTypes types: ItemTypes) -> Int
    func item(withTypes types: ItemTypes, at indexPath: IndexPath) -> Item?
    func indexPath(for item: Item, withTypes types: ItemTypes) -> IndexPath
    func intersectionOfBrowserOutputTypes(inputTypes: ItemTypes) -> ItemTypes
    func isItemLiked(withTypes types: ItemTypes, at indexPath: IndexPath) -> Bool
    func senderName() -> String
    func startingItemIndexPath(withTypes types: ItemTypes) -> IndexPath
    func transform(indexPath: IndexPath, fromTypes: ItemTypes, toTypes: ItemTypes) -> IndexPath
    func allowedActions() -> AllowedActions

}

class PhotoBrowserModel {

    private weak var dataSource: PhotoBrowserDataSouce!
    private weak var delegate: PhotoBrowserDelegate!

    lazy var cachedItems = [Item]()
    private var itemsCacheByTypes = [ItemTypes: [Item]]()
    private var cachedTypes: ItemTypes?

    static func make(dataSource: PhotoBrowserDataSouce, delegate: PhotoBrowserDelegate) -> PhotoBrowserModel {
        let model = PhotoBrowserModel()
        model.dataSource = dataSource
        model.delegate = delegate
        model.updateCache()

        return model
    }

    private func cacheFirstPortion() {
        let minCount = 20
        let startIndex = max(0, dataSource.startingItemIndexPath().row - minCount / 2)
        let finishIndex = min(startIndex + minCount, dataSource.itemsCount() - 1)



        for index in startIndex...finishIndex {
            if let item = dataSource.items(for: [IndexPath(item: index, section: 0)]).first {
                cachedItems[index] = item
            }
        }
    }

    private func updateCache() {
        var indexPaths = [IndexPath]()
        for index in 0..<dataSource.itemsCount() {
            indexPaths.append(IndexPath(item: index, section: 0))
        }
        cachedItems = dataSource.items(for: indexPaths)
        itemsCacheByTypes = [ItemTypes: [Item]]()
    }

    deinit {
        ImageCache.shared.cleanCache()
        print("browser deinit")
    }

    private func filteredItems(withTypes types: ItemTypes) -> [Item] {
        if let items = itemsCacheByTypes[types] {
            return items
        } else {
            let filteredItems = cachedItems.filter { types.contains($0.type) }

            itemsCacheByTypes[types] = filteredItems
            return filteredItems
        }
    }

    // types is necessary for calculation unfiltred index path in all Items
    private func dataSourceIndexPaths(for typedIndexPaths: [IndexPath], withTypes types: ItemTypes) -> [IndexPath] {
        var dataSourceIndexPaths = [IndexPath]()
        var filteredItemsArray = filteredItems(withTypes: types)

        for typedIndexPath in typedIndexPaths {
            let targetItem = filteredItemsArray[typedIndexPath.row]
            if let dataSourceIndexPathRow = cachedItems.index(of: targetItem),
                dataSourceIndexPathRow >= cachedItems.startIndex,
                dataSourceIndexPathRow <= cachedItems.endIndex {
                dataSourceIndexPaths.append(IndexPath(row: dataSourceIndexPathRow, section: 0))
            }
        }
        return dataSourceIndexPaths
    }

}

extension PhotoBrowserModel: ModelInput {

    func setItemAs(withTypes types: ItemTypes, isLiked: Bool, at indexPaths: [IndexPath]) {
        let indexPaths = dataSourceIndexPaths(for: indexPaths, withTypes: types)
        delegate.setItemAs(at: indexPaths, isLiked: isLiked)
        updateCache()
    }

    func deleteItems(withTypes types: ItemTypes, indexPaths: [IndexPath]) {
        let indexPaths = dataSourceIndexPaths(for: indexPaths, withTypes: types).sorted()
        delegate.deleteItems(at: indexPaths)
        updateCache()
    }

    func saveItem(withTypes types: ItemTypes, indexPaths: [IndexPath]) {
        let indexPaths = dataSourceIndexPaths(for: indexPaths, withTypes: types)
        delegate.saveItem(at: indexPaths)
    }

    func forwardItem(withTypes types: ItemTypes, indexPaths: [IndexPath]) {
        let indexPaths = dataSourceIndexPaths(for: indexPaths, withTypes: types)
        delegate.forwardItem(at: indexPaths)
    }

    func shareItem(withTypes types: ItemTypes, indexPaths: [IndexPath]) {
        let indexPaths = dataSourceIndexPaths(for: indexPaths, withTypes: types)
        delegate.shareItem(at: indexPaths)
    }

    func setAsMyProfilePhoto(withTypes types: ItemTypes, indexPath: IndexPath) {
        if let indexPath = dataSourceIndexPaths(for: [indexPath], withTypes: types).first {
            delegate.setAsMyProfilePhoto(indexPath: indexPath)
        }
    }

    func scrollToMessage(at indexPath: IndexPath) {
        delegate.scrollToMessage(at: indexPath)
    }
}

extension PhotoBrowserModel: ModelOutput {

    func transform(indexPath: IndexPath, fromTypes: ItemTypes, toTypes: ItemTypes) -> IndexPath {
        if let realIndexPath = dataSourceIndexPaths(for: [indexPath], withTypes: fromTypes).first,
            realIndexPath.row >= 0, realIndexPath.row <= cachedItems.endIndex {

            let realItem = cachedItems[realIndexPath.row]
            if let targetIndexPathRow = filteredItems(withTypes: toTypes).index(of: realItem) {
                return IndexPath(row: targetIndexPathRow, section: 0)
            }
        }
        return IndexPath()
    }

    func startingItemIndexPath(withTypes types: ItemTypes) -> IndexPath {
        if let startingItem = dataSource.items(for: [dataSource.startingItemIndexPath()]).first,
            let filteredIndex = filteredItems(withTypes: types).index(of: startingItem) {
            
            return IndexPath(item: filteredIndex, section: 0)
        }
        return IndexPath(item: 0, section: 0)
    }

    func numberOfItems(withTypes types: ItemTypes) -> Int {
        return filteredItems(withTypes: types).count

    }

    func item(withTypes types: ItemTypes, at indexPath: IndexPath) -> Item? {
        if indexPath.row < filteredItems(withTypes: types).count {
            return filteredItems(withTypes: types)[indexPath.row]
        }
        return nil
    }


    func indexPath(for item: Item, withTypes types: ItemTypes) -> IndexPath {
        return IndexPath(row: filteredItems(withTypes: types).index(of: item) ?? 0, section: 0)
    }

    func intersectionOfBrowserOutputTypes(inputTypes: ItemTypes) -> ItemTypes {
        var dataSourceItemTypes = ItemTypes()
        _ = cachedItems.map { dataSourceItemTypes.insert($0.type) }
        return dataSourceItemTypes.intersection(inputTypes)
    }

    func isItemLiked(withTypes types: ItemTypes, at indexPath: IndexPath) -> Bool {

        if indexPath.row < filteredItems(withTypes: types).count {
            return filteredItems(withTypes: types)[indexPath.row].isLiked
        }
        return false
    }

    func senderName() -> String {
        return dataSource?.senderName() ?? ""
    }

    func allowedActions() -> AllowedActions {
        return AllowedActions.onlyShare
    }
}

