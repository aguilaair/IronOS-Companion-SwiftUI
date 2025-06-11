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
import ActivityKit

public enum SignalQuality: String {
    case excellent = "Excellent"
    case good = "Good"
    case poor = "Poor"

    public var color: Color {
        switch self {
        case .excellent:
            return .green
        case .good:
            return .orange
        case .poor:
            return .red
        }
    }
    public var displayString: String { self.rawValue }
}

public enum IronColor: String, Codable {
    case teal
    case red
    case blue
    case liquid
    case pink
    case pride
    case transparent
}

@Model
public class Iron {
    @Attribute(.unique) public var id: UUID
    public var name: String?
    public var build: String?
    public var devSN: String?
    public var devID: String?
    @Attribute public var variation: IronColor
    @Transient public var connectedAt: Date?
    @Transient public var connected: Bool = false
    @Transient public var rssi: Int = 0
    @Transient public var peripheral: CBPeripheral?
    
    public init(uuid: UUID, name: String?, build: String?, devSN: String?, devID: String?) {
        self.id = uuid
        self.name = name
        self.build = build
        self.devSN = devSN
        self.devID = devID
        self.variation = .teal
    }

    // Init for device discovery
    public init(uuid: UUID, rssi: Int, name: String?, peripheral: CBPeripheral?) {
        self.id = uuid
        self.rssi = rssi
        self.name = name
        self.peripheral = peripheral
        self.variation = .teal
    }

    public var signalQuality: SignalQuality {
        switch rssi {
        case let rssi where rssi >= -60:
            return .excellent
        case -80...(-61):
            return .good
        default:
            return .poor
        }
    }

    public var signalColor: Color {
        signalQuality.color
    }

    public var signalQualityString: String {
        signalQuality.displayString
    }
    
    // Iron Image provider
    public var image: Image {
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

    public var cutImage: Image {
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
