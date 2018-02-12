//
//  TableViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: SelectableViewController {

    private let supportedTypes: [ItemType] = [.image, .video]

    static var dateFormatter = DateFormatter()
    static let inset: CGFloat = 10

    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var selectedCountLabel: UIBarButtonItem!
    @IBOutlet weak var toolbarBottomContraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: UITableView!

    private var selectButton: UIBarButtonItem!
    private var selectAllButton: UIBarButtonItem!
    private var trashButton: UIBarButtonItem!


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

    internal override func updateToolbar() {
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

    internal override func setupToolbar() {
        trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashButtonDidTap))
        toolbar.items?.append(trashButton)
    }

    internal override func updateSelectionTitle() {
        selectedCountLabel.title = super.getSelectionTitle()
    }

    internal override func setupNavigationBar() {
        navigationItem.hidesBackButton = isSelectionAllowed

        selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(toggleSelection))
        navigationItem.rightBarButtonItem = selectButton

        selectAllButton = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(toggleSelectAll))
        navigationItem.leftBarButtonItem = isSelectionAllowed ? selectAllButton : nil

    }

    @objc private func toggleSelectAll() {
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
        tableView.reloadData()
    }

    @objc private func toggleSelection() {
        isSelectionAllowed = !isSelectionAllowed
        let title = isSelectionAllowed ? "Calcel" : "Select"
        selectButton.title = title

        tableView.reloadData()
    }

    private func isLastCell(indexPath: IndexPath) -> Bool {
        return indexPath.row == presentationInputOutput.numberOfItems() - 1
    }

//    @IBAction func trashButtonDidTap(_ sender: Any) {
//        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//        let deleteForMeAction = UIAlertAction(title: "Delete For Me", style: .destructive) { [weak self] _ in
//            guard let `self` = self else { return }
//            self.presentationInputOutput.deleteItems(indexPathes: self.selectedIndexPathes)
//
//        }
//        alertController.addAction(deleteForMeAction)
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
//            alertController.dismiss(animated: true, completion: nil)
//        }
//
//        alertController.addAction(cancelAction)
//
//        present(alertController, animated: true, completion: nil)
//    }

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
