//
//  PhotoBrowser.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

//action to presentations
protocol PhotoBrowserInternalDelegate: class {

    func currentItemIndexDidChange()

    func getSupportedTypes() -> ItemTypes

}

//action by presentations
typealias PresentationInputOutput = PresentationInput & PresentationOutput & UIViewController

protocol PresentationOutput: class {

    func switchTo(presentation: Presentation)

    func goToMessage(with indexPath: IndexPath)

    func setItemAsCurrent(at indexPath: IndexPath, withTypes types: ItemTypes)

    func setAutoplayVideoEnabled(to enabled: Bool)

}

protocol PresentationInput: class {
    
    func currentItemIndex(withTypes types: ItemTypes) -> IndexPath

    func shouldAutoplayVideo() -> Bool
    
}

enum Presentation {

    case carousel
    case container
    case table
    case single

}

typealias PresentationViewController = Presentable & PhotoBrowserInternalDelegate & UIViewController

protocol Presentable where Self: UIViewController {

    var presentation: Presentation { get }

}

class PhotoBrowser: UIViewController {

    private var modelInputOutput: ModelInputOutput
    private weak var delegate: PhotoBrowserInternalDelegate?

    //for transitions to the same item
    lazy private var currentItemIndexPathWithTypes: (indexPath: IndexPath, types: ItemTypes) = {
        if let currentTypes = delegate?.getSupportedTypes() {
            return (modelInputOutput.startingItemIndexPath(withTypes: currentTypes), currentTypes)
        } else {
            fatalError("PhotoBrowserDelegate == nil")
            return (IndexPath(), [.image])
        }

    }()

    private let presentationStack: Stack<Presentation>

    private var isVideoAutoplayEnabled = true

    init(modelInputOutput: ModelInputOutput, presentation: Presentation) {
        self.modelInputOutput = modelInputOutput
        presentationStack = Stack(presentation)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var carouselViewController = CarouselViewController.make(
        modelInputOutput: modelInputOutput,
        presentationInputOutput: self
    )
    private lazy var containerViewController = ContainerViewController.make(
        modelInputOutput: modelInputOutput,
        presentationInputOutput: self
    )
    private lazy var tableViewController = TableViewController.make(
        modelInputOutput: modelInputOutput,
        presentationInputOutput: self
    )
    private lazy var singleViewController = SingleViewController.make(
        modelInputOutput: modelInputOutput,
        presentationInputOutput: self
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(
            title: "Back",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(back(sender:))
        )
        self.navigationItem.leftBarButtonItem = newBackButton

        switchToCurrentPresentation()
    }

    private func getViewController(by presentation: Presentation) -> PresentationViewController? {

        let presentationViewControllers: [PresentationViewController] = [carouselViewController, containerViewController, tableViewController, singleViewController]
        return presentationViewControllers.filter { $0.presentation == presentation }.first
    }

    func switchToCurrentPresentation() {
        guard let currentPresentation = presentationStack.current,
              let currentPresentationViewController = getViewController(by: currentPresentation) else { return }

        delegate = currentPresentationViewController as PhotoBrowserInternalDelegate
        if let previousPresentation = presentationStack.previous,
           let previousPresentationViewController = getViewController(by: previousPresentation) {
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
        modelInputOutput.scrollToMessage(at: messageindexPath)
    }

    @objc func back(sender: UIBarButtonItem) {
        presentationStack.pop()

        if presentationStack.count == 0 || presentationStack.previous == nil {
            _ = navigationController?.popViewController(animated: true)
        } else {
            switchToCurrentPresentation()
        }
    }

}

extension PhotoBrowser: PresentationInput {

    func shouldAutoplayVideo() -> Bool {
        return isVideoAutoplayEnabled
    }

    func currentItemIndex(withTypes types: ItemTypes) -> IndexPath {
        return modelInputOutput.transform(
            indexPath: currentItemIndexPathWithTypes.indexPath,
            fromTypes: currentItemIndexPathWithTypes.types,
            toTypes: types
        )
    }

}

extension PhotoBrowser: PresentationOutput {

    func setAutoplayVideoEnabled(to enabled: Bool) {
        isVideoAutoplayEnabled = enabled
    }

    func setItemAsCurrent(at indexPath: IndexPath, withTypes types: ItemTypes) {
        if currentItemIndexPathWithTypes.indexPath != indexPath ||
               currentItemIndexPathWithTypes.types != types {
            currentItemIndexPathWithTypes = (indexPath, types)
            delegate?.currentItemIndexDidChange()
        }
    }

    func goToMessage(with indexPath: IndexPath) {
        openChat(on: indexPath)
    }

    func switchTo(presentation: Presentation) {
        presentationStack.push(presentation)
        //check If presentation supports current Item type
        if let targetSupportedTypes = getViewController(by: presentation)?.getSupportedTypes(),
           let currentItemType = modelInputOutput.item(
               withTypes: currentItemIndexPathWithTypes.types,
               at: currentItemIndexPathWithTypes.indexPath
           )?.type {
            if targetSupportedTypes.contains(currentItemType) {
                switchToCurrentPresentation()
            } else {
                _ = presentationStack.pop()
            }
        }
    }

}

class Stack<T> where T: Equatable {

    private var array = [T]()

    private(set) var current: T?
    private(set) var previous: T?

    var count: Int {
        return array.count
    }

    init(_ current: T) {
        array.append(current)
        self.current = current
    }

    func pop() {
        previous = array.last
        if !array.isEmpty {
            array.removeLast()
        }
        current = array.last
    }

    func push(_ new: T) {
        previous = array.last
        array.append(new)
        current = array.last
    }

}
