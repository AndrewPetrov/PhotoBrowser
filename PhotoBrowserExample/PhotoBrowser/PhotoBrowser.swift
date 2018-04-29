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

}

typealias PresentationViewController = Presentatable & PhotoBrowserInternalDelegate & UIViewController

protocol Presentatable where Self: UIViewController {

    var presentation: Presentation { get }

}

class PhotoBrowser: UIViewController {

    private var modelInputOutput: ModelInputOutput!
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

    private var currentPresentation: Presentation
    private var previousPresentation: Presentation?

    private var isVideoAutoplayEnabled = true

    init(modelInputOutput: ModelInputOutput, presentation: Presentation) {
        self.modelInputOutput = modelInputOutput
        self.currentPresentation = presentation

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var carouselViewController = CarouselViewController.make(modelInputOutput: modelInputOutput, presentationInputOutput: self)
    private lazy var containerViewController = ContainerViewController.make (modelInputOutput: modelInputOutput, presentationInputOutput: self)
    private lazy var tableViewController = TableViewController.make(modelInputOutput: modelInputOutput, presentationInputOutput: self)

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

        delegate = currentPresentationViewController as PhotoBrowserInternalDelegate
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
        modelInputOutput.scrollToMessage(at: messageindexPath)
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
        previousPresentation = currentPresentation
        currentPresentation = presentation
        //check If presentation supports current Item type
        if let targetSupportedTypes = getViewController(by: presentation)?.getSupportedTypes(),
            let currentItemType = modelInputOutput.item(withTypes: currentItemIndexPathWithTypes.types, at: currentItemIndexPathWithTypes.indexPath)?.type {
            if targetSupportedTypes.contains(currentItemType) {
                switchToCurrentPresentation()
            } else {
                if let previousPresentation = previousPresentation {
                    currentPresentation = previousPresentation
                }
            }
        }
    }

}

