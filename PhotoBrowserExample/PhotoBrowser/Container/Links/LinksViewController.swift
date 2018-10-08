//
//  LinkViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/11/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class LinksViewController: UIViewController {
    
    private weak var modelInputOutput: ModelInputOutput!
    private weak var containerInputOutput: ContainerViewControllerInputOutput!
    
    @IBOutlet private weak var tableView: UITableView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static func make(modelInputOutput: ModelInputOutput,
                     containerInputOutput: ContainerViewControllerInputOutput) -> LinksViewController {
        
        let newViewController = StoryboardScene.PhotoBrowser.linksViewController.instantiate()
        newViewController.modelInputOutput = modelInputOutput
        newViewController.containerInputOutput = containerInputOutput
        
        return newViewController
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let firstIndex = tableView.indexPathsForVisibleRows?.first
        var secondIndex: IndexPath?
        if let indexPaths = tableView.indexPathsForVisibleRows, indexPaths.count > 1 {
            secondIndex = tableView.indexPathsForVisibleRows?[1]
        }
        coordinator.animate(alongsideTransition: { [weak self] (context) -> Void in
            guard let `self` = self else { return }
            self.tableView.scrollToRow(
                at: secondIndex ?? firstIndex ?? IndexPath(item: 0, section: 0),
                at: .middle,
                animated: true
            )
        }, completion: nil)
    }
    
    private func showWebViewController(url: URL) {
        let controller = StoryboardScene.PhotoBrowser.webViewController.instantiate()
        
        controller.url = url
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension LinksViewController: ContainerViewControllerDelegate {
    
    func updateCache() {
        //do nothing for now
        reloadUI()
    }
    
    func getSelectedIndexPaths() -> [IndexPath] {
        return tableView.indexPathsForVisibleRows ?? [IndexPath]()
    }
    
    func setItem(at indexPath: IndexPath, selected: Bool) {
        if selected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func reloadUI() {
        tableView.reloadData()
    }
    
}

extension LinksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelInputOutput.numberOfItems(withTypes: containerInputOutput.currentlySupportedTypes())
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkTableViewCell") as! LinkTableViewCell
        let isSelectionAllowed = containerInputOutput.isSelectionAllowed()
        if let item = modelInputOutput.item(
            withTypes: containerInputOutput.currentlySupportedTypes(),
            at: indexPath
        ) as? LinkItem {
            cell.configureCell(
                with: item,
                isSelectionAllowed: isSelectionAllowed,
                isLiked: item.isLiked) { [weak self] in
                self?.modelInputOutput.scrollToMessage(at: item.messageIndexPath)
            }
        }
        
        return cell
    }
    
}

extension LinksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if containerInputOutput.isSelectionAllowed() {
            containerInputOutput.didSetItemAs(isSelected: true, at: indexPath)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            if let item = modelInputOutput.item(
                withTypes: containerInputOutput.currentlySupportedTypes(),
                at: indexPath
            ) as? LinkItem {
                showWebViewController(url: item.url)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        containerInputOutput.didSetItemAs(isSelected: false, at: indexPath)
    }
    
}
