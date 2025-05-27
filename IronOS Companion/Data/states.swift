//
//  states.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/26/25.
//

enum OperatingMode: Int, Codable {
    case idle
    case soldering
    case boost
    case sleeping
    case settings
    case debug
    
    static func fromInt(_ value: Int) -> OperatingMode {
        switch value {
        case 0: return .idle
        case 1: return .soldering
        case 2: return .boost
        case 3: return .sleeping
        case 4: return .settings
        case 5: return .debug
        default: return .idle
        }
    }
}
