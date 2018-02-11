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

class ContainerViewController: UIViewController {

    private weak var presentationInputOutput: PresentationInputOutput!

    var mediaTypesSegmentedControl: UISegmentedControl!

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

    static func make(presentationInputOutput: PresentationInputOutput) -> ContainerViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContainerViewController") as! ContainerViewController
        newViewController.presentationInputOutput = presentationInputOutput

        return newViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        add(asChildViewController: mediaViewController)
    }

    private func setupNavigationBar() {
        mediaTypesSegmentedControl = UISegmentedControl(items: [
            ContainerItemTypes.media.title,
            ContainerItemTypes.links.title,
            ContainerItemTypes.docs.title
            ])

        mediaTypesSegmentedControl.selectedSegmentIndex = 0;
        mediaTypesSegmentedControl.addTarget(self, action: #selector(mediaTypeDidChange(_:)), for: .valueChanged)
        navigationItem.titleView = mediaTypesSegmentedControl
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
    }

}
