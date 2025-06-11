//
//  SettingsSheet.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 6/11/25.
//
// Claude Sonnet 3.7 added the repetitive code to show the settings in the sheet, with the following prompt:
// "Let's implement the settings page. I want it to be a sheet. Please use standard iOS pickers to implmenet the UI"
// Claude Sonnet 3.7 added MARKs and comments


import SwiftUI

/// A sheet view that displays and manages all device settings.
/// This view is organized into tabs for different categories of settings:
/// - Soldering settings
/// - Sleep settings
/// - Power settings
/// - UI settings
struct SettingsSheet: View {
    // MARK: - Environment & State
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var selectedTab = 0
    @State private var isSaving = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                Picker("Settings", selection: $selectedTab) {
                    Text("Soldering").tag(0)
                    Text("Sleep").tag(1)
                    Text("Power").tag(2)
                    Text("UI").tag(3)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if settingsViewModel.isRetrieving {
                    ProgressView("Loading settings...")
                } else if let error = settingsViewModel.error {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                } else if let settings = settingsViewModel.settings {
                    TabView(selection: $selectedTab) {
                        SolderingSettingsView(settings: settings, viewModel: settingsViewModel)
                            .tag(0)
                        SleepSettingsView(settings: settings, viewModel: settingsViewModel)
                            .tag(1)
                        PowerSettingsView(settings: settings, viewModel: settingsViewModel)
                            .tag(2)
                        UISettingsView(settings: settings, viewModel: settingsViewModel)
                            .tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                } else {
                    Text("No settings available")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            isSaving = true
                            await settingsViewModel.saveToFlash()
                            isSaving = false
                            dismiss()
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(settingsViewModel.settings == nil || isSaving)
                }
            }
        }
    }
}

/// A view that displays and manages soldering-related settings.
struct SolderingSettingsView: View {
    // MARK: - Properties
    let settings: IronSettings
    let viewModel: SettingsViewModel
    
    // MARK: - Body
    var body: some View {
        Form {
            Section("Temperature") {
                HStack {
                    Text("Soldering Temp")
                    Spacer()
                    Stepper("\(settings.solderingSettings.solderingTemp)°", value: Binding(
                        get: { settings.solderingSettings.solderingTemp },
                        set: { viewModel.setSolderingTemp($0) }
                    ), in: 180...480)
                }
                
                HStack {
                    Text("Boost Temp")
                    Spacer()
                    Stepper("\(settings.solderingSettings.boostTemp)°", value: Binding(
                        get: { settings.solderingSettings.boostTemp },
                        set: { viewModel.setBoostTemp($0) }
                    ), in: 180...480)
                }
            }
            
            Section("Temperature Change") {
                HStack {
                    Text("Short Press")
                    Spacer()
                    Stepper("\(settings.solderingSettings.tempChangeShortPress)°", value: Binding(
                        get: { settings.solderingSettings.tempChangeShortPress },
                        set: { viewModel.setTempChangeShortPress($0) }
                    ), in: 1...50)
                }
                
                HStack {
                    Text("Long Press")
                    Spacer()
                    Stepper("\(settings.solderingSettings.tempChangeLongPress)°", value: Binding(
                        get: { settings.solderingSettings.tempChangeLongPress },
                        set: { viewModel.setTempChangeLongPress($0) }
                    ), in: 1...50)
                }
            }
            
            Section("Startup") {
                Picker("Startup Behavior", selection: Binding(
                    get: { settings.solderingSettings.startUpBehavior },
                    set: { viewModel.setStartupBehavior($0) }
                )) {
                    Text("Off").tag(StartupBehavior.off)
                    Text("Heat to Setpoint").tag(StartupBehavior.heatToSetpoint)
                    Text("Standby Until Moved").tag(StartupBehavior.standbyUntilMoved)
                    Text("Standby Without Heating").tag(StartupBehavior.standbyWithoutHeating)
                }
            }
            
            Section("Locking") {
                Picker("Button Locking", selection: Binding(
                    get: { settings.solderingSettings.allowLockingButtons },
                    set: { viewModel.setLockingBehavior($0) }
                )) {
                    Text("Off").tag(LockingBehavior.off)
                    Text("Boost Only").tag(LockingBehavior.boostOnly)
                    Text("Full").tag(LockingBehavior.full)
                }
            }
        }
    }
}

