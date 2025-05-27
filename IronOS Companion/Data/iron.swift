//
//  iron.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/26/25.
//

import SwiftData
import Foundation

@Model
class Iron {
    var name: String
    var value: String
    var build: String
    var devSN:String
    var devID: String
    
    init(name: String, value: String, build: String, devSN: String, devID: String) {
        self.name = name
        self.value = value
        self.build = build
        self.devSN = devSN
        self.devID = devID
    }
}
