//
//  TitleView.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/14/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class TitleView: UIView {
    
    @IBOutlet private weak var senderLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }

    func setup(sender: String, info: String) {
        senderLabel.text = sender
        infoLabel.text = info
    }

    fileprivate func loadNib() {
        // check to avoid infinite loop with "required init?(coder aDecoder: NSCoder)" method
        if subviews.count == 0 {
            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
            let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView

            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(view)
        }
    }

}
