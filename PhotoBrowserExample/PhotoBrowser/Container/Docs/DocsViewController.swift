//
//  DocsViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/11/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class DocsViewController: UIViewController {
    
    private weak var presentationInputOutput: PresentationInputOutput!
    private weak var containerInputOutput: ContainerViewControllerInputOutput!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func make(presentationInputOutput: PresentationInputOutput, containerInputOutput: ContainerViewControllerInputOutput) -> DocsViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DocsViewController") as! DocsViewController
        newViewController.presentationInputOutput = presentationInputOutput
        newViewController.containerInputOutput = containerInputOutput

        return newViewController
    }
}

extension DocsViewController: ContainerViewControllerDelegate {

    func reloadUI() {
//        tableView.reloadData()
    }

}

