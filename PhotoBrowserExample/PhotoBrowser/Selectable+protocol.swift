//
//  Selectable+protocol.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/12/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class SelectableViewController: UIViewController {

    internal weak var presentationInputOutput: PresentationInputOutput!

    internal var supportedTypes: [ItemType] = [.image, .video]

    var selectButton: UIBarButtonItem!
    var selectAllButton: UIBarButtonItem!
    var trashButton: UIBarButtonItem!

    internal var selectedIndexPathes = Set<IndexPath>() {
        didSet {
            updateSelectionTitle()
        }
    }

    internal var isSelectionAllowed = false {
        didSet {
            if !isSelectionAllowed {
                selectedIndexPathes.removeAll()
            }
            setupNavigationBar()
            updateSelectionTitle()
            updateToolbar()
        }
    }

    internal func setupNavigationBar() {

    }

    internal func updateToolbar() {

    }

    internal func setupToolbar() {

    }

    internal func updateSelectionTitle() {

    }

    internal func reloadUI() {

    }


    internal func getSelectionTitle() -> String {
        //TODO: concider other type combinations
        let type = "Items"
        return "\(selectedIndexPathes.count) " + type + " Selected"
    }

    @objc internal func toggleSelection() {
        isSelectionAllowed = !isSelectionAllowed
        let title = isSelectionAllowed ? "Calcel" : "Select"
        selectButton.title = title

        reloadUI()
    }

    @objc internal func trashButtonDidTap(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let deleteForMeAction = UIAlertAction(title: "Delete For Me", style: .destructive) { [weak self] _ in
            guard let `self` = self else { return }
            self.presentationInputOutput.deleteItems(indexPathes: self.selectedIndexPathes)

        }
        alertController.addAction(deleteForMeAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            alertController.dismiss(animated: true, completion: nil)
        }

        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @objc internal func toggleSelectAll() {
        //select all
        if selectedIndexPathes.count < presentationInputOutput.numberOfItems(withType: supportedTypes) {
            selectAllButton.title = "Deselect All"
            selectedIndexPathes.removeAll()
            let count = presentationInputOutput.numberOfItems(withType: supportedTypes)
            for row in 0..<count {
                selectedIndexPathes.insert(IndexPath(row: row, section: 0))
            }
        } else {
            //deselect all
            selectAllButton.title = "Select All"
            selectedIndexPathes.removeAll()
        }
        reloadUI()
    }

}
