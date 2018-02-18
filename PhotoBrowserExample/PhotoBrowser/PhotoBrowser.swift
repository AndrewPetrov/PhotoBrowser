//
//  PhotoBrowser.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit


//relations with someone who has created browser
protocol PhotoBrowserDelegate: class {

    // types is necessary for calculation unfiltred index path in all Items
    func setItemAs(withTypes types: ItemTypes, isLiked: Bool, at indexPaths: [IndexPath])
    func deleteItems(withTypes types: ItemTypes, indexPaths: [IndexPath])
    func scrollToMessage(at indexPath: IndexPath)
    func saveItem(withTypes types: ItemTypes, indexPaths: [IndexPath])
    func forwardItem(withTypes types: ItemTypes, indexPaths: [IndexPath])
    func shareItem(withTypes types: ItemTypes, indexPaths: [IndexPath])
    func setAsMyProfilePhoto(withTypes types: ItemTypes, indexPath: IndexPath)

}

//relations with someone who has created browser
protocol PhotoBrowserDataSouce: class {

    func startingItemIndexPath() -> IndexPath
    func item(at indexPath: IndexPath) -> Item?
    func numberOfItems(withTypes types: ItemTypes) -> Int
    func item(withTypes types: ItemTypes, at indexPath: IndexPath) -> Item?
    func senderName() -> String
    func typesOfItems() -> ItemTypes
    func indexPath(for item: Item, types: ItemTypes) -> IndexPath

}

//relations with presentations
protocol PhotoBrowserInternalDelegate: class {

    func currentItemIndexDidChange()

}

typealias PresentationInputOutput = PresentationInput & PresentationOutput

protocol PresentationInput: class {

    func currentItemIndex() -> IndexPath
    func isItemLiked(withTypes types: ItemTypes, at indexPath: IndexPath) -> Bool
    func countOfItems(withType types: ItemTypes) -> Int
    func item(withType types: ItemTypes, at indexPath: IndexPath) -> Item?
    func senderName() -> String
    func indexPath(for item: Item, withTypes types: ItemTypes) -> IndexPath
    //in example gallery gives 3 types, but this Presentation can take only 2 types, result will be logical AND
    func intersectionOfBrowserOutputTypes(inputTypes: ItemTypes) -> ItemTypes

}

protocol PresentationOutput: class {

    func setItemAsCurrent(at indexPath: IndexPath)
    func setItemAs(withTypes types: ItemTypes, isLiked: Bool, at indexPaths: [IndexPath])
    func deleteItems(withTypes types: ItemTypes, indexPaths: [IndexPath])
    func switchTo(presentation: Presentation)
    func goToMessage(with indexPath: IndexPath)
    func saveItem(withTypes types: ItemTypes, indexPaths: [IndexPath])
    func forwardItem(withTypes types: ItemTypes, indexPaths: [IndexPath])
    func shareItem(withTypes types: ItemTypes, indexPaths: [IndexPath])
    func setAsMyProfilePhoto(withTypes types: ItemTypes, indexPath: IndexPath)

}

enum Presentation {

    case carousel
    case container
    case table

}

typealias PresentationViewController = Presentatable & PhotoBrowserInternalDelegate & UIViewController

protocol Presentatable where Self: UIViewController {

    var presentation: Presentation { get }

}

class PhotoBrowser: UIViewController {

    private weak var externalDelegate: PhotoBrowserDelegate?
    private weak var internalDelegate: PhotoBrowserInternalDelegate?
    private weak var dataSource: PhotoBrowserDataSouce?
    private var currentPresentation: Presentation
    //for transitions to the same item
    private var previousPresentation: Presentation?
    lazy private var currentItemIndexPath: IndexPath = dataSource?.startingItemIndexPath() ?? IndexPath(item: 0, section: 0)

    init(dataSource: PhotoBrowserDataSouce?,
         delegate: PhotoBrowserDelegate?,
         presentation: Presentation
        ) {

        self.dataSource = dataSource
        self.externalDelegate = delegate
        self.currentPresentation = presentation

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        ImageCache.shared.cleanCache()
        print(">>>browser deinit")
    }

    private lazy var carouselViewController = CarouselViewController.make(presentationInputOutput: self)
    private lazy var containerViewController = ContainerViewController.make (presentationInputOutput: self)
    private lazy var tableViewController = TableViewController.make(presentationInputOutput: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        switchToCurrentPresentation()
    }

    private func getViewController(by presentation: Presentation) -> PresentationViewController? {

        let presentationViewControllers: [PresentationViewController] = [carouselViewController, containerViewController, tableViewController]
        return presentationViewControllers.filter { $0.presentation == presentation }.first
    }

