//
//  CarouselControlCollectionLayout.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/13/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation
import UIKit

class CarouselControlCollectionLayout: UICollectionViewFlowLayout {

    private let supportedTypes: [ItemType]

    private weak var presentationInputOutput: PresentationInputOutput!

    init(presentationInputOutput: PresentationInputOutput, supportedTypes: [ItemType]) {
        self.presentationInputOutput = presentationInputOutput
        self.supportedTypes = supportedTypes

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