/// A view that displays and manages sleep-related settings.
struct SleepSettingsView: View {
    // MARK: - Properties
    let settings: IronSettings
    let viewModel: SettingsViewModel
    
    // MARK: - Body
    var body: some View {
        Form {
            Section("Sleep Temperature") {
                HStack {
                    Text("Sleep Temp")
                    Spacer()
                    Stepper("\(settings.sleepSettings.sleepTemp)°", value: Binding(
                        get: { settings.sleepSettings.sleepTemp },
                        set: { viewModel.setSleepTemp($0) }
                    ), in: 0...480)
                }
            }
            
            Section("Sleep Timeout") {
                HStack {
                    Text("Sleep Timeout")
                    Spacer()
                    Stepper("\(settings.sleepSettings.sleepTimeout)s", value: Binding(
                        get: { settings.sleepSettings.sleepTimeout },
                        set: { viewModel.setSleepTimeout($0) }
                    ), in: 10...600)
                }
            }
            
            Section("Motion Sensitivity") {
                HStack {
                    Text("Motion Sensitivity")
                    Spacer()
                    Stepper("\(settings.sleepSettings.motionSensitivity)", value: Binding(
                        get: { settings.sleepSettings.motionSensitivity },
                        set: { viewModel.setMotionSensitivity($0) }
                    ), in: 0...9)
                }
            }
            
            Section("Shutdown") {
                HStack {
                    Text("Shutdown Timeout")
                    Spacer()
                    Stepper("\(Int(settings.sleepSettings.shutdownTimeout))s", value: Binding(
                        get: { Int(settings.sleepSettings.shutdownTimeout) },
                        set: { viewModel.setShutdownTimeout(TimeInterval($0)) }
                    ), in: 0...3600)
                }
            }
        }
    }
}

/// A view that displays and manages power-related settings.
struct PowerSettingsView: View {
    // MARK: - Properties
    let settings: IronSettings
    let viewModel: SettingsViewModel
    
    // MARK: - Body
    var body: some View {
        Form {
            Section("Power Source") {
                Picker("Power Source", selection: Binding(
                    get: { settings.powerSettings.dCInCutoff },
                    set: { viewModel.setPowerSource($0) }
                )) {
                    Text("DC").tag(PowerSource.dc)
                    Text("3 Cell").tag(PowerSource.threeCell)
                    Text("4 Cell").tag(PowerSource.fourCell)
                    Text("5 Cell").tag(PowerSource.fiveCell)
                    Text("6 Cell").tag(PowerSource.sixCell)
                }
            }
            
            Section("Voltage") {
                HStack {
                    Text("Min Cell Voltage")
                    Spacer()
                    Stepper(String(format: "%.1fV", settings.powerSettings.minVolCell), value: Binding(
                        get: { Int(settings.powerSettings.minVolCell * 10) },
                        set: { viewModel.setMinVolCell(Double($0) / 10.0) }
                    ), in: 20...35)
                }
                
                HStack {
                    Text("QC Max Voltage")
                    Spacer()
                    Stepper(String(format: "%.1fV", settings.powerSettings.qCMaxVoltage), value: Binding(
                        get: { Int(settings.powerSettings.qCMaxVoltage * 10) },
                        set: { viewModel.setQCMaxVoltage(Double($0) / 10.0) }
                    ), in: 50...200)
                }
            }
            
            Section("USB-C") {
                HStack {
                    Text("PD Timeout")
                    Spacer()
                    Stepper("\(Int(settings.powerSettings.pdTimeout))s", value: Binding(
                        get: { Int(settings.powerSettings.pdTimeout) },
                        set: { viewModel.setPDTimeout(TimeInterval($0)) }
                    ), in: 0...60)
                }
            }
        }
    }
}

