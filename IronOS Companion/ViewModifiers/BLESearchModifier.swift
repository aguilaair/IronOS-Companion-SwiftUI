//
//  BLESearchModifier.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/28/25.
//

import SwiftUI
import CoreBluetooth

struct BLESearchModifier: ViewModifier {
    @Binding var discoveredDevices: [CBPeripheral]
    @Binding var isScanning: Bool
    @State private var centralManager: CBCentralManager?
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Service UUIDs from your uuids.swift
    private let settingsServiceUUID = CBUUID(string: IronServices.settings)
    private let bulkServiceUUID = CBUUID(string: IronServices.bulk)
    
    init(discoveredDevices: Binding<[CBPeripheral]>, isScanning: Binding<Bool>) {
        self._discoveredDevices = discoveredDevices
        self._isScanning = isScanning
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                setupBluetoothManager()
            }
            .onDisappear {
                stopScanning()
            }
            .alert("Bluetooth Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
    }
    
    private func setupBluetoothManager() {
        centralManager = CBCentralManager(delegate: BLESearchDelegate(
            onStateUpdate: { state in
                switch state {
                case .poweredOn:
                    startScanning()
                case .poweredOff:
                    showError(message: "Please turn on Bluetooth to search for devices")
                case .unauthorized:
                    showError(message: "Bluetooth permission is required")
                case .unsupported:
                    showError(message: "Bluetooth is not supported on this device")
                default:
                    break
                }
            },
            onDeviceDiscovered: { peripheral in
                if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
                    discoveredDevices.append(peripheral)
                }
            }
        ), queue: nil)
    }
    
    private func startScanning() {
        guard let centralManager = centralManager,
              centralManager.state == .poweredOn,
              !isScanning else { return }
        
        isScanning = true
        // Scan for devices with both service UUIDs
        centralManager.scanForPeripherals(
            withServices: [settingsServiceUUID, bulkServiceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }
    
    private func stopScanning() {
        guard let centralManager = centralManager else { return }
        centralManager.stopScan()
        isScanning = false
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

// Delegate class to handle Bluetooth events
private class BLESearchDelegate: NSObject, CBCentralManagerDelegate {
    let onStateUpdate: (CBManagerState) -> Void
    let onDeviceDiscovered: (CBPeripheral) -> Void
    
    init(onStateUpdate: @escaping (CBManagerState) -> Void,
         onDeviceDiscovered: @escaping (CBPeripheral) -> Void) {
        self.onStateUpdate = onStateUpdate
        self.onDeviceDiscovered = onDeviceDiscovered
        super.init()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        onStateUpdate(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                       advertisementData: [String : Any], rssi RSSI: NSNumber) {
        onDeviceDiscovered(peripheral)
    }
}

extension View {
    func searchBLEDevices(discoveredDevices: Binding<[CBPeripheral]>, isScanning: Binding<Bool>) -> some View {
        modifier(BLESearchModifier(discoveredDevices: discoveredDevices, isScanning: isScanning))
    }
} 