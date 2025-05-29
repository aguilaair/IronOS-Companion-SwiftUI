//
//  iron.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/26/25.
//

import SwiftData
import Foundation
import SwiftUI

enum SignalQuality: String {
    case excellent = "Excellent"
    case good = "Good"
    case poor = "Poor"

    var color: Color {
        switch self {
        case .excellent:
            return .green
        case .good:
            return .orange
        case .poor:
            return .red
        }
    }
    var displayString: String { self.rawValue }
}

@Model
class Iron {
    @Attribute(.unique) var id: UUID
    var name: String?
    var build: String?
    var devSN: String?
    var devID: String?
    @Transient var connectedAt: Date?
    @Transient var connected: Bool = false
    @Transient var rssi: Int = 0
    
    init(uuid: UUID, name: String?, build: String?, devSN: String?, devID: String?) {
        self.id = uuid
        self.name = name
        self.build = build
        self.devSN = devSN
        self.devID = devID
    }

    // Init with rssi
    init(uuid: UUID, rssi: Int, name: String?) {
        self.id = uuid
        self.rssi = rssi
        self.name = name
    }

    var signalQuality: SignalQuality {
        switch rssi {
        case let rssi where rssi >= -60:
            return .excellent
        case -80...(-61):
            return .good
        default:
            return .poor
        }
    }

    var signalColor: Color {
        signalQuality.color
    }

    var signalQualityString: String {
        signalQuality.displayString
    }
}
