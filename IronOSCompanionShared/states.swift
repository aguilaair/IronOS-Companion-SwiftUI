import SwiftUI
import ActivityKit

public struct GradientConfig {
    public let colors: [Color]
    public let isAnimating: Bool
    public let animationDuration: Double
    
    public static func forMode(_ mode: OperatingMode) -> GradientConfig {
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
    
    public static var disconnected: GradientConfig {
        GradientConfig(
            colors: [Color(.systemGray4), Color(.systemBackground)],
            isAnimating: false,
            animationDuration: 0
        )
    }
}

public enum OperatingMode: Int, Codable {
    case idle
    case soldering
    case boost
    case sleeping
    case settings
    case debug
    
    public var displayText: String {
        switch self {
        case .idle: return "Stand-by"
        case .soldering: return "Soldering"
        case .boost: return "Boost"
        case .sleeping: return "Sleeping"
        case .settings: return "Settings"
        case .debug: return "Debug"
        }
    }
    
    public static func fromInt(_ value: Int) -> OperatingMode {
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

public struct IronOSCompanionLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var temperature: Int
        public var setpoint: Int
        public var mode: OperatingMode
        public var handleTemp: Double
        public var power: Int
        
        public init(temperature: Int, setpoint: Int, mode: OperatingMode, handleTemp: Double, power: Int) {
            self.temperature = temperature
            self.setpoint = setpoint
            self.mode = mode
            self.handleTemp = handleTemp
            self.power = power
        }
    }

    public var ironName: String
    public var ironColor: IronColor
    
    public init(ironName: String, ironColor: IronColor) {
        self.ironName = ironName
        self.ironColor = ironColor
    }
} 
