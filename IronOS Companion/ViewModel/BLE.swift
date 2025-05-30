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
    static let shared = BLEManager() // Add shared instance
    
    var myCentralManager: CBCentralManager!
    @Published var isSwitchedOn: Bool = false
    @Published var irons: [Iron] = []
    @Published var connectedIron: Iron?
    @Published var bluetoothPermission: CBManagerAuthorization = CBCentralManager.authorization
    @Published var connectionStatus: ConnectionStatus = .disconnected
    private var isInitialized = false
    private let successFeedback = UINotificationFeedbackGenerator()

    enum ConnectionStatus {
        case disconnected
        case connecting
        case discoveringServices
        case discoveringCharacteristics
        case connected
        case failed
        
        var message: String {
            switch self {
            case .disconnected: return "Disconnected"
            case .connecting: return "Connecting..."
            case .discoveringServices: return "Discovering services..."
            case .discoveringCharacteristics: return "Discovering characteristics..."
            case .connected: return "Connected"
            case .failed: return "Connection failed"
            }
        }
    }

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
        super.init()
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
        self.bluetoothPermission = CBCentralManager.authorization
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("🔵 BLEManager: Bluetooth state updated: \(central.state.rawValue)")
        isSwitchedOn = central.state == .poweredOn
        isInitialized = true
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
        let iron = Iron(uuid: peripheral.identifier, rssi: RSSI.intValue, name: peripheral.name, peripheral: peripheral)
        if !irons.contains(where: { $0.id == iron.id }) {
            DispatchQueue.main.async {
                self.irons.append(iron)
            }
        }
    }

    //Connect to a peripheral
    func connect(to iron: Iron) {
        print("🔵 BLEManager: Connecting to peripheral: \(iron.name ?? "Unknown")")
        connectionStatus = .connecting
        connectedIron = iron
        iron.peripheral!.delegate = self
        myCentralManager.connect(iron.peripheral!, options: nil)
    }

    //Disconnect from a peripheral
    func disconnect(from peripheral: Iron) {
        print("🔵 BLEManager: Disconnecting from peripheral: \(peripheral.name ?? "Unknown")")
        myCentralManager.cancelPeripheralConnection(peripheral.peripheral!)
    }

    // Handle connection events
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("🔵 BLEManager: Connected to peripheral: \(peripheral.name ?? "Unknown")")
        connectionStatus = .discoveringServices
        connectedIron = irons.first(where: { $0.id == peripheral.identifier })
        connectedIron?.connected = true
        connectedIron?.connectedAt = Date()
        
        // Discover services after connection
        print("🔵 BLEManager: Discovering services...")
        peripheral.discoverServices([
            IronServices.liveData,
            IronServices.settings,
            IronServices.bulk
        ])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("🔵 BLEManager: Failed to connect to peripheral: \(peripheral.name ?? "Unknown")")
        if let error = error {
            print("🔵 BLEManager: Connection error: \(error.localizedDescription)")
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("🔵 BLEManager: Disconnected from peripheral: \(peripheral.name ?? "Unknown")")
        if let error = error {
            print("🔵 BLEManager: Disconnection error: \(error.localizedDescription)")
        }
        // Find the iron in the list and set it as disconnected
        if let iron = irons.first(where: { $0.id == peripheral.identifier }) {
            iron.connected = false
            iron.connectedAt = nil
            DispatchQueue.main.async {
                self.connectedIron = nil
            }
        }
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("🔵 BLEManager: Error discovering services: \(error.localizedDescription)")
            connectionStatus = .failed
            return
        }
        
        print("🔵 BLEManager: Discovered services: \(peripheral.services?.map { $0.uuid.uuidString } ?? [])")
        connectionStatus = .discoveringCharacteristics
        
        // Discover characteristics for each service
        peripheral.services?.forEach { service in
            print("🔵 BLEManager: Discovering characteristics for service: \(service.uuid.uuidString)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("🔵 BLEManager: Error discovering characteristics: \(error.localizedDescription)")
            connectionStatus = .failed
            return
        }
        
        print("🔵 BLEManager: Discovered characteristics for service \(service.uuid.uuidString): \(service.characteristics?.map { $0.uuid.uuidString } ?? [])")
        
        // Check if all services have their characteristics discovered
        if peripheral.services?.allSatisfy({ $0.characteristics != nil }) == true {
            connectionStatus = .connected
            successFeedback.notificationOccurred(.success)
        }
        
        // Enable notifications for characteristics that support it
        service.characteristics?.forEach { characteristic in
            if characteristic.properties.contains(.notify) {
                print("🔵 BLEManager: Enabling notifications for characteristic: \(characteristic.uuid.uuidString)")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("🔵 BLEManager: Error receiving value for characteristic \(characteristic.uuid.uuidString): \(error.localizedDescription)")
            return
        }
        
        print("🔵 BLEManager: Received value for characteristic: \(characteristic.uuid.uuidString)")
        // Handle the received data here
    }
}


// Mock BLEManager for previews
class MockBLEManager: BLEManager {
    override init() {
        super.init()
        // Initialize with mock state
        isSwitchedOn = true
        bluetoothPermission = .allowedAlways
        
        
        // Add a mock iron
        let iron = Iron(uuid: UUID(), rssi: -80, name: "Test Iron", peripheral: nil)
        irons.append(iron)
    }
    
    override func connect(to iron: Iron) {
        // Simulate connection process
        connectionStatus = .connecting
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.connectionStatus = .discoveringServices
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.connectionStatus = .discoveringCharacteristics
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.connectionStatus = .connected
        }
    }
    
    override func disconnect(from peripheral: Iron) {
        connectionStatus = .disconnected
    }
}
