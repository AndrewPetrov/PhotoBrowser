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
    func scrollToMessage(at indexPath: IndexPath)

}

protocol PhotoBrowserDataSouce: class {

    func numberOfItems() -> Int
    func startingItemIndexPath() -> IndexPath
    func item(at indexPath: IndexPath) -> Item?
    func numberOfItems(withTypes types: [ItemType]) -> Int
    func item(withTypes types: [ItemType], at indexPath: IndexPath) -> Item?

}

typealias PresentationInputOutput = PresentationInput & PresentationOutput

protocol PresentationInput: class {

    func currentItemIndex() -> IndexPath
    func isItemLiked(at indexPath: IndexPath) -> Bool
    func numberOfItems() -> Int
    func numberOfItems(withType types: [ItemType]) -> Int
    func item(withType types: [ItemType], at indexPath: IndexPath) -> Item?
    func item(at indexPath: IndexPath) -> Item?
}

protocol PresentationOutput: class {

    func setItemAsCurrent(at indexPath: IndexPath)
    func setItemAs(isLiked: Bool, at indexPath: IndexPath)
    func deleteItems(indexPathes: Set<IndexPath>)
    func switchTo(presentation: Presentation)
    func goToMessage(with indexPath: IndexPath)

}

enum Presentation {

    case carousel
    case container
    case table

}

protocol PresentationViewController {

    var presentation: Presentation { get }

}

class PhotoBrowser: UIViewController {

    private weak var delegate: PhotoBrowserDelegate?
    private weak var dataSource: PhotoBrowserDataSouce?
    private var currentPresentation: Presentation
    //for transitions to the same item
    private var previousPresentation: Presentation?
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
        navigationController?.delegate = self

        view.backgroundColor = UIColor.white
        switchToCurrentPresentation()
    }

    private func getViewController(by presentation: Presentation) -> PresentationViewController? {

        let presentationViewControllers: [PresentationViewController] = [carouselViewController, containerViewController, tableViewController]
        return presentationViewControllers.filter { $0.presentation == presentation }.first
    }

    func switchToCurrentPresentation() {
        guard let currentPresentationViewController = getViewController(by: currentPresentation) as? UIViewController else { return }
        
        if let viewControllers = navigationController?.viewControllers, viewControllers.contains(currentPresentationViewController) {
            navigationController?.popToViewController(currentPresentationViewController, animated: true)
        } else {
            navigationController?.pushViewController(currentPresentationViewController, animated: true)
        }
    }

    private func openChat(on messageindexPath: IndexPath) {
        navigationController?.popToRootViewController(animated: false)
        delegate?.scrollToMessage(at: messageindexPath)
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

    func goToMessage(with indexPath: IndexPath) {
        openChat(on: indexPath)
    }

    func switchTo(presentation: Presentation) {
        previousPresentation = currentPresentation
        currentPresentation = presentation
        switchToCurrentPresentation()
    }

    func setItemAs(isLiked: Bool, at indexPath: IndexPath) {
        print("like = ", isLiked,  indexPath)
        delegate?.setItemAs(isLiked: isLiked, at: indexPath)
    }

    func deleteItems(indexPathes: Set<IndexPath>) {
        //TODO: consider indexes with Types and indexes at all difference
        print("delete", indexPathes)

    }

    func setItemAsCurrent(at indexPath: IndexPath) {
        currentItemIndexPath = indexPath
    }

}

extension PhotoBrowser: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        if viewController == self, animated == true {
            navigationController.popViewController(animated: false)
        }

    }

}

