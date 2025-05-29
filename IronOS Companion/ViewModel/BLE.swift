//
//  BLE.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/28/25.
//
// Based on: https://youtu.be/dKUgxZC1y6Q
// Claude Sonnet 3.7 added logging, with the following prompt:
// "Add print statements to all of the functions in the BLEManager class"

import Foundation
import Foundation
import SwiftUI
import CoreBluetooth // Import CoreBluetooth framework for Bluetooth functionalities


class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var myCentralManager: CBCentralManager!
    @Published var isSwitchedOn: Bool = false
    @Published var irons: [Iron] = []
    @Published var connectedIronUUID: UUID?
    @Published var bluetoothPermission: CBManagerAuthorization = CBCentralManager.authorization

    var bluetoothPermissionDescription: String {
        switch bluetoothPermission {
        case .allowedAlways:
            return "Allowed"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .notDetermined:
            return "Not Determined"
        @unknown default:
            return "Unknown"
        }
    }

    // Override the init method
    override init() {
        super.init() // Call the superclass's initializer
        myCentralManager = CBCentralManager(delegate: self, queue: nil) // Initialize the central manager with self as delegate
        self.bluetoothPermission = CBCentralManager.authorization
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isSwitchedOn = central.state == .poweredOn
        bluetoothPermission = CBCentralManager.authorization
        if isSwitchedOn {
            startScanning()
        } else {
            stopScanning()
        }
    }

    func startScanning() {
        print("🔵 BLEManager: Starting scanning")
        myCentralManager.scanForPeripherals(withServices: [
            IronServices.liveData,
            IronServices.settings,
            IronServices.bulk
        ], options: nil)
    }

    func stopScanning() {
        print("🔵 BLEManager: Stopping scanning")
        myCentralManager.stopScan()
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("🔵 BLEManager: Discovered peripheral: \(peripheral.name ?? "Unknown") with RSSI: \(RSSI.intValue)")
        let iron = Iron(uuid: peripheral.identifier, rssi: RSSI.intValue, name: peripheral.name)
        if !irons.contains(where: { $0.id == iron.id }) {
            DispatchQueue.main.async {
                self.irons.append(iron)
            }
        }
    }
    
    
}
