//
//  ItemsStringHelper.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/14/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation

class ItemsSelectionHelper {
    
    static func getSelectionTitle(itemTypes: ItemTypes, count: Int) -> String {
        return "\(count) " + itemTypes.description(isPlural: count > 1)
    }
    
}
