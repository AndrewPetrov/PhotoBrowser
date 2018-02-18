//
//  DocsViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/11/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class DocsViewController: UIViewController {
    
    private weak var presentationInputOutput: PresentationInputOutput!
    private weak var containerInputOutput: ContainerViewControllerInputOutput!

    @IBOutlet private weak var tableView: UITableView!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func make(presentationInputOutput: PresentationInputOutput, containerInputOutput: ContainerViewControllerInputOutput) -> DocsViewController {
        let newViewController = UIStoryboard(name: "PhotoBrowser", bundle: nil).instantiateViewController(withIdentifier: "DocsViewController") as! DocsViewController
        newViewController.presentationInputOutput = presentationInputOutput
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
            self.tableView.scrollToRow(at: secondIndex ?? firstIndex ?? IndexPath(item: 0, section: 0), at: .middle, animated: true)
            }, completion: nil)
    }
}

extension DocsViewController: ContainerViewControllerDelegate {

    func getSelectedIndexPaths() -> [IndexPath] {
        return tableView.indexPathsForVisibleRows ?? [IndexPath]()
    }

    func setItem(at indexPath: IndexPath, slected: Bool) {
        if slected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    func reloadUI() {
        tableView.reloadData()
    }

}

extension DocsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentationInputOutput.countOfItems(withType: containerInputOutput.currentlySupportedTypes())
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "DocsTableViewCell") as! DocsTableViewCell
        let isSelectionAllowed = containerInputOutput.isSelectionAllowed()
        if let item = presentationInputOutput.item(withType: containerInputOutput.currentlySupportedTypes(), at: indexPath) as? DocumentItem {
            cell.configureCell(
                with: item,
                size: "100500",
                extensionText: "jpg",
                isSelectionAllowed: isSelectionAllowed,
                isLiked: item.isLiked
            )
        }

        return cell
    }

}

extension DocsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if containerInputOutput.isSelectionAllowed() {
            containerInputOutput.didSetItemAs(isSelected: true, at: indexPath)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            if let item = presentationInputOutput.item(withType: containerInputOutput.currentlySupportedTypes(), at: indexPath) as? LinkItem {
                //TODO: somhow open the document fom item
            }
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        containerInputOutput.didSetItemAs(isSelected: false, at: indexPath)
    }
}

