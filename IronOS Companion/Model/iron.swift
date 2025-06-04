//
//  iron.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/26/25.
//

import SwiftData
import Foundation
import SwiftUI
import CoreBluetooth

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

enum IronColor: String, Codable {
    case teal
    case red
    case blue
    case liquid
    case pink
    case pride
    case transparent
}

@Model
class Iron {
    @Attribute(.unique) var id: UUID
    var name: String?
    var build: String?
    var devSN: String?
    var devID: String?
    @Attribute var variation: IronColor
    @Transient var connectedAt: Date?
    @Transient var connected: Bool = false
    @Transient var rssi: Int = 0
    @Transient var peripheral: CBPeripheral?
    
    init(uuid: UUID, name: String?, build: String?, devSN: String?, devID: String?) {
        self.id = uuid
        self.name = name
        self.build = build
        self.devSN = devSN
        self.devID = devID
        self.variation = .teal
    }

    // Init for device discovery
    init(uuid: UUID, rssi: Int, name: String?, peripheral: CBPeripheral?) {
        self.id = uuid
        self.rssi = rssi
        self.name = name
        self.peripheral = peripheral
        self.variation = .teal
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
    
    // Iron Image provider
    var image: Image {
        switch variation {
        case .teal:
            return Image("pinecil.default")
        case .red:
            return Image("pinecil.red")
        case .blue:
            return Image("pinecil.blue")
        case .liquid:
            return Image("pinecil.liquid")
        case .pink:
            return Image("pinecil.pink")
        case .pride:
            return Image("pinecil.pride")
        case .transparent:
            return Image("pinecil.transparent")
        }
    }

    var cutImage: Image {
        switch variation {
        case .teal:
            return Image("pinecil.cut.default")
        case .red:
            return Image("pinecil.cut.red")
        case .blue:
            return Image("pinecil.cut.blue")
        case .liquid:
            return Image("pinecil.cut.liquid")
        case .pink:
            return Image("pinecil.cut.pink")
        case .pride:
            return Image("pinecil.cut.pride")
        case .transparent:
            return Image("pinecil.cut.transparent")
        }
    }
}
