//
//  TableViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: SelectableViewController, PresentationViewController {

    let presentation: Presentation = .table

    static var dateFormatter = DateFormatter()
    static let inset: CGFloat = 10

    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var selectedCountLabel: UIBarButtonItem!
    @IBOutlet weak var toolbarBottomContraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: UITableView!

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
    }

    internal override func updateToolbarPosition() {
        if isSelectionAllowed {
            toolbarBottomContraint.constant = 0
        } else {
            if let navigationController = navigationController {
                toolbarBottomContraint.constant = -(toolbar.frame.height + navigationController.navigationBar.intrinsicContentSize.height)
            }
        }
        UIView.animate(withDuration: 0.33) {
            self.view.layoutIfNeeded()
        }
    }

    private func setupToolbar() {
        trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashButtonDidTap))
        toolbar.items?.append(trashButton)
    }

    internal override func updateSelectionTitle() {
        selectedCountLabel.title = super.getSelectionTitle()
    }

    override func updateNavigationBar() {
        navigationItem.hidesBackButton = isSelectionAllowed
        navigationItem.leftBarButtonItem = isSelectionAllowed ? selectAllButton : nil
    }

    private func setupNavigationBar() {
        selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(toggleSelection))
        navigationItem.rightBarButtonItem = selectButton

        selectAllButton = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(toggleSelectAll))
    }

    internal override func reloadUI() {
        tableView.reloadData()
    }

    private func isLastCell(indexPath: IndexPath) -> Bool {
        return indexPath.row == presentationInputOutput.numberOfItems() - 1
    }

    @IBAction func actionButtonDidTap(_ sender: Any) {
        //TODO: add action here
    }

}

extension TableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentationInputOutput.numberOfItems(withType: supportedTypes)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        if let item = presentationInputOutput.item(withType: supportedTypes, at: indexPath) as? Item & Likable {

            let isSelected = selectedIndexPathes.contains(indexPath)

            cell.configureCell(
                item: item,
                hasInset: !isLastCell(indexPath: indexPath),
                isSelectionAllowed: isSelectionAllowed,
                isSelected: isSelected) { [weak self]  isSelected in
                    guard let `self` = self else { return }
                    if isSelected {
                        self.selectedIndexPathes.insert(indexPath)
                    } else {
                        self.selectedIndexPathes.remove(indexPath)
                    }
            }
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
        return 1000
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentationInputOutput.setItemAsCurrent(at: indexPath)
        presentationInputOutput.switchTo(presentation: .carousel)
    }

}
