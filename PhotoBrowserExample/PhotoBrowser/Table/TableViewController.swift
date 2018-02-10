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

    private weak var presentationInput: PresentationInput!

//    @IBOutlet private weak var tableView: UITableView!


    //    required init?(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }

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

    //
    //    init(presentationInput: PresentationInput) {
    ////        super.init(nibName: nil, bundle: nil)
    //    }

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    private func setupCollectionView() {
        //        collectionView
        //        collectionView?.register(UINib(nibName: "TableCollectionViewCell", bundle: nil),
        //                                 forCellWithReuseIdentifier: "TableCollectionViewCell")

    }

}


extension TableViewController {


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentationInput.numberOfItems()
    }


    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell

        cell.configureCell(image: presentationInput.item(at: indexPath)?.image)

        return cell
    }



//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TableCollectionViewCell",
//                                                      for: indexPath) as! TableCollectionViewCell
//        //        cell.delegate = self
//        //        cell.isForPreviewOnly = isForPreviewOnly
//        //        if let network: SocialNetworkEntity = dataSourceArray?[indexPath.row]{
//        //            cell.configure(network: network, index:indexPath.row)
//        //        }
//        cell.configureCell(image: presentationInput.item(at: indexPath)?.image)
//
//        return cell
//    }

}

extension TableViewController : PresentationOutput {

    func setItem(at index: IndexPath, isSelected: Bool) {

    }

    func setItemAsCurrent(at index: IndexPath) {

    }


}
