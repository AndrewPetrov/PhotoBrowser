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
    
    private weak var modelInputOutput: ModelInputOutput!
    
    init(modelInputOutput: ModelInputOutput, supportedTypes: ItemTypes) {
        self.modelInputOutput = modelInputOutput
        self.supportedTypes = supportedTypes
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
