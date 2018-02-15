//
//  TableViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: SelectableViewController, Presentatable {

    let presentation: Presentation = .table

    static var dateFormatter = DateFormatter()
    static let inset: CGFloat = 10

    @IBOutlet private weak var toolbar: UIToolbar!
    private var selectedCountLabel: UIBarButtonItem!
    @IBOutlet private weak var toolbarBottomContraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Life cycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func make(presentationInputOutput: PresentationInputOutput) -> TableViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableViewController") as! TableViewController
        newViewController.presentationInputOutput = presentationInputOutput

        return newViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        TableViewController.dateFormatter.dateStyle = .short
        setupNavigationBar()
        setupToolbar()
        updateToolbarButtons()
        updateSelectionTitle()
        updateToolbarPosition()
    }

    // MARK: - Setup controls

    private func setupToolbar() {
        actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionButtonDidTap))
        trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashButtonDidTap))
        selectedCountLabel = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        toolbar.items? = [actionButton, flexibleSpace, selectedCountLabel, flexibleSpace, trashButton]
    }

    private func setupNavigationBar() {
        selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(toggleSelection))
        parent?.navigationItem.rightBarButtonItem = selectButton

        selectAllButton = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(toggleSelectAll))

        let titleView = TitleView.init(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        let itemsTitle = ItemsSelectionHelper.getSelectionTitle(
            itemTypes: presentationInputOutput.intersectionOfBrowserOutputTypes(inputTypes: supportedTypes),
            count: presentationInputOutput.numberOfItems(withType: supportedTypes)
        )
        titleView.setup(sender: presentationInputOutput.senderName(), info: itemsTitle)
        parent?.navigationItem.titleView = titleView
    }

    // MARK: - Update controls

    internal override func updateToolbarPosition() {
        if isSelectionAllowed {
            toolbarBottomContraint.constant = 0
        } else {
            toolbarBottomContraint.constant = -toolbar.frame.height
            //consider extra padding point for iPhone X
            if #available(iOS 11.0, *), let window = UIApplication.shared.keyWindow {
                let bottomPadding = window.safeAreaInsets.bottom
                toolbarBottomContraint.constant -= bottomPadding
            }
        }
        UIView.animate(withDuration: 0.33) {
            self.view.layoutIfNeeded()
        }
    }

    internal override func updateSelectionTitle() {
        selectedCountLabel.title = super.getSelectionTitle()
    }

    internal override func updateNavigationBar() {
        parent?.navigationItem.hidesBackButton = isSelectionAllowed
        parent?.navigationItem.leftBarButtonItem = isSelectionAllowed ? selectAllButton : nil
    }

    internal override func updateToolbarButtons() {
        actionButton.isEnabled = selectedIndexPathes.count != 0
        trashButton.isEnabled = selectedIndexPathes.count != 0
    }

    internal override func reloadUI() {
        tableView.reloadData()
    }

    private func isLastCell(indexPath: IndexPath) -> Bool {
        return indexPath.row == presentationInputOutput.numberOfItems(withType: supportedTypes) - 1
    }

    // MARK: - User actions

    @objc internal func actionButtonDidTap(_ sender: Any) {
        presentationInputOutput.shareItem(withTypes: supportedTypes, indexPathes: Array(selectedIndexPathes).sorted())
    }

}

extension TableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentationInputOutput.numberOfItems(withType: supportedTypes)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        if let item = presentationInputOutput.item(withType: supportedTypes, at: indexPath) {
            let isSelected = selectedIndexPathes.contains(indexPath)
            cell.configureCell(
                item: item,
                hasInset: !isLastCell(indexPath: indexPath),
                isSelectionAllowed: isSelectionAllowed,
                isSelected: isSelected)
        }

        return cell
    }

}

extension TableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = presentationInputOutput.item(withType: supportedTypes, at: indexPath)?.image else { return 0 }
        let proportion = image.size.height / image.size.width
        let height = tableView.frame.width * proportion

        return height + (isLastCell(indexPath: indexPath) ? 0 : TableViewController.inset)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        //fix jumping after reloadData()
        return 10000
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSelectionAllowed {
            selectedIndexPathes.insert(indexPath)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
            presentationInputOutput.setItemAsCurrent(at: indexPath)
            presentationInputOutput.switchTo(presentation: .carousel)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedIndexPathes.remove(indexPath)
    }

}

extension TableViewController: PhotoBrowserInternalDelegate {

    func currentItemIndexDidChange() {

    }

}
