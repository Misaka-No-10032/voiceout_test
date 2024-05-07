//
//  Item.swift
//  test
//
//  Created by Shengkai Sun on 5/07/24.
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
