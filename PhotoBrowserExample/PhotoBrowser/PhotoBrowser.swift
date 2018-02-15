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
    func setItemAs(withTypes types: [ItemType], isLiked: Bool, at indexPath: IndexPath)
    func deleteItems(withTypes types: [ItemType], indexPathes: Set<IndexPath>)
    func scrollToMessage(at indexPath: IndexPath)
    func saveItem(withTypes types: [ItemType], indexPathes: Set<IndexPath>)
    func forwardItem(withTypes types: [ItemType], indexPathes: Set<IndexPath>)
    func shareItem(withTypes types: [ItemType], indexPathes: Set<IndexPath>)
    func setAsMyProfilePhoto(withTypes types: [ItemType], indexPath: IndexPath)

}

//relations with someone who has created browser
protocol PhotoBrowserDataSouce: class {

    func startingItemIndexPath() -> IndexPath
    func item(at indexPath: IndexPath) -> Item?
    func numberOfItems(withTypes types: [ItemType]) -> Int
    func item(withTypes types: [ItemType], at indexPath: IndexPath) -> Item?
    func senderName() -> String
    func typesOfItems() -> [ItemType]

}

//relations with presentations
protocol PhotoBrowserInternalDelegate: class {

    func currentItemIndexDidChange()

}

typealias PresentationInputOutput = PresentationInput & PresentationOutput

protocol PresentationInput: class {

    func currentItemIndex() -> IndexPath
    func isItemLiked(withTypes types: [ItemType], at indexPath: IndexPath) -> Bool
    func numberOfItems(withType types: [ItemType]) -> Int
    func item(withType types: [ItemType], at indexPath: IndexPath) -> Item?
    func senderName() -> String
    //in example gallery gives 3 types, but this Presentation can take only 2 types, result will be logical AND
    func intersectionOfBrowserOutputTypes(inputTypes: [ItemType]) -> [ItemType]

}

protocol PresentationOutput: class {

    func setItemAsCurrent(at indexPath: IndexPath)
    func setItemAs(withTypes types: [ItemType], isLiked: Bool, at indexPath: IndexPath)
    func deleteItems(withTypes types: [ItemType], indexPathes: Set<IndexPath>)
    func switchTo(presentation: Presentation)
    func goToMessage(with indexPath: IndexPath)
    func saveItem(withTypes types: [ItemType], indexPathes: Set<IndexPath>)
    func forwardItem(withTypes types: [ItemType], indexPathes: Set<IndexPath>)
    func shareItem(withTypes types: [ItemType], indexPathes: Set<IndexPath>)
    func setAsMyProfilePhoto(withTypes types: [ItemType], indexPath: IndexPath)

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
    private var currentItemIndexPath: IndexPath

    init(dataSource: PhotoBrowserDataSouce?,
         delegate: PhotoBrowserDelegate?,
         presentation: Presentation,
         starIndex: IndexPath = IndexPath(row: 0, section: 0)) {

        self.dataSource = dataSource
        self.externalDelegate = delegate
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

        // variant without animation
        if childViewControllers.count != 0 {
            removeChildViewControllers()
        }

        add(asChildViewController: currentPresentationViewController)
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

    func intersectionOfBrowserOutputTypes( inputTypes: [ItemType]) -> [ItemType] {
        if let ouputTypes = dataSource?.typesOfItems() {
            let ouputTypesSet: Set<ItemType> = Set(ouputTypes)
            let inputTypesSet: Set<ItemType> = Set(inputTypes)
            return Array(ouputTypesSet.intersection(inputTypesSet))
        }

        return [ItemType]()
    }

    func isItemLiked(withTypes types: [ItemType], at indexPath: IndexPath) -> Bool {
        if let item = dataSource?.item(at: indexPath) as? Likable {
            return item.isLiked
        }
        return false
    }

    func senderName() -> String {
        return dataSource?.senderName() ?? ""
    }

    func item(withType types: [ItemType], at indexPath: IndexPath) -> Item? {
        return dataSource?.item(withTypes: types, at: indexPath)
    }

    func numberOfItems(withType types: [ItemType]) -> Int {
        return dataSource?.numberOfItems(withTypes: types) ?? 0
    }


    func currentItemIndex() -> IndexPath {
        return currentItemIndexPath
    }

}

extension PhotoBrowser: PresentationOutput {
    func saveItem(withTypes types: [ItemType], indexPathes: Set<IndexPath>) {
        externalDelegate?.saveItem(withTypes: types, indexPathes: indexPathes)
    }

    func forwardItem(withTypes types: [ItemType], indexPathes: Set<IndexPath>) {
        externalDelegate?.forwardItem(withTypes: types, indexPathes: indexPathes)
    }

    func shareItem(withTypes types: [ItemType], indexPathes: Set<IndexPath>) {
        externalDelegate?.shareItem(withTypes: types, indexPathes: indexPathes)
    }

    func setAsMyProfilePhoto(withTypes types: [ItemType], indexPath: IndexPath) {
        externalDelegate?.setAsMyProfilePhoto(withTypes: types, indexPath: indexPath)
    }

    func setItemAs(withTypes types: [ItemType], isLiked: Bool, at indexPath: IndexPath) {
        print("like = ", isLiked,  indexPath)
        externalDelegate?.setItemAs(withTypes: types, isLiked: isLiked, at: indexPath)
    }

    func goToMessage(with indexPath: IndexPath) {
        openChat(on: indexPath)
    }

    func switchTo(presentation: Presentation) {
        previousPresentation = currentPresentation
        currentPresentation = presentation
        switchToCurrentPresentation()
    }

    func deleteItems(withTypes types: [ItemType], indexPathes: Set<IndexPath>) {
        externalDelegate?.deleteItems(withTypes: types, indexPathes: indexPathes)
    }

    func setItemAsCurrent(at indexPath: IndexPath) {
        if currentItemIndexPath != indexPath {
            currentItemIndexPath = indexPath
            internalDelegate?.currentItemIndexDidChange()
        }
    }

}

