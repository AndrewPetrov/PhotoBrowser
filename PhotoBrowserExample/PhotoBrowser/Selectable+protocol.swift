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
    var actionButton: UIBarButtonItem!
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadUI()
    }

    internal var selectedIndexPathes = Set<IndexPath>() {
        didSet {
            updateSelectionTitle()
            updateToolbarButtons() 
        }
    }

    var isSelectionAllowed = false {
        didSet {
            if !isSelectionAllowed {
                selectedIndexPathes.removeAll()
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

    internal func updateToolbarButtons() {
        fatalError("need to override reloadUI")
    }

    internal func getSelectionTitle() -> String {

        var itemTypes = Set<ItemType>()
        for indexPath in selectedIndexPathes {
            if let item = presentationInputOutput.item(withType: supportedTypes, at: indexPath) {
                itemTypes.insert(item.type)
            }
        }
        return ItemsSelectionHelper.getSelectionTitle(
            itemTypes: Array(itemTypes),
            count: selectedIndexPathes.count)
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
                indexPathes: Array(self.selectedIndexPathes).sorted()
            )
            self.selectedIndexPathes.removeAll()
            self.reloadUI()
        }
        alertController.addAction(deleteForMeAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }

        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
// FIXME fix selection all
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
