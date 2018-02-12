//
//  ContainerViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/11/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

enum ContainerItemTypes: Int {
    case media
    case links
    case docs

    var title: String {
        switch self {
        case .media:
            return "Media"
        case .links:
            return "Links"
        case .docs:
            return "Docs"
        }
    }
}

class ContainerViewController: SelectableViewController {

//    private var selectButton: UIBarButtonItem!
//    private var selectAllButton: UIBarButtonItem!

    private var mediaTypesSegmentedControl: UISegmentedControl!

    var likeButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(trashButtonDidTap))
    var actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(trashButtonDidTap))
    var shareButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(trashButtonDidTap))
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    @IBOutlet private weak var toolbar: UIToolbar!
    @IBOutlet private weak var containerView: UIView!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private lazy var mediaViewController = MediaViewController.make(presentationInputOutput: presentationInputOutput)
    private lazy var linksViewController = LinksViewController.make(presentationInputOutput: presentationInputOutput)
    private lazy var docsViewController = DocsViewController.make(presentationInputOutput: presentationInputOutput)

    private func add(asChildViewController viewController: UIViewController) {
        addChildViewController(viewController)
        containerView.addSubview(viewController.view)

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

    static func make(presentationInputOutput: PresentationInputOutput) -> ContainerViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContainerViewController") as! ContainerViewController
        newViewController.presentationInputOutput = presentationInputOutput

        return newViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        add(asChildViewController: mediaViewController)
        createBarButtonItems()
        setupToolbar()
    }

    private func createBarButtonItems() {
        trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashButtonDidTap))
    }

    override func setupToolbar() {



        guard let type = ContainerItemTypes(rawValue: mediaTypesSegmentedControl.selectedSegmentIndex) else { return }

        switch type {
        case .media:
            toolbar.items = [actionButton, flexibleSpace, trashButton]

        case .links, .docs:
            toolbar.items = [shareButton, flexibleSpace, likeButton, flexibleSpace, actionButton, flexibleSpace, trashButton]
        }

    }

    internal override func updateToolbar() {

    }

    internal override func setupNavigationBar() {
        mediaTypesSegmentedControl = UISegmentedControl(items: [
            ContainerItemTypes.media.title,
            ContainerItemTypes.links.title,
            ContainerItemTypes.docs.title
            ])

        mediaTypesSegmentedControl.selectedSegmentIndex = 0;
        mediaTypesSegmentedControl.addTarget(self, action: #selector(mediaTypeDidChange(_:)), for: .valueChanged)
        navigationItem.titleView = mediaTypesSegmentedControl

        selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(toggleSelection))
        navigationItem.rightBarButtonItem = selectButton

        selectAllButton = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(toggleSelectAll))
        navigationItem.leftBarButtonItem = isSelectionAllowed ? selectAllButton : nil
        navigationItem.hidesBackButton = isSelectionAllowed
    }

    @objc func mediaTypeDidChange(_ sender: UISegmentedControl) {
        removeChildViewControllers()
        guard let type = ContainerItemTypes(rawValue: sender.selectedSegmentIndex) else { return }
        switch type {
        case .media:
            add(asChildViewController: mediaViewController)
        case .links:
            add(asChildViewController: linksViewController)
        case .docs:
            add(asChildViewController: docsViewController)
        }
        setupToolbar()
    }

}
