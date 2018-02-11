//
//  LinkViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/11/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class LinksViewController: UIViewController {
    private weak var presentationInputOutput: PresentationInputOutput!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func make(presentationInputOutput: PresentationInputOutput) -> LinksViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LinksViewController") as! LinksViewController
        newViewController.presentationInputOutput = presentationInputOutput

        return newViewController
    }
    
}

extension LinksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentationInputOutput.numberOfItems(withType: [.link])
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkTableViewCell") as! LinkTableViewCell
        if let item = presentationInputOutput.item(withType: [.link], at: indexPath) as? LinkItem {
            cell.configureCell(with: item) {
                print("go to message")
            }
        }

        return cell
    }


}

extension LinksViewController: UITableViewDelegate {

}
