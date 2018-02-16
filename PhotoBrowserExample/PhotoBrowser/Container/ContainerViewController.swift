//
//  ContainerViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/11/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

enum ContainerItemType: Int {
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
    func currentlySupportedTypes() -> [ItemType]
}

protocol ContainerViewControllerDelegate {
    func reloadUI()
    func setItem(at indexPath: IndexPath, slected: Bool)
}

class ContainerViewController: SelectableViewController, Presentatable {

    let presentation: Presentation = .container

    private var mediaTypesSegmentedControl: UISegmentedControl!

    var forwardButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(forwardButtonDidTap))

    @IBOutlet private weak var toolbar: UIToolbar!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var toolbarBottomConstraint: NSLayoutConstraint!

    private let uiBarButtonImageSize = CGSize(width: 25, height: 25)
    private lazy var likedYesSizedImage = UIImageHelper.imageWithImage(image: #imageLiteral(resourceName: "likedYes"), scaledToSize: uiBarButtonImageSize)
    private lazy var likedNoSizedImage = UIImageHelper.imageWithImage(image: #imageLiteral(resourceName: "likeNo"), scaledToSize: uiBarButtonImageSize)

    private var delegate: ContainerViewControllerDelegate?

    // MARK: - Life cycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        add(asChildViewController: mediaViewController)
        createBarButtonItems()
        setupToolbar()
        updateToolbarButtons()
        updateToolbarPosition()
    }

    private lazy var mediaViewController = MediaViewController.make(presentationInputOutput: presentationInputOutput, containerInputOutput: self)
    private lazy var linksViewController = LinksViewController.make(presentationInputOutput: presentationInputOutput, containerInputOutput: self)
    private lazy var docsViewController = DocsViewController.make(presentationInputOutput: presentationInputOutput, containerInputOutput: self)

    private func add(asChildViewController viewController: UIViewController & ContainerViewControllerDelegate) {
        delegate = viewController
        addChildViewController(viewController)

        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }

    private func removeChildViewControllers() {
        for childViewController in childViewControllers {
            childViewController.willMove(toParentViewController: nil)
            childViewController.view.removeFromSuperview()
            childViewController.removeFromParentViewController()
        }
    }

    override func removeFromParentViewController() {
        clearNavigationBar()

        super.removeFromParentViewController()
    }

    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)

        setupNavigationBar()
    }

    static func make(presentationInputOutput: PresentationInputOutput) -> ContainerViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContainerViewController") as! ContainerViewController
        newViewController.presentationInputOutput = presentationInputOutput

        return newViewController
    }

    // MARK: - Setup controls

    private func createBarButtonItems() {
        trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashButtonDidTap))
        actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionButtonDidTap))
    }

    private func setupToolbar() {
        guard let type = ContainerItemType(rawValue: mediaTypesSegmentedControl.selectedSegmentIndex) else { return }

        switch type {
        case .media:
            toolbar.items = [actionButton, flexibleSpace, trashButton]

        case .links, .docs:
            updateToolbarButtons()
        }
    }

    private func setupNavigationBar() {
        mediaTypesSegmentedControl = UISegmentedControl(items: [
            ContainerItemType.media.title,
            ContainerItemType.links.title,
            ContainerItemType.docs.title
            ])

        mediaTypesSegmentedControl.selectedSegmentIndex = 0;
        mediaTypesSegmentedControl.addTarget(self, action: #selector(mediaTypeDidChange(_:)), for: .valueChanged)
        parent?.navigationItem.titleView = mediaTypesSegmentedControl
        parent?.navigationItem.titleView?.alpha = 0
        UIView.animate(withDuration: 0.1,
                       animations: { [weak self] in
                        self?.parent?.navigationItem.titleView?.alpha = 1
        })

        selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(toggleSelection))
        parent?.navigationItem.rightBarButtonItem = selectButton

        selectAllButton = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(toggleSelectAll))
    }

    // MARK: - Update controls

    internal override func reloadUI() {
        delegate?.reloadUI()
    }

    internal override func updateToolbarButtons() {
        let sizedImage = isAllItemsLiked() ? likedYesSizedImage : likedNoSizedImage
        let likeButton = UIBarButtonItem(image: sizedImage, style: .plain, target: self, action: #selector(likeButtonDidTap(_:)))

        actionButton.isEnabled = selectedIndexPathes.count != 0
        trashButton.isEnabled = selectedIndexPathes.count != 0
        likeButton.isEnabled = selectedIndexPathes.count != 0
        forwardButton.isEnabled = selectedIndexPathes.count != 0

        toolbar.items = [forwardButton, flexibleSpace, likeButton, flexibleSpace, actionButton, flexibleSpace, trashButton]
    }

    internal override func setItem(at indexPath: IndexPath, slected: Bool) {
        delegate?.setItem(at: indexPath, slected: slected)
    }

    private func clearNavigationBar() {
        UIView.animate(withDuration: 0.1,
                       animations: { [weak self] in
                        self?.parent?.navigationItem.titleView?.alpha = 0
        }) { [weak self] _ in
            self?.parent?.navigationItem.titleView = nil
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

    internal override func updateNavigationBar() {
        parent?.navigationItem.leftBarButtonItem = isSelectionAllowed ? selectAllButton : nil
        parent?.navigationItem.hidesBackButton = isSelectionAllowed
    }

    @objc func mediaTypeDidChange(_ sender: UISegmentedControl) {
        removeChildViewControllers()
        isSelectionAllowed = false
        delegate?.reloadUI()
        guard let type = ContainerItemType(rawValue: sender.selectedSegmentIndex) else { return }
        switch type {
        case .media:
            supportedTypes = [.image, .video]
            add(asChildViewController: mediaViewController)
        case .links:
            supportedTypes = [.link]
            add(asChildViewController: linksViewController)
        case .docs:
            supportedTypes = [.document]
            add(asChildViewController: docsViewController)
        }
        setupToolbar()
    }

    @objc private func likeButtonDidTap(_ sender: Any) {
        presentationInputOutput.setItemAs(withTypes: supportedTypes, isLiked: !isAllItemsLiked(), at: Array(selectedIndexPathes()).sorted())
        selectedIndexPathes.removeAll()
        isSelectionAllowed = false
        delegate?.reloadUI()
    }

    @objc private func actionButtonDidTap(_ sender: Any) {
        presentationInputOutput.shareItem(withTypes: supportedTypes, indexPathes: Array(selectedIndexPathes()).sorted())
        selectedIndexPathes.removeAll()
        isSelectionAllowed = false
        delegate?.reloadUI()
    }

    @objc private func forwardButtonDidTap(_ sender: Any) {
        presentationInputOutput.forwardItem(withTypes: supportedTypes, indexPathes: Array(selectedIndexPathes()).sorted())
        selectedIndexPathes.removeAll()
        isSelectionAllowed = false
        delegate?.reloadUI()
    }

}

extension ContainerViewController: ContainerViewControllerImput {

    func didSetItemAs(isSelected: Bool, at indexPath: IndexPath) {
        if isSelected {
            selectedIndexPathes.insert(indexPath)
        } else {
            selectedIndexPathes.remove(indexPath)
        }
    }

}

extension ContainerViewController: ContainerViewControllerOutput {

    func currentlySupportedTypes() -> [ItemType] {
        return supportedTypes
    }

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