/// A view that displays and manages UI-related settings.
struct UISettingsView: View {
    // MARK: - Properties
    let settings: IronSettings
    let viewModel: SettingsViewModel
    
    // MARK: - Body
    var body: some View {
        Form {
            Section("Display") {
                Picker("Temperature Unit", selection: Binding(
                    get: { settings.uiSettings.tempUnit },
                    set: { viewModel.setTempUnit($0) }
                )) {
                    Text("Celsius").tag(TempUnit.celsius)
                    Text("Fahrenheit").tag(TempUnit.fahrenheit)
                }
                
                Picker("Display Orientation", selection: Binding(
                    get: { settings.uiSettings.displayOrientation },
                    set: { viewModel.setDisplayOrientation($0) }
                )) {
                    Text("Right").tag(DisplayOrientation.right)
                    Text("Left").tag(DisplayOrientation.left)
                    Text("Auto").tag(DisplayOrientation.auto)
                }
                
                Toggle("Invert Screen", isOn: Binding(
                    get: { settings.uiSettings.invertScreen },
                    set: { viewModel.setInvertScreen($0) }
                ))
            }
            
            Section("Animation") {
                Picker("Animation Speed", selection: Binding(
                    get: { settings.uiSettings.animationSpeed },
                    set: { viewModel.setAnimationSpeed($0) }
                )) {
                    Text("Off").tag(AnimationSpeed.off)
                    Text("Slow").tag(AnimationSpeed.slow)
                    Text("Medium").tag(AnimationSpeed.medium)
                    Text("Fast").tag(AnimationSpeed.fast)
                }
                
                Picker("Scrolling Speed", selection: Binding(
                    get: { settings.uiSettings.scrollingSpeed },
                    set: { viewModel.setScrollingSpeed($0) }
                )) {
                    Text("Slow").tag(ScrollingSpeed.slow)
                    Text("Fast").tag(ScrollingSpeed.fast)
                }
            }
            
            Section("Screen") {
                HStack {
                    Text("Brightness")
                    Spacer()
                    Stepper("\(settings.uiSettings.screenBrightness)%", value: Binding(
                        get: { settings.uiSettings.screenBrightness },
                        set: { viewModel.setScreenBrightness($0) }
                    ), in: 0...100)
                }
                
                Toggle("Cooldown Flashing", isOn: Binding(
                    get: { settings.uiSettings.cooldownFlashing },
                    set: { viewModel.setCooldownFlashing($0) }
                ))
                
                Toggle("Swap +/- Keys", isOn: Binding(
                    get: { settings.uiSettings.swapPlusMinusKeys },
                    set: { viewModel.setSwapPlusMinusKeys($0) }
                ))
            }
            
            Section("Boot") {
                HStack {
                    Text("Boot Logo Duration")
                    Spacer()
                    Stepper("\(Int(settings.uiSettings.bootLogoDuration))s", value: Binding(
                        get: { Int(settings.uiSettings.bootLogoDuration) },
                        set: { viewModel.setBootLogoDuration(TimeInterval($0)) }
                    ), in: 0...10)
                }
            }
            
            Section("Screens") {
                Toggle("Detailed Idle Screen", isOn: Binding(
                    get: { settings.uiSettings.detailedIdleScreen },
                    set: { viewModel.setDetailedIdleScreen($0) }
                ))
                
                Toggle("Detailed Soldering Screen", isOn: Binding(
                    get: { settings.uiSettings.detailedSolderingScreen },
                    set: { viewModel.setDetailedSolderingScreen($0) }
                ))
            }
        }
    }
}

#Preview {
    SettingsSheet()
        .environmentObject(BLEManager.shared)
} 
