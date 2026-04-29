//
//  Item.swift
//  Vellum
//
//  Created by Disha Maheshwari on 4/29/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
