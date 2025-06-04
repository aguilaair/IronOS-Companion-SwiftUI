import Foundation
import CoreBluetooth
import SwiftUI

class IronSettingsManager: ObservableObject {
    @Published var settings: IronSettings?
    @Published var isRetrieving: Bool = false
    
    private let bleManager: BLEManager
    private let successFeedback = UINotificationFeedbackGenerator()
    
    init(bleManager: BLEManager = .shared) {
        self.bleManager = bleManager
    }
    
    // MARK: - Settings Retrieval
    
    func getSettings() async throws {
        guard let _ = bleManager.connectedIron?.peripheral,
              let settingsService = bleManager.getSettingsService else {
            throw BLEError.notConnected
        }
        
        await MainActor.run {
            isRetrieving = true
        }
        
        // Get Power Settings
        let powerSettings = try await getPowerSettings(service: settingsService)
        
        // Get Soldering Settings
        let solderingSettings = try await getSolderingSettings(service: settingsService)
        
        // Get UI Settings
        let uiSettings = try await getUISettings(service: settingsService)
        
        // Get Advanced Settings
        let advancedSettings = try await getAdvancedSettings(service: settingsService)
        
        // Get Sleep Settings
        let sleepSettings = try await getSleepSettings(service: settingsService)
        
        await MainActor.run {
            self.settings = IronSettings(
                powerSettings: powerSettings,
                solderingSettings: solderingSettings,
                uiSettings: uiSettings,
                advancedSettings: advancedSettings,
                sleepSettings: sleepSettings
            )
            isRetrieving = false
        }
    }
    
    // MARK: - Power Settings
    
    private func getPowerSettings(service: CBService) async throws -> PowerSettings {
        let sourceChar = try await getCharacteristic(for: IronCharacteristicUUIDs.dCInCutoff, in: service)
        let minVolChar = try await getCharacteristic(for: IronCharacteristicUUIDs.minVolCell, in: service)
        let qcMaxVoltageChar = try await getCharacteristic(for: IronCharacteristicUUIDs.qCMaxVoltage, in: service)
        let pdTimeoutChar = try await getCharacteristic(for: IronCharacteristicUUIDs.pdNegTimeout, in: service)
        
        let sourceData = try await readValue(from: sourceChar)
        let minVolData = try await readValue(from: minVolChar)
        let qcMaxVoltageData = try await readValue(from: qcMaxVoltageChar)
        let pdTimeoutData = try await readValue(from: pdTimeoutChar)
        
        return PowerSettings(
            dCInCutoff: PowerSource(rawValue: Int(sourceData[0])) ?? .dc,
            minVolCell: Double(minVolData[0]) / 10.0,
            qCMaxVoltage: Double(qcMaxVoltageData[0]) / 10.0,
            pdTimeout: TimeInterval(pdTimeoutData[0]) * 0.1
        )
    }
    
    // MARK: - Soldering Settings
    
    private func getSolderingSettings(service: CBService) async throws -> SolderingSettings {
        let tempChar = try await getCharacteristic(for: IronCharacteristicUUIDs.setTemperature, in: service)
        let boostChar = try await getCharacteristic(for: IronCharacteristicUUIDs.boostTemperature, in: service)
        let startChar = try await getCharacteristic(for: IronCharacteristicUUIDs.autoStart, in: service)
        let tempChangeShrtChar = try await getCharacteristic(for: IronCharacteristicUUIDs.tempChangeShortStep, in: service)
        let tempChangeLngChar = try await getCharacteristic(for: IronCharacteristicUUIDs.tempChangeLongStep, in: service)
        let lockChar = try await getCharacteristic(for: IronCharacteristicUUIDs.lockingMode, in: service)
        
        let tempData = try await readValue(from: tempChar)
        let boostData = try await readValue(from: boostChar)
        let startData = try await readValue(from: startChar)
        let tempChangeShrtData = try await readValue(from: tempChangeShrtChar)
        let tempChangeLngData = try await readValue(from: tempChangeLngChar)
        let lockData = try await readValue(from: lockChar)
        
        return SolderingSettings(
            solderingTemp: Int(tempData[0]) | (Int(tempData[1]) << 8),
            boostTemp: Int(boostData[0]) | (Int(boostData[1]) << 8),
            startUpBehavior: StartupBehavior(rawValue: Int(startData[0])) ?? .off,
            tempChangeShortPress: Int(tempChangeShrtData[0]) | (Int(tempChangeShrtData[1]) << 8),
            tempChangeLongPress: Int(tempChangeLngData[0]) | (Int(tempChangeLngData[1]) << 8),
            allowLockingButtons: LockingBehavior(rawValue: Int(lockData[0])) ?? .off
        )
    }
    
