//
//  states.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/26/25.
//

import SwiftUI

struct GradientConfig {
    let colors: [Color]
    let isAnimating: Bool
    let animationDuration: Double
    
    static func forMode(_ mode: OperatingMode) -> GradientConfig {
        switch mode {
        case .idle:
            return GradientConfig(
                colors: [Color.green.opacity(0.4), Color(.systemBackground)],
                isAnimating: false,
                animationDuration: 0
            )
        case .soldering:
            return GradientConfig(
                colors: [Color.orange.opacity(0.4), Color(.systemBackground)],
                isAnimating: true,
                animationDuration: 2.0
            )
        case .boost:
            return GradientConfig(
                colors: [Color.red.opacity(0.4), Color(.systemBackground)],
                isAnimating: true,
                animationDuration: 0.5
            )
        case .sleeping:
            return GradientConfig(
                colors: [Color.purple.opacity(0.4), Color(.systemBackground)],
                isAnimating: true,
                animationDuration: 3.0
            )
        case .settings:
            return GradientConfig(
                colors: [Color.teal.opacity(0.4), Color(.systemBackground)],
                isAnimating: false,
                animationDuration: 0
            )
        case .debug:
            return GradientConfig(
                colors: [Color.yellow.opacity(0.4), Color(.systemBackground)],
                isAnimating: false,
                animationDuration: 0
            )
        }
    }
    
    static var disconnected: GradientConfig {
        GradientConfig(
            colors: [Color(.systemGray4), Color(.systemBackground)],
            isAnimating: false,
            animationDuration: 0
        )
    }
}

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
