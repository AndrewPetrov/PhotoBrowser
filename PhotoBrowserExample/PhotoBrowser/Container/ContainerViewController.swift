//
//  ContainerViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/11/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit
import WebKit

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

typealias ContainerViewControllerInputOutput = ContainerViewControllerInput & ContainerViewControllerOutput

protocol ContainerViewControllerInput: class {
    func didSetItemAs(isSelected: Bool, at indexPath: IndexPath)
    
    func switchTo(presentation: Presentation)
    
    func setItemAsCurrent(at indexPath: IndexPath, withTypes types: ItemTypes)
    
    func open(item: Item)
}

protocol ContainerViewControllerOutput: class {
    func isSelectionAllowed() -> Bool
    
    func selectedIndexPaths() -> [IndexPath]
    
    func currentlySupportedTypes() -> ItemTypes
}

protocol ContainerViewControllerDelegate {
    func reloadUI()
    
    func setItem(at indexPath: IndexPath, selected: Bool)
    
    func getSelectedIndexPaths() -> [IndexPath]
    
    func updateCache()
}

class ContainerViewController: SelectableViewController, Presentable {
    
    let presentation: Presentation = .container
    
    private var mediaTypesSegmentedControl: UISegmentedControl!
    internal weak var presentationInputOutput: PresentationInputOutput!
    
    var forwardButton = UIBarButtonItem(
        barButtonSystemItem: .reply,
        target: self,
        action: #selector(forwardButtonDidTap)
    )
    
    @IBOutlet private weak var toolbar: UIToolbar!
    private var selectedCountLabel = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    private let uiBarButtonImageSize = CGSize(width: 25, height: 25)
    private lazy var likedYesSizedImage = UIImageHelper.imageWithImage(
        image: #imageLiteral(resourceName: "iOSPhotoBrowser_doubleTick"),
        scaledToSize: uiBarButtonImageSize
    )
    private lazy var likedNoSizedImage = UIImageHelper.imageWithImage(
        image: #imageLiteral(resourceName: "iOSPhotoBrowser_likeNo"),
        scaledToSize: uiBarButtonImageSize
    )
    
    private var delegate: ContainerViewControllerDelegate?
    
    // MARK: - Life cycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("-ContainerViewController")
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
    
    private lazy var mediaViewController = MediaViewController.make(
        modelInputOutput: modelInputOutput,
        containerInputOutput: self
    )
    private lazy var linksViewController = LinksViewController.make(
        modelInputOutput: modelInputOutput,
        containerInputOutput: self
    )
    private lazy var docsViewController = DocsViewController.make(
        modelInputOutput: modelInputOutput,
        containerInputOutput: self
    )
    
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
    
    static func make(modelInputOutput: ModelInputOutput, presentationInputOutput: PresentationInputOutput) -> ContainerViewController {
        let newViewController = UIStoryboard(name: "PhotoBrowser", bundle: nil)
            .instantiateViewController(withIdentifier: "ContainerViewController") as! ContainerViewController
        newViewController.modelInputOutput = modelInputOutput
        newViewController.presentationInputOutput = presentationInputOutput
        
        return newViewController
    }
    
    // MARK: - Setup controls
    
    private func createBarButtonItems() {
        trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashButtonDidTap))
        actionButton = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(actionButtonDidTap)
        )
    }
    
    private func setupToolbar() {
        toolbar.items = [actionButton, flexibleSpace, selectedCountLabel, flexibleSpace, trashButton]
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
    }
    
    // MARK: - Update controls
    
    internal override func reloadUI() {
        delegate?.reloadUI()
    }
    
    internal override func updateCache() {
        delegate?.updateCache()
    }
    
    internal override func getSelectedIndexPaths() -> [IndexPath] {
        return delegate?.getSelectedIndexPaths() ?? [IndexPath]()
    }
    
    internal override func updateToolbarButtons() {
        actionButton.isEnabled = getSelectedIndexPaths().count != 0
        trashButton.isEnabled = getSelectedIndexPaths().count != 0
    }
    
    internal override func setItem(at indexPath: IndexPath, slected: Bool) {
        delegate?.setItem(at: indexPath, selected: slected)
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
                toolbarBottomConstraint.constant =
                    -(toolbar.frame.height + navigationController.navigationBar.intrinsicContentSize.height)
            }
        }
        UIView.animate(withDuration: 0.33) {
            self.view.layoutIfNeeded()
        }
    }
    
    internal override func updateSelectionTitle() {
        selectedCountLabel.title = getSelectionTitle()
    }
    
    internal override func updateNavigationBar() {
        // do nothing for now
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
        updateSelectButtonTitle()
    }
    
    @objc private func likeButtonDidTap(_ sender: Any) {
        modelInputOutput.setItemAs(
            withTypes: supportedTypes,
            isLiked: !isAllItemsLiked(),
            at: selectedIndexPaths())
        isSelectionAllowed = false
        delegate?.updateCache()
    }
    
    @objc private func actionButtonDidTap(_ sender: Any) {
        modelInputOutput.shareItem(withTypes: supportedTypes, indexPaths:Array(selectedIndexPaths()).sorted())
        isSelectionAllowed = false
        delegate?.reloadUI()
    }
    
    @objc private func forwardButtonDidTap(_ sender: Any) {
        modelInputOutput.forwardItem(withTypes: supportedTypes, indexPaths:Array(selectedIndexPaths()).sorted())
        isSelectionAllowed = false
        delegate?.reloadUI()
    }
    
}

extension ContainerViewController: ContainerViewControllerInput {
    
    func open(item: Item) {
        if let documentItem = item as? DocumentItem {
            let webView = WKWebView(frame: view.frame)
            let webViewController = UIViewController(nibName: nil, bundle: nil)
            webViewController.view = webView
            webView.load(URLRequest(url: documentItem.url))
            navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    func setItemAsCurrent(at indexPath: IndexPath, withTypes types: ItemTypes) {
        presentationInputOutput.setItemAsCurrent(at: indexPath, withTypes: types)
    }
    
    func switchTo(presentation: Presentation) {
        presentationInputOutput.setAutoplayVideoEnabled(to: presentation != .carousel)
        presentationInputOutput.switchTo(presentation: presentation)
    }
    
    func didSetItemAs(isSelected: Bool, at indexPath: IndexPath) {
        updateUIRalatedToSelection()
    }
    
}

extension ContainerViewController: ContainerViewControllerOutput {
    
    func currentlySupportedTypes() -> ItemTypes {
        return supportedTypes
    }
    
    func isSelectionAllowed() -> Bool {
        return isSelectionAllowed
    }
    
    func selectedIndexPaths() -> [IndexPath] {
        return getSelectedIndexPaths()
    }
    
}

extension ContainerViewController: PhotoBrowserInternalDelegate {
    
    func currentItemIndexDidChange() {
    
    }
    
    func getSupportedTypes() -> ItemTypes {
        return supportedTypes
    }
    
}




