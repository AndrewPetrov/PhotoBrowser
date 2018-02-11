//
//  PhotoBrowser.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoBrowserDelegate: class {

    func setItemAs(isLiked: Bool, at indexPath: IndexPath)
    func deleteItems(indexPathes: Set<IndexPath>)

}


protocol PhotoBrowserDataSouce: class {

    func numberOfItems() -> Int
    func startingItemIndexPath() -> IndexPath
    func item(at indexPath: IndexPath) -> Item?
    func numberOfItems(withTypes types: [ItemType]) -> Int
    func item(withTypes types: [ItemType], at indexPath: IndexPath) -> Item?

}

typealias PresentationInputOutput = PresentationInput & PresentationOutput

protocol PresentationInput: AnyObject {

    func currentItemIndex() -> IndexPath
    func isItemLiked(at indexPath: IndexPath) -> Bool
    func numberOfItems() -> Int
    func numberOfItems(withType types: [ItemType]) -> Int
    func item(withType types: [ItemType], at indexPath: IndexPath) -> Item?
    func item(at indexPath: IndexPath) -> Item?
}

protocol PresentationOutput: AnyObject {

    func setItemAsCurrent(at indexPath: IndexPath)
    func setItemAs(isLiked: Bool, at indexPath: IndexPath)
    func deleteItems(indexPathes: Set<IndexPath>)
    func switchTo(presentation: Presentation)

}

enum Presentation {

    case carousel
    case container
    case table

}

class PhotoBrowser: UIViewController {

    private weak var delegate: PhotoBrowserDelegate?
    private weak var dataSource: PhotoBrowserDataSouce?
    private var currentPresentation: Presentation
    //for transitions to the same item
    private var currentItemIndexPath: IndexPath

    init(dataSource: PhotoBrowserDataSouce?,
         delegate: PhotoBrowserDelegate?,
         presentation: Presentation,
         starIndex: IndexPath = IndexPath(row: 0, section: 0)) {

        self.dataSource = dataSource
        self.delegate = delegate
        self.currentPresentation = presentation
        currentItemIndexPath = starIndex

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var carouselViewController = CarouselViewController.make(presentationInputOutput: self)
    private lazy var containerViewController = ContainerViewController.make (presentationInputOutput: self)
    private lazy var tableViewController = TableViewController.make(presentationInputOutput: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        switchToCurrentPresentation()
    }

    func switchToCurrentPresentation() {
        if navigationController?.viewControllers.last != self {
            navigationController?.popViewController(animated: true)
        }
        //TODO: delete 'asyncAfter' when will implement animated transitions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let `self` = self else { return }
            switch self.currentPresentation {
            case .carousel:
                self.navigationController?.pushViewController(self.carouselViewController, animated: true)
            case .container:
                self.navigationController?.pushViewController(self.containerViewController, animated: true)
            case .table:
                self.navigationController?.pushViewController(self.tableViewController, animated: true)
            }
        }
    }

}

extension PhotoBrowser: PresentationInput {

    func item(withType types: [ItemType], at indexPath: IndexPath) -> Item? {
        return dataSource?.item(withTypes: types, at: indexPath)
    }

    func numberOfItems(withType types: [ItemType]) -> Int {
        return dataSource?.numberOfItems(withTypes: types) ?? 0
    }

    func isItemLiked(at indexPath: IndexPath) -> Bool {
        if let item = dataSource?.item(at: indexPath) as? Likable {
            return item.isLiked
        }
        return false
    }


    func currentItemIndex() -> IndexPath {
        return currentItemIndexPath
    }

    func numberOfItems() -> Int {
        return dataSource?.numberOfItems() ?? 0
    }

    func item(at indexPath: IndexPath) -> Item? {
        return dataSource?.item(at: indexPath)
    }

}

extension PhotoBrowser: PresentationOutput {

    func switchTo(presentation: Presentation) {
        self.currentPresentation = presentation
    }

    func setItemAs(isLiked: Bool, at indexPath: IndexPath) {
        print("like = ", isLiked,  indexPath)
        delegate?.setItemAs(isLiked: isLiked, at: indexPath)
    }

    func deleteItems(indexPathes: Set<IndexPath>) {
        print("delete", indexPathes)

    }

    func setItemAsCurrent(at indexPath: IndexPath) {
        currentItemIndexPath = indexPath
        switchToCurrentPresentation()
    }

}