    // MARK: - UI Settings
    
    private func getUISettings(service: CBService) async throws -> UISettings {
        let unitChar = try await getCharacteristic(for: IronCharacteristicUUIDs.temperatureUnit, in: service)
        let orientationChar = try await getCharacteristic(for: IronCharacteristicUUIDs.displayRotation, in: service)
        let cooldownChar = try await getCharacteristic(for: IronCharacteristicUUIDs.cooldownBlink, in: service)
        let scrollSpeedChar = try await getCharacteristic(for: IronCharacteristicUUIDs.scrollingSpeed, in: service)
        let swapKeysChar = try await getCharacteristic(for: IronCharacteristicUUIDs.reverseButtonTempChange, in: service)
        let animSpeedChar = try await getCharacteristic(for: IronCharacteristicUUIDs.animSpeed, in: service)
        let brightnessChar = try await getCharacteristic(for: IronCharacteristicUUIDs.brightness, in: service)
        let invertChar = try await getCharacteristic(for: IronCharacteristicUUIDs.colourInversion, in: service)
        let bootDurChar = try await getCharacteristic(for: IronCharacteristicUUIDs.logoTime, in: service)
        let advIdleChar = try await getCharacteristic(for: IronCharacteristicUUIDs.advancedIdle, in: service)
        let advSolderingChar = try await getCharacteristic(for: IronCharacteristicUUIDs.advancedSoldering, in: service)
        
        let unitData = try await readValue(from: unitChar)
        let orientationData = try await readValue(from: orientationChar)
        let cooldownData = try await readValue(from: cooldownChar)
        let scrollSpeedData = try await readValue(from: scrollSpeedChar)
        let swapKeysData = try await readValue(from: swapKeysChar)
        let animSpeedData = try await readValue(from: animSpeedChar)
        let brightnessData = try await readValue(from: brightnessChar)
        let invertData = try await readValue(from: invertChar)
        let bootDurData = try await readValue(from: bootDurChar)
        let advIdleData = try await readValue(from: advIdleChar)
        let advSolderingData = try await readValue(from: advSolderingChar)
        
        return UISettings(
            tempUnit: TempUnit(rawValue: Int(unitData[0])) ?? .celsius,
            displayOrientation: DisplayOrientation(rawValue: Int(orientationData[0])) ?? .right,
            cooldownFlashing: cooldownData[0] == 1,
            scrollingSpeed: ScrollingSpeed(rawValue: Int(scrollSpeedData[0])) ?? .slow,
            swapPlusMinusKeys: swapKeysData[0] == 1,
            animationSpeed: AnimationSpeed(rawValue: Int(animSpeedData[0])) ?? .off,
            screenBrightness: Int(brightnessData[0]) | (Int(brightnessData[1]) << 8),
            invertScreen: invertData[0] == 1,
            bootLogoDuration: TimeInterval(bootDurData[0]),
            detailedIdleScreen: advIdleData[0] == 1,
            detailedSolderingScreen: advSolderingData[0] == 1
        )
    }
    
    // MARK: - Advanced Settings
    
