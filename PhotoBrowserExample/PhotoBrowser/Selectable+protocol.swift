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
    
    internal weak var modelInputOutput: ModelInputOutput!
    
    internal var supportedTypes: ItemTypes = [.image, .video]
    
    internal var selectButton: UIBarButtonItem!
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
    
    internal func updateCache() {
        fatalError("need to override updateCache")
    }
    
    internal func setItem(at indexPath: IndexPath, selected: Bool) {
        fatalError("need to override setItem(at indexPath: IndexPath, selected: Bool)")
    }
    
    internal func updateToolbarButtons() {
        fatalError("need to override reloadUI")
    }
    
    internal func getSelectedIndexPaths() -> [IndexPath] {
        fatalError("need to override getSelectedIndexPaths")
    }
    
    internal func updateUIRelatedToSelection() {
        updateSelectionTitle()
        updateToolbarButtons()
    }
    
    internal func getSelectionTitle() -> String {
        
        var itemTypes = ItemTypes()
        for indexPath in getSelectedIndexPaths() {
            if let item = modelInputOutput.item(withTypes: supportedTypes, at: indexPath) {
                itemTypes.insert(item.type)
            }
        }
        return ItemsSelectionHelper.getSelectionTitle(
            itemTypes: itemTypes,
            count: getSelectedIndexPaths().count
        )
    }
    
    internal func updateSelectButtonTitle() {
        selectButton.isEnabled = modelInputOutput.numberOfItems(withTypes: supportedTypes) > 0
        let title = isSelectionAllowed ? "Cancel" : "Select"
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
            self.modelInputOutput.deleteItems(
                withTypes: self.supportedTypes,
                indexPaths: self.getSelectedIndexPaths()
            )
            self.isSelectionAllowed = false
            self.updateUIRelatedToSelection()
            self.updateCache()
        }
        alertController.addAction(deleteForMeAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deselectAll() {
        let count = modelInputOutput.numberOfItems(withTypes: supportedTypes)
        for row in 0..<count {
            let indexPath = IndexPath(row: row, section: 0)
            setItem(at: indexPath, selected: false)
        }
        updateUIRelatedToSelection()
    }
    
    internal func isAllItemsLiked() -> Bool {
        var isAllItemsLiked = !getSelectedIndexPaths().isEmpty
        for selectedIndexPath in getSelectedIndexPaths() {
            let isItemLiked = modelInputOutput.isItemLiked(withTypes: supportedTypes, at: selectedIndexPath)
            if !isItemLiked {
                isAllItemsLiked = false
                break
            }
        }
        return isAllItemsLiked
    }
    
}
