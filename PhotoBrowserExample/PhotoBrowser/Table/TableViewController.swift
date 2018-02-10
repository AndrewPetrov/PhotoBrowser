//
//  TableViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/9/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UITableViewController {

    static var dateFormatter = DateFormatter()
    static let inset: CGFloat = 10

    private weak var presentationInput: PresentationInput!
    private var isSelectionAllowed = false {
        didSet {
            if !isSelectionAllowed {
                selectedIndexPathes.removeAll()
            }
            setupNavigationBar()
        }
    }
    private var selectButton: UIBarButtonItem!
    private var selectAllButton: UIBarButtonItem!
    private var selectedIndexPathes = Set<IndexPath>()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func makeTableViewController(presentationInput: PresentationInput) -> TableViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableViewController") as! TableViewController
        newViewController.presentationInput = presentationInput

        return newViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        TableViewController.dateFormatter.dateStyle = .short
        setupNavigationBar()


    }

    private func setupNavigationBar() {


        navigationItem.hidesBackButton = isSelectionAllowed

        selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(toggleSelection))
        navigationItem.rightBarButtonItem = selectButton

        selectAllButton = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(toggleSelectAll))
        if isSelectionAllowed {
            navigationItem.leftBarButtonItem = selectAllButton
        } else {
            navigationItem.leftBarButtonItem = nil
        }


    }

    @objc private func toggleSelectAll() {
        //select all
        if selectedIndexPathes.count < presentationInput.numberOfItems() {
            selectAllButton.title = "Deselect All"
            selectedIndexPathes.removeAll()
            let count = presentationInput.numberOfItems()
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
        return indexPath.row == presentationInput.numberOfItems() - 1
    }

}

extension TableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentationInput.numberOfItems()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        if let item = presentationInput.item(at: indexPath) {

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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = presentationInput.item(at: indexPath)?.image else { return 0 }
        let proportion = image.size.height / image.size.width
        let height = tableView.frame.width * proportion

        return height + (isLastCell(indexPath: indexPath) ? 0 : TableViewController.inset)
    }

}

extension TableViewController : PresentationOutput {

    func setItem(at index: IndexPath, isSelected: Bool) {

    }

    func setItemAsCurrent(at index: IndexPath) {

    }

}