    func switchToCurrentPresentation() {
        guard let currentPresentationViewController = getViewController(by: currentPresentation) else { return }
        internalDelegate = currentPresentationViewController
        if let previousPresentation = previousPresentation, let previousPresentationViewController = getViewController(by: previousPresentation) {
            previousPresentationViewController.willMove(toParentViewController: nil)
            addChildViewController(currentPresentationViewController)

            previousPresentationViewController.view.alpha = 1
            currentPresentationViewController.view.alpha = 0
            transition(
                from: previousPresentationViewController,
                to: currentPresentationViewController,
                duration: 0.33,
                options: .curveEaseInOut,
                animations: {
                    previousPresentationViewController.view.alpha = 0
                    currentPresentationViewController.view.alpha = 1
            }, completion: { _ in
                previousPresentationViewController.removeFromParentViewController()
                currentPresentationViewController.didMove(toParentViewController: self)
            })

        } else {
            add(asChildViewController: currentPresentationViewController)
        }

        return
    }

    private func add(asChildViewController viewController: UIViewController) {

        addChildViewController(viewController)
        view.addSubview(viewController.view)

        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
    }

    private func removeChildViewControllers() {
        for childViewController in childViewControllers {
            childViewController.willMove(toParentViewController: nil)
            childViewController.view.removeFromSuperview()
            childViewController.removeFromParentViewController()
        }
    }

    private func openChat(on messageindexPath: IndexPath) {
        navigationController?.popToRootViewController(animated: false)
        externalDelegate?.scrollToMessage(at: messageindexPath)
    }

}

extension PhotoBrowser: PresentationInput {

    func indexPath(for item: Item, withTypes types: ItemTypes) -> IndexPath {
        return dataSource?.indexPath(for:item, types: types) ?? IndexPath()
    }

    func intersectionOfBrowserOutputTypes(inputTypes: ItemTypes) -> ItemTypes {
        if let ouputTypes = dataSource?.typesOfItems() {
            return ouputTypes.intersection(inputTypes)
        }

        return ItemTypes()
    }

    func isItemLiked(withTypes types: ItemTypes, at indexPath: IndexPath) -> Bool {
        if let item = dataSource?.item(withTypes: types, at: indexPath) {
            return item.isLiked
        }
        return false
    }

    func senderName() -> String {
        return dataSource?.senderName() ?? ""
    }

    func item(withType types: ItemTypes, at indexPath: IndexPath) -> Item? {
        return dataSource?.item(withTypes: types, at: indexPath)
    }

    func countOfItems(withType types: ItemTypes) -> Int {
        return dataSource?.numberOfItems(withTypes: types) ?? 0
    }


    func currentItemIndex() -> IndexPath {
        return currentItemIndexPath
    }

}

extension PhotoBrowser: PresentationOutput {

    func saveItem(withTypes types: ItemTypes, indexPaths: [IndexPath]) {
        externalDelegate?.saveItem(withTypes: types, indexPaths: indexPaths)
    }

    func forwardItem(withTypes types: ItemTypes, indexPaths: [IndexPath]) {
        externalDelegate?.forwardItem(withTypes: types, indexPaths: indexPaths)
    }

    func shareItem(withTypes types: ItemTypes, indexPaths: [IndexPath]) {
        externalDelegate?.shareItem(withTypes: types, indexPaths: indexPaths)
    }

    func setAsMyProfilePhoto(withTypes types: ItemTypes, indexPath: IndexPath) {
        externalDelegate?.setAsMyProfilePhoto(withTypes: types, indexPath: indexPath)
    }

    func setItemAs(withTypes types: ItemTypes, isLiked: Bool, at indexPaths: [IndexPath]) {
        externalDelegate?.setItemAs(withTypes: types, isLiked: isLiked, at: indexPaths)
    }

    func goToMessage(with indexPath: IndexPath) {
        openChat(on: indexPath)
    }

    func switchTo(presentation: Presentation) {
        previousPresentation = currentPresentation
        currentPresentation = presentation
        switchToCurrentPresentation()
    }

    func deleteItems(withTypes types: ItemTypes, indexPaths: [IndexPath]) {
        externalDelegate?.deleteItems(withTypes: types, indexPaths: indexPaths)
    }

    func setItemAsCurrent(at indexPath: IndexPath) {
        if currentItemIndexPath != indexPath {
            currentItemIndexPath = indexPath
            internalDelegate?.currentItemIndexDidChange()
        }
    }

}

