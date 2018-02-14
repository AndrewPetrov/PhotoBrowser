//
//  ItemsStringHelper.swift
//  PhotoBrowser
//
//  Created by AndrewPetrov on 2/14/18.
//  Copyright © 2018 AndrewPetrov. All rights reserved.
//

import Foundation

class ItemsSelectionHelper {

    static func getSelectionTitle(itemTypes: [ItemType], count: Int) -> String {
        if itemTypes.count == 1 {
            return "\(count) " + itemTypes.first!.description(isPlural: count > 1)
        } else {
            return "\(count) " + (count > 1 ? "Items" : "Item")
        }
    }

}
