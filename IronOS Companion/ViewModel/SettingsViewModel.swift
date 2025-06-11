//
//  SettingsViewModel.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 6/11/25.
//
// Claude Sonnet 3.7 added the repetitive code to get the settings from the characteristic, with the following prompt:
// "Give me a function that gets the settings from the characteristic based on the uuids: [...]"

import Foundation
import SwiftUI
import Combine
import CoreBluetooth

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var settings: IronSettings?
    @Published var isRetrieving = false
    @Published var isSaving = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    private let bleManager = BLEManager.shared
    private let settingsManager: IronSettingsManager
    
    init(settingsManager: IronSettingsManager = IronSettingsManager()) {
        self.settingsManager = settingsManager
        
        // Subscribe to BLE manager's connected iron changes
        bleManager.$connectedIron
            .sink { [weak self] iron in
                if iron != nil {
                    Task {
                        await self?.getSettings()
                    }
                } else {
                    self?.settings = nil
                }
            }
            .store(in: &cancellables)
        
        // Subscribe to settings manager's settings changes
        settingsManager.$settings
            .sink { [weak self] settings in
                self?.settings = settings
            }
            .store(in: &cancellables)
        
        settingsManager.$isRetrieving
            .sink { [weak self] isRetrieving in
                self?.isRetrieving = isRetrieving
            }
            .store(in: &cancellables)
    }
    
    func getSettings() async {
        do {
            try await settingsManager.getSettings()
        } catch {
            self.error = error
        }
    }
    
    func saveToFlash() async {
        do {
            isSaving = true
            try await settingsManager.saveToFlash()
            isSaving = false
        } catch {
            self.error = error
            isSaving = false
        }
    }
    
    // MARK: - Settings Setters
    
    private func updateSetting<T>(_ value: T, for characteristic: CBUUID, updateLocal: (inout IronSettings) -> Void) {
        guard var currentSettings = settings else { return }
        updateLocal(&currentSettings)
        self.settings = currentSettings
        
        // Store the current settings for potential revert
        let originalSettings = currentSettings
        
        Task {
            do {
                try await settingsManager.updateSetting(value, for: characteristic)
            } catch {
                print("Error updating setting: \(error.localizedDescription)")
                // Revert the local change if the write failed
                await MainActor.run {
                    self.settings = originalSettings
                }
            }
        }
    }
    
    func setSolderingTemp(_ temp: Int) {
        updateSetting(temp, for: IronCharacteristicUUIDs.setTemperature) { settings in
            settings.solderingSettings.solderingTemp = temp
        }
    }
    
    func setBoostTemp(_ temp: Int) {
        updateSetting(temp, for: IronCharacteristicUUIDs.boostTemperature) { settings in
            settings.solderingSettings.boostTemp = temp
        }
    }
    
    func setTempChangeShortPress(_ value: Int) {
        updateSetting(value, for: IronCharacteristicUUIDs.tempChangeShortStep) { settings in
            settings.solderingSettings.tempChangeShortPress = value
        }
    }
    
    func setTempChangeLongPress(_ value: Int) {
        updateSetting(value, for: IronCharacteristicUUIDs.tempChangeLongStep) { settings in
            settings.solderingSettings.tempChangeLongPress = value
        }
    }
    
    func setStartupBehavior(_ behavior: StartupBehavior) {
        updateSetting(behavior, for: IronCharacteristicUUIDs.autoStart) { settings in
            settings.solderingSettings.startUpBehavior = behavior
        }
    }
    
    func setLockingBehavior(_ behavior: LockingBehavior) {
        updateSetting(behavior, for: IronCharacteristicUUIDs.lockingMode) { settings in
            settings.solderingSettings.allowLockingButtons = behavior
        }
    }
    
    func setSleepTemp(_ temp: Int) {
        updateSetting(temp, for: IronCharacteristicUUIDs.sleepTemperature) { settings in
            settings.sleepSettings.sleepTemp = temp
        }
    }
    
    func setSleepTimeout(_ timeout: Int) {
        updateSetting(timeout, for: IronCharacteristicUUIDs.sleepTimeout) { settings in
            settings.sleepSettings.sleepTimeout = timeout
        }
    }
    
    func setMotionSensitivity(_ sensitivity: Int) {
        updateSetting(sensitivity, for: IronCharacteristicUUIDs.motionSensitivity) { settings in
            settings.sleepSettings.motionSensitivity = sensitivity
        }
    }
    
    func setShutdownTimeout(_ timeout: TimeInterval) {
        updateSetting(Int(timeout / 60), for: IronCharacteristicUUIDs.shutdownTimeout) { settings in
            settings.sleepSettings.shutdownTimeout = timeout
        }
    }
    
    func setPowerSource(_ source: PowerSource) {
        updateSetting(source, for: IronCharacteristicUUIDs.dCInCutoff) { settings in
            settings.powerSettings.dCInCutoff = source
        }
    }
    
    func setMinVolCell(_ voltage: Double) {
        updateSetting(voltage, for: IronCharacteristicUUIDs.minVolCell) { settings in
            settings.powerSettings.minVolCell = voltage
        }
    }
    
    func setQCMaxVoltage(_ voltage: Double) {
        updateSetting(voltage, for: IronCharacteristicUUIDs.qCMaxVoltage) { settings in
            settings.powerSettings.qCMaxVoltage = voltage
        }
    }
    
    func setPDTimeout(_ timeout: TimeInterval) {
        updateSetting(Int(timeout * 10), for: IronCharacteristicUUIDs.pdNegTimeout) { settings in
            settings.powerSettings.pdTimeout = timeout
        }
    }
    
    func setTempUnit(_ unit: TempUnit) {
        updateSetting(unit, for: IronCharacteristicUUIDs.temperatureUnit) { settings in
            settings.uiSettings.tempUnit = unit
        }
    }
    
    func setDisplayOrientation(_ orientation: DisplayOrientation) {
        updateSetting(orientation, for: IronCharacteristicUUIDs.displayRotation) { settings in
            settings.uiSettings.displayOrientation = orientation
        }
    }
    
    func setInvertScreen(_ invert: Bool) {
        updateSetting(invert, for: IronCharacteristicUUIDs.colourInversion) { settings in
            settings.uiSettings.invertScreen = invert
        }
    }
    
    func setAnimationSpeed(_ speed: AnimationSpeed) {
        updateSetting(speed, for: IronCharacteristicUUIDs.animSpeed) { settings in
            settings.uiSettings.animationSpeed = speed
        }
    }
    
    func setScrollingSpeed(_ speed: ScrollingSpeed) {
        updateSetting(speed, for: IronCharacteristicUUIDs.scrollingSpeed) { settings in
            settings.uiSettings.scrollingSpeed = speed
        }
    }
    
    func setScreenBrightness(_ brightness: Int) {
        updateSetting(brightness, for: IronCharacteristicUUIDs.brightness) { settings in
            settings.uiSettings.screenBrightness = brightness
        }
    }
    
    func setCooldownFlashing(_ enabled: Bool) {
        updateSetting(enabled, for: IronCharacteristicUUIDs.cooldownBlink) { settings in
            settings.uiSettings.cooldownFlashing = enabled
        }
    }
    
    func setSwapPlusMinusKeys(_ swap: Bool) {
        updateSetting(swap, for: IronCharacteristicUUIDs.reverseButtonTempChange) { settings in
            settings.uiSettings.swapPlusMinusKeys = swap
        }
    }
    
    func setBootLogoDuration(_ duration: TimeInterval) {
        updateSetting(Int(duration), for: IronCharacteristicUUIDs.logoTime) { settings in
            settings.uiSettings.bootLogoDuration = duration
        }
    }
    
    func setDetailedIdleScreen(_ detailed: Bool) {
        updateSetting(detailed, for: IronCharacteristicUUIDs.advancedIdle) { settings in
            settings.uiSettings.detailedIdleScreen = detailed
        }
    }
    
    func setDetailedSolderingScreen(_ detailed: Bool) {
        updateSetting(detailed, for: IronCharacteristicUUIDs.advancedSoldering) { settings in
            settings.uiSettings.detailedSolderingScreen = detailed
        }
    }
} 