    private func getAdvancedSettings(service: CBService) async throws -> AdvancedSettings {
        let powerLimitChar = try await getCharacteristic(for: IronCharacteristicUUIDs.powerLimit, in: service)
        let calibrateCJCChar = try await getCharacteristic(for: IronCharacteristicUUIDs.calibrateCJC, in: service)
        let powerPulseChar = try await getCharacteristic(for: IronCharacteristicUUIDs.powerPulsePower, in: service)
        let powerPulseDurChar = try await getCharacteristic(for: IronCharacteristicUUIDs.powerPulseDuration, in: service)
        let powerPulseDelayChar = try await getCharacteristic(for: IronCharacteristicUUIDs.powerPulseWait, in: service)
        
        let powerLimitData = try await readValue(from: powerLimitChar)
        let calibrateCJCData = try await readValue(from: calibrateCJCChar)
        let powerPulseData = try await readValue(from: powerPulseChar)
        let powerPulseDurData = try await readValue(from: powerPulseDurChar)
        let powerPulseDelayData = try await readValue(from: powerPulseDelayChar)
        
        return AdvancedSettings(
            powerLimit: Int(powerLimitData[0]) | (Int(powerLimitData[1]) << 8),
            calibrateCJCNextBoot: calibrateCJCData[0] == 1,
            powerPulse: Double(Int(powerPulseData[0]) | (Int(powerPulseData[1]) << 8)) / 10.0,
            powerPulseDuration: TimeInterval(Int(powerPulseDurData[0]) | (Int(powerPulseDurData[1]) << 8)),
            powerPulseDelay: TimeInterval(Int(powerPulseDelayData[0]) | (Int(powerPulseDelayData[1]) << 8))
        )
    }
    
    // MARK: - Sleep Settings
    
    private func getSleepSettings(service: CBService) async throws -> SleepSettings {
        let sleepTempChar = try await getCharacteristic(for: IronCharacteristicUUIDs.sleepTemperature, in: service)
        let sleepDelayChar = try await getCharacteristic(for: IronCharacteristicUUIDs.sleepTimeout, in: service)
        let shutdownChar = try await getCharacteristic(for: IronCharacteristicUUIDs.shutdownTimeout, in: service)
        let motionSensChar = try await getCharacteristic(for: IronCharacteristicUUIDs.motionSensitivity, in: service)
        
        let sleepTempData = try await readValue(from: sleepTempChar)
        let sleepDelayData = try await readValue(from: sleepDelayChar)
        let shutdownData = try await readValue(from: shutdownChar)
        let motionSensData = try await readValue(from: motionSensChar)
        
        return SleepSettings(
            motionSensitivity: Int(motionSensData[0]),
            sleepTemp: Int(sleepTempData[0]) | (Int(sleepTempData[1]) << 8),
            sleepTimeout: Int(sleepDelayData[0]) | (Int(sleepDelayData[1]) << 8),
            shutdownTimeout: TimeInterval(Int(shutdownData[0]) | (Int(shutdownData[1]) << 8)) * 60
        )
    }
    
    // MARK: - Helper Methods
    
    private func getCharacteristic(for uuid: CBUUID, in service: CBService) async throws -> CBCharacteristic {
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == uuid }) else {
            throw BLEError.characteristicNotFound
        }
        return characteristic
    }
    
    private func readValue(from characteristic: CBCharacteristic) async throws -> Data {
        return try await bleManager.readValue(for: characteristic)
    }
    
    // MARK: - Settings Update Methods
    
    func updateSetting<T>(_ value: T, for characteristic: CBUUID) async throws {
        guard let service = bleManager.getSettingsService,
              let characteristic = service.characteristics?.first(where: { $0.uuid == characteristic }) else {
            throw BLEError.notConnected
        }
        
        var data: Data
        switch value {
        case let intValue as Int:
            data = withUnsafeBytes(of: UInt16(intValue).littleEndian) { Data($0) }
        case let doubleValue as Double:
            data = withUnsafeBytes(of: UInt16(Int(doubleValue * 10)).littleEndian) { Data($0) }
        case let boolValue as Bool:
            data = Data([boolValue ? 1 : 0])
        case let enumValue as any RawRepresentable:
            data = Data([UInt8(enumValue.rawValue as! Int)])
        default:
            throw BLEError.invalidValueType
        }
        
        try await bleManager.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func saveToFlash() async throws {
        guard let service = bleManager.getSettingsService,
              let characteristic = service.characteristics?.first(where: { $0.uuid == IronCharacteristicUUIDs.saveToFlash }) else {
            throw BLEError.notConnected
        }
        
        let data = Data([1])
        try await bleManager.writeValue(data, for: characteristic, type: .withResponse)
    }
}

// MARK: - Errors

enum BLEError: Error {
    case notConnected
    case characteristicNotFound
    case readFailed
    case writeFailed
    case invalidValueType
} 