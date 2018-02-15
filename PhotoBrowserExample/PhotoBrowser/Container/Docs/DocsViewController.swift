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
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DocsViewController") as! DocsViewController
        newViewController.presentationInputOutput = presentationInputOutput
        newViewController.containerInputOutput = containerInputOutput

        return newViewController
    }
}

extension DocsViewController: ContainerViewControllerDelegate {

    func reloadUI() {
        tableView.reloadData()
    }

}

extension DocsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentationInputOutput.numberOfItems(withType: [.document])
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "DocsTableViewCell") as! DocsTableViewCell
        let isSelectionAllowed = containerInputOutput.isSelectionAllowed()
        let isSelected = containerInputOutput.selectedIndexPathes().contains(indexPath)
        if let item = presentationInputOutput.item(withType: [.document], at: indexPath) as? DocumentItem {
            cell.configureCell(
                with: item,
                size: "100500",
                extensionText: "jpg",
                isSelectionAllowed: isSelectionAllowed, isSelected: isSelected
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
            if let item = presentationInputOutput.item(withType: [.document], at: indexPath) as? LinkItem {
                //TODO: somhow open the document fom item
            }
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        containerInputOutput.didSetItemAs(isSelected: false, at: indexPath)
    }
}

