//
//  SingleViewController.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 4/29/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class SingleViewController: UIViewController, Presentable {
    
    var presentation: Presentation = .single
    
    private let supportedTypes: ItemTypes = [.image]
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    
    private weak var modelInputOutput: ModelInputOutput!
    private weak var presentationInputOutput: PresentationInputOutput!
    
    //TODO: calculate related on real resolution
    let minScale: CGFloat = 1
    let maxScale: CGFloat = 4
    
    static func make(modelInputOutput: ModelInputOutput,
                     presentationInputOutput: PresentationInputOutput) -> SingleViewController {
        let newViewController = StoryboardScene.PhotoBrowser.singleViewController.instantiate()
//        let newViewController = UIStoryboard(name: "PhotoBrowser", bundle: nil).instantiateViewController(
//            withIdentifier: "SingleViewController"
//        ) as! SingleViewController
        newViewController.modelInputOutput = modelInputOutput
        newViewController.presentationInputOutput = presentationInputOutput
        
        return newViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.maximumZoomScale = maxScale
        scrollView.minimumZoomScale = minScale
        scrollView.delegate = self
        
        imageView.image = modelInputOutput.item(withTypes: supportedTypes, at: IndexPath(item: 0, section: 0))?.image
    }
    
    @IBAction func shareAction(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.modelInputOutput.saveItem(
                withTypes: self.supportedTypes,
                indexPaths: [self.presentationInputOutput.currentItemIndex(withTypes: self.supportedTypes)]
            )
        }
        alertController.addAction(saveAction)
        
        let shareAction = UIAlertAction(title: "Share", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.modelInputOutput.shareItem(
                withTypes: self.supportedTypes,
                indexPaths: [self.presentationInputOutput.currentItemIndex(withTypes: self.supportedTypes)]
            )
        }
        alertController.addAction(shareAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeImageScaleAction(_ sender: Any) {
        let scale = scrollView.zoomScale == minScale ? maxScale : minScale
        
        scrollView.setZoomScale(scale, animated: true)
    }
    
}

extension SingleViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale <= minScale {
            scrollView.minimumZoomScale = minScale
        }
    }
    
}

extension SingleViewController: PhotoBrowserInternalDelegate {
    
    func currentItemIndexDidChange() {
        //never can be called
    }
    
    func getSupportedTypes() -> ItemTypes {
        return supportedTypes
    }
    
}
