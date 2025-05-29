//
//  settings.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/26/25.
//

import Foundation

import Foundation

// MARK: - Enums
enum PowerSource: Int, Codable {
    case dc
    case threeCell
    case fourCell
    case fiveCell
    case sixCell
}

enum StartupBehavior: Int, Codable {
    case off
    case heatToSetpoint
    case standbyUntilMoved
    case standbyWithoutHeating
}

enum LockingBehavior: Int, Codable {
    case off
    case boostOnly
    case full
}

enum TempUnit: Int, Codable {
    case celsius
    case fahrenheit
}

enum DisplayOrientation: Int, Codable {
    case right
    case left
    case auto
}

enum ScrollingSpeed: Int, Codable {
    case slow
    case fast
}

enum AnimationSpeed: Int, Codable {
    case off
    case slow
    case medium
    case fast
}

// MARK: - Main Settings Struct
struct IronSettings: Codable, Equatable {
    var powerSettings: PowerSettings
    var solderingSettings: SolderingSettings
    var uiSettings: UISettings
    var advancedSettings: AdvancedSettings
    var unusedSettings: UnusedSettings?
    var sleepSettings: SleepSettings
}

// MARK: - Power Settings
struct PowerSettings: Codable, Equatable {
    var dCInCutoff: PowerSource
    var minVolCell: Double
    var qCMaxVoltage: Double
    var pdTimeout: TimeInterval
}

// MARK: - Sleep Settings
struct SleepSettings: Codable, Equatable {
    var motionSensitivity: Int
    var sleepTemp: Int
    var sleepTimeout: Int
    var shutdownTimeout: TimeInterval
}

// MARK: - Soldering Settings
struct SolderingSettings: Codable, Equatable {
    var solderingTemp: Int
    var boostTemp: Int
    var startUpBehavior: StartupBehavior
    var tempChangeShortPress: Int
    var tempChangeLongPress: Int
    var allowLockingButtons: LockingBehavior
}

// MARK: - UI Settings
struct UISettings: Codable, Equatable {
    var tempUnit: TempUnit
    var displayOrientation: DisplayOrientation
    var cooldownFlashing: Bool
    var scrollingSpeed: ScrollingSpeed
    var swapPlusMinusKeys: Bool
    var animationSpeed: AnimationSpeed
    var screenBrightness: Int
    var invertScreen: Bool
    var bootLogoDuration: TimeInterval
    var detailedIdleScreen: Bool
    var detailedSolderingScreen: Bool
}

// MARK: - Advanced Settings
struct AdvancedSettings: Codable, Equatable {
    var powerLimit: Int
    var calibrateCJCNextBoot: Bool
    var powerPulse: Double
    var powerPulseDuration: TimeInterval
    var powerPulseDelay: TimeInterval
}

// MARK: - Unused Settings (need to check where they are used)
struct UnusedSettings: Codable, Equatable {
    var accelMissingWarningCount: Int
    var animLoop: Int
    var calibrationOffset: Int
    var hallEffectSensitivity: Int
    var pDMissingWarningCount: Int
    var uiLanguage: Int
}
