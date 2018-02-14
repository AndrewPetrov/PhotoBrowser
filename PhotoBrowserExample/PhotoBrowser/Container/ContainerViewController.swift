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

typealias ContainerViewControllerInputOutput = ContainerViewControllerImput & ContainerViewControllerOutput

protocol ContainerViewControllerImput: class {
    func didSetItemAs(isSelected: Bool, at indexPath: IndexPath)
}

protocol ContainerViewControllerOutput: class {
    func isSelectionAllowed() -> Bool
    func selectedIndexPathes() -> Set<IndexPath>
}

protocol ContainerViewControllerDelegate {
    func reloadUI()
}

class ContainerViewController: SelectableViewController, Presentatable {

    let presentation: Presentation = .container

    private var mediaTypesSegmentedControl: UISegmentedControl!

    var likeButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(trashButtonDidTap))
    var actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(trashButtonDidTap))
    var shareButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(trashButtonDidTap))
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    @IBOutlet private weak var toolbar: UIToolbar!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!

    private var delegate: ContainerViewControllerDelegate?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private lazy var mediaViewController = MediaViewController.make(presentationInputOutput: presentationInputOutput, containerInputOutput: self)
    private lazy var linksViewController = LinksViewController.make(presentationInputOutput: presentationInputOutput, containerInputOutput: self)
    private lazy var docsViewController = DocsViewController.make(presentationInputOutput: presentationInputOutput, containerInputOutput: self)

    private func add(asChildViewController viewController: UIViewController & ContainerViewControllerDelegate) {
        delegate = viewController
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
        updateToolbarPosition()
    }

    private func createBarButtonItems() {
        trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashButtonDidTap))
    }

    internal override func reloadUI() {
        delegate?.reloadUI()
    }

    func setupToolbar() {
        guard let type = ContainerItemTypes(rawValue: mediaTypesSegmentedControl.selectedSegmentIndex) else { return }

        switch type {
        case .media:
            toolbar.items = [actionButton, flexibleSpace, trashButton]

        case .links, .docs:
            toolbar.items = [shareButton, flexibleSpace, likeButton, flexibleSpace, actionButton, flexibleSpace, trashButton]
        }
    }

    internal override func updateToolbarPosition() {
        if isSelectionAllowed {
            toolbarBottomConstraint.constant = 0
        } else {
            if let navigationController = parent?.navigationController {
                toolbarBottomConstraint.constant = -(toolbar.frame.height + navigationController.navigationBar.intrinsicContentSize.height)
            }
        }
        UIView.animate(withDuration: 0.33) {
            self.view.layoutIfNeeded()
        }
    }

    internal override func updateSelectionTitle() {
        //do nothing for now
    }

    private func setupNavigationBar() {
        mediaTypesSegmentedControl = UISegmentedControl(items: [
            ContainerItemTypes.media.title,
            ContainerItemTypes.links.title,
            ContainerItemTypes.docs.title
            ])

        mediaTypesSegmentedControl.selectedSegmentIndex = 0;
        mediaTypesSegmentedControl.addTarget(self, action: #selector(mediaTypeDidChange(_:)), for: .valueChanged)
        parent?.navigationItem.titleView = mediaTypesSegmentedControl

        selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(toggleSelection))
        parent?.navigationItem.rightBarButtonItem = selectButton

        selectAllButton = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(toggleSelectAll))
    }

    internal override func updateNavigationBar() {
        parent?.navigationItem.leftBarButtonItem = isSelectionAllowed ? selectAllButton : nil
        parent?.navigationItem.hidesBackButton = isSelectionAllowed
    }

    @objc func mediaTypeDidChange(_ sender: UISegmentedControl) {
        removeChildViewControllers()
        isSelectionAllowed = false
        delegate?.reloadUI()
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

extension ContainerViewController: ContainerViewControllerImput {

    func didSetItemAs(isSelected: Bool, at indexPath: IndexPath) {
        print(indexPath, " ", isSelected)
    }

}

extension ContainerViewController: ContainerViewControllerOutput {

    func isSelectionAllowed() -> Bool {
        return isSelectionAllowed
    }

    func selectedIndexPathes() -> Set<IndexPath> {
        return selectedIndexPathes
    }

}

extension ContainerViewController: PhotoBrowserInternalDelegate {

    func currentItemIndexDidChange() {
        
    }

}




