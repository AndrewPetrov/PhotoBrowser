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
    private weak var containerInputOutput: ContainerViewControllerInputOutput!

    @IBOutlet private weak var tableView: UITableView!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func make(presentationInputOutput: PresentationInputOutput, containerInputOutput: ContainerViewControllerInputOutput) -> LinksViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LinksViewController") as! LinksViewController
        newViewController.presentationInputOutput = presentationInputOutput
        newViewController.containerInputOutput = containerInputOutput

        return newViewController
    }

    private func showWebViewController(url: URL) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        controller.url = url

        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension LinksViewController: ContainerViewControllerDelegate {

    func reloadUI() {
        tableView.reloadData()
    }

}

extension LinksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentationInputOutput.numberOfItems(withType: [.link])
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkTableViewCell") as! LinkTableViewCell
        if let item = presentationInputOutput.item(withType: [.link], at: indexPath) as? LinkItem {
            cell.configureCell(with: item) { [weak self] in
                self?.presentationInputOutput.goToMessage(with: item.messageIndexPath)
            }
        }

        return cell
    }

}

extension LinksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = presentationInputOutput.item(withType: [.link], at: indexPath) as? LinkItem {
            showWebViewController(url: item.url)
        }
    }

}
