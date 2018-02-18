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

    private let supportedTypes: ItemTypes

    private weak var presentationInputOutput: PresentationInputOutput!

    init(presentationInputOutput: PresentationInputOutput, supportedTypes: ItemTypes) {
        self.presentationInputOutput = presentationInputOutput
        self.supportedTypes = supportedTypes

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
