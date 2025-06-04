import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var settings: IronSettings?
    @Published var isRetrieving: Bool = false
    @Published var error: Error?
    
    private let settingsManager: IronSettingsManager
    private var debounceTimer: Timer?
    private let debounceInterval: TimeInterval = 0.5 // 500ms debounce
    
    init(settingsManager: IronSettingsManager = IronSettingsManager()) {
        self.settingsManager = settingsManager
    }
    
    func loadSettings() async {
        do {
            isRetrieving = true
            error = nil
            try await settingsManager.getSettings()
            settings = settingsManager.settings
        } catch {
            self.error = error
        }
        isRetrieving = false
    }
    
    // MARK: - Power Settings
    
    func setPowerSource(_ source: PowerSource) async {
        do {
            try await settingsManager.updateSetting(source, for: IronCharacteristicUUIDs.dCInCutoff)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setMinVolCell(_ value: Double) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.minVolCell)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setQCMaxVoltage(_ value: Double) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.qCMaxVoltage)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setPdTimeout(_ value: TimeInterval) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.pdNegTimeout)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Soldering Settings
    
    func setSolderingTemp(_ value: Int) {
        // Update local settings immediately
        if var currentSettings = settings {
            currentSettings.solderingSettings.solderingTemp = value
            settings = currentSettings
        }
        
        // Cancel any existing timer
        debounceTimer?.invalidate()
        
        // Create a new timer
        debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { [weak self] _ in
            // Apply to device asynchronously after debounce
            Task {
                do {
                    try await self?.settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.setTemperature)
                    await self?.loadSettings()
                } catch {
                    self?.error = error
                }
            }
        }
    }
    
    func setBoostTemp(_ value: Int) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.boostTemperature)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setStartupBehavior(_ behavior: StartupBehavior) async {
        do {
            try await settingsManager.updateSetting(behavior, for: IronCharacteristicUUIDs.autoStart)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setTempChangeShort(_ value: Int) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.tempChangeShortStep)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setTempChangeLong(_ value: Int) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.tempChangeLongStep)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setLockButtons(_ behavior: LockingBehavior) async {
        do {
            try await settingsManager.updateSetting(behavior, for: IronCharacteristicUUIDs.lockingMode)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    // MARK: - UI Settings
    
    func setTempUnit(_ unit: TempUnit) async {
        do {
            try await settingsManager.updateSetting(unit, for: IronCharacteristicUUIDs.temperatureUnit)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setDisplayOrientation(_ orientation: DisplayOrientation) async {
        do {
            try await settingsManager.updateSetting(orientation, for: IronCharacteristicUUIDs.displayRotation)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setCooldownFlashing(_ value: Bool) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.cooldownBlink)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setScrollingSpeed(_ speed: ScrollingSpeed) async {
        do {
            try await settingsManager.updateSetting(speed, for: IronCharacteristicUUIDs.scrollingSpeed)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setSwapButtons(_ value: Bool) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.reverseButtonTempChange)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setAnimationSpeed(_ speed: AnimationSpeed) async {
        do {
            try await settingsManager.updateSetting(speed, for: IronCharacteristicUUIDs.animSpeed)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setScreenBrightness(_ value: Int) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.brightness)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setInvertScreen(_ value: Bool) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.colourInversion)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setBootLogoDuration(_ value: Int) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.logoTime)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setDetailedIdleScreen(_ value: Bool) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.advancedIdle)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setDetailedSolderScreen(_ value: Bool) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.advancedSoldering)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Advanced Settings
    
    func setPowerLimit(_ value: Int) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.powerLimit)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setPowerPulse(_ value: Double) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.powerPulsePower)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setPowerPulseDuration(_ value: TimeInterval) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.powerPulseDuration)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setPowerPulseDelay(_ value: TimeInterval) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.powerPulseWait)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Sleep Settings
    
    func setSleepTemp(_ value: Int) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.sleepTemperature)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setSleepTimeout(_ value: Int) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.sleepTimeout)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setShutdownTimeout(_ value: TimeInterval) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.shutdownTimeout)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    func setMotionSensitivity(_ value: Int) async {
        do {
            try await settingsManager.updateSetting(value, for: IronCharacteristicUUIDs.motionSensitivity)
            await loadSettings()
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Save Settings
    
    func saveToFlash() async {
        do {
            try await settingsManager.saveToFlash()
        } catch {
            self.error = error
        }
    }
    
    deinit {
        debounceTimer?.invalidate()
    }
} 