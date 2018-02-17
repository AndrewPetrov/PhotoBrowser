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

    internal var selectButton: UIBarButtonItem!
    internal var selectAllButton: UIBarButtonItem!
    internal var trashButton: UIBarButtonItem!
    internal var actionButton: UIBarButtonItem!
    internal let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadUI()
    }

    var isSelectionAllowed = false {
        didSet {
            reloadUI()
            if !isSelectionAllowed {
                deselectAll()
            }
            updateSelectionTitle()
            updateToolbarPosition()
            updateNavigationBar()
            updateSelectButtonTitle()
        }
    }

    internal func updateNavigationBar() {
        fatalError("need to override updateNavigationBar")
    }


    internal func updateToolbarPosition() {
        fatalError("need to override updateToolbarPosition")
    }

    internal func updateSelectionTitle() {
        fatalError("need to override updateSelectionTitle")
    }

    internal func reloadUI() {
        fatalError("need to override reloadUI")
    }

    internal func setItem(at indexPath: IndexPath, slected: Bool) {
        fatalError("need to override setItem(at indexPath: IndexPath, slected: Bool)")
    }

    internal func updateToolbarButtons() {
        fatalError("need to override reloadUI")
    }

    internal func getSelectedIndexPaths() -> [IndexPath] {
        fatalError("need to override getSelectedIndexPaths")
    }

    internal func updateUIRalatedToSelection() {
        updateSelectionTitle()
        updateToolbarButtons()
        updateSelectAllTitle()
    }

    internal func getSelectionTitle() -> String {

        var itemTypes = Set<ItemType>()
        for indexPath in getSelectedIndexPaths() {
            if let item = presentationInputOutput.item(withType: supportedTypes, at: indexPath) {
                itemTypes.insert(item.type)
            }
        }
        return ItemsSelectionHelper.getSelectionTitle(
            itemTypes: Array(itemTypes),
            count: getSelectedIndexPaths().count)
    }

    private func updateSelectButtonTitle() {
        let title = isSelectionAllowed ? "Calcel" : "Select"
        selectButton.title = title
    }

    @objc internal func toggleSelection() {
        isSelectionAllowed = !isSelectionAllowed
        reloadUI()
    }

    @objc internal func trashButtonDidTap(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let deleteForMeAction = UIAlertAction(title: "Delete For Me", style: .destructive) { [weak self] _ in
            guard let `self` = self else { return }
            self.presentationInputOutput.deleteItems(
                withTypes: self.supportedTypes,
                indexPaths: self.getSelectedIndexPaths()
            )
            self.updateUIRalatedToSelection()
            self.reloadUI()
        }
        alertController.addAction(deleteForMeAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }

        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @objc internal func toggleSelectAll() {
        if getSelectedIndexPaths().count < presentationInputOutput.numberOfItems(withType: supportedTypes) {
            selectAll()
        } else {
            deselectAll()
        }
    }

    private func selectAll() {
        let count = presentationInputOutput.numberOfItems(withType: supportedTypes)
        for row in 0..<count {
            let indexPath = IndexPath(row: row, section: 0)
            setItem(at: indexPath, slected: true)
        }
        updateUIRalatedToSelection()
    }

    private func deselectAll() {
        let count = presentationInputOutput.numberOfItems(withType: supportedTypes)
        for row in 0..<count {
            let indexPath = IndexPath(row: row, section: 0)
            setItem(at: indexPath, slected: false)
        }
        updateUIRalatedToSelection()
    }

    internal func updateSelectAllTitle() {
        if getSelectedIndexPaths().count < presentationInputOutput.numberOfItems(withType: supportedTypes) {
            selectAllButton.title = "Select All"
        } else {
            selectAllButton.title = "Deselect All"
        }
    }

    internal func isAllItemsLiked() -> Bool {
        var isAllItemsLiked = !getSelectedIndexPaths().isEmpty
        for selectedIndexPath in getSelectedIndexPaths() {
            let isItemLiked = presentationInputOutput.isItemLiked(withTypes: supportedTypes, at: selectedIndexPath)
            if !isItemLiked {
                isAllItemsLiked = false
                break
            }
        }
        return isAllItemsLiked
    }

}
