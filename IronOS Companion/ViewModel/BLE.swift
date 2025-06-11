//
//  BLE.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/28/25.
//
// Based on: https://youtu.be/dKUgxZC1y6Q, heavily modified to support BLE data streaming
// Claude Sonnet 3.7 added logging, with the following prompt:
// "Add print statements to all of the functions in the BLEManager class"
// Claude Sonnet 3.7 added SwiftData to the class, with the following prompt:
// "Give me access to the modelContext in this class"

import Foundation
import Foundation
import SwiftUI
import CoreBluetooth // Import CoreBluetooth framework for Bluetooth functionalities
import SwiftData
import ActivityKit
import IronOSCompanionShared

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = BLEManager() // Add shared instance
    
    var myCentralManager: CBCentralManager!
    @Published var isSwitchedOn: Bool = false
    @Published var irons: [Iron] = []
    @Published var connectedIron: Iron?
    @Published var bluetoothPermission: CBManagerAuthorization = CBCentralManager.authorization
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var latestData: IronData?
    @Published var historicalData: [IronData] = []
    private var isInitialized = false
    private let successFeedback = UINotificationFeedbackGenerator()
    private var bulkDataCharacteristic: CBCharacteristic?
    private var buildCharacteristic: CBCharacteristic?
    private var bulkService: CBService?
    private var liveService: CBService?
    private var settingsService: CBService?
    private var dataUpdateTimer: Timer?
    private var pendingReadContinuations: [CBCharacteristic: CheckedContinuation<Data, Error>] = [:]
    private var pendingWriteContinuations: [CBCharacteristic: CheckedContinuation<Void, Error>] = [:]
    var modelContext: ModelContext?
    private var liveActivity: Activity<IronOSCompanionLiveActivityAttributes>?
    
    private var state: AppState? {
        guard let context = modelContext else { return nil }
        let descriptor = FetchDescriptor<AppState>()
        return try? context.fetch(descriptor).first
    }

    // Public getter for settingsService
    var getSettingsService: CBService? {
        return settingsService
    }

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
        
        // Check if we already have this device in our list
        if let existingIron = irons.first(where: { $0.id == peripheral.identifier }) {
            // Update the existing iron's properties
            existingIron.rssi = RSSI.intValue
            existingIron.peripheral = peripheral
            if let name = peripheral.name {
                existingIron.name = name
            }
            // Ensure we preserve the variation
            let variation = existingIron.variation
            existingIron.variation = variation
        } else {
            // Check if this iron exists in saved irons
            if let savedIron = state?.savedIrons.first(where: { $0.id == peripheral.identifier }) {
                // Update the saved iron with current discovery info
                savedIron.rssi = RSSI.intValue
                savedIron.peripheral = peripheral
                DispatchQueue.main.async {
                    self.irons.append(savedIron)
                }
            } else {
                // Create a new iron instance if not found in saved irons
                let iron = Iron(uuid: peripheral.identifier, rssi: RSSI.intValue, name: peripheral.name, peripheral: peripheral)
                DispatchQueue.main.async {
                    self.irons.append(iron)
                }
            }
        }
    }

    // MARK: - Connection Management
    
    func attemptConnectToLastIron(iron: Iron) {
        print("🔵 BLEManager: Attempting to connect to last iron with UUID: \(iron.id)")
        if let iron = irons.first(where: { $0.id == iron.id }) {
            connect(to: iron)
        } else {
            print("🔵 BLEManager: Last connected iron not found in discovered devices")
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
        dataUpdateTimer?.invalidate()
        dataUpdateTimer = nil
        myCentralManager.cancelPeripheralConnection(peripheral.peripheral!)
    }

    // Handle connection events
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("🔵 BLEManager: Connected to peripheral: \(peripheral.name ?? "Unknown")")
        connectionStatus = .discoveringServices
        connectedIron = irons.first(where: { $0.id == peripheral.identifier })
        connectedIron?.connected = true
        connectedIron?.connectedAt = Date()
        
        // Start Live Activity
        startLiveActivity()
        
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
        
        // End Live Activity
        endLiveActivity()
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
        
        // Store references to services
        peripheral.services?.forEach { service in
            switch service.uuid {
            case IronServices.bulk:
                bulkService = service
            case IronServices.liveData:
                liveService = service
            case IronServices.settings:
                settingsService = service
            default:
                break
            }
        }
        
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
        
        // Store references to important characteristics
        service.characteristics?.forEach { characteristic in
            switch characteristic.uuid {
            case IronCharacteristicUUIDs.bulkLiveData:
                bulkDataCharacteristic = characteristic
                // Read the first characteristic immediately
                peripheral.readValue(for: characteristic)
            case IronCharacteristicUUIDs.build:
                buildCharacteristic = characteristic
                peripheral.readValue(for: characteristic)
            default:
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
        
        // Check if all services have their characteristics discovered
        if peripheral.services?.allSatisfy({ $0.characteristics != nil }) == true {
            connectionStatus = .connected
            successFeedback.notificationOccurred(.success)
            startDataUpdates()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("🔵 BLEManager: Error receiving value for characteristic \(characteristic.uuid.uuidString): \(error.localizedDescription)")
            if let continuation = pendingReadContinuations[characteristic] {
                continuation.resume(throwing: error)
                pendingReadContinuations.removeValue(forKey: characteristic)
            }
            return
        }
        
        guard let data = characteristic.value else {
            print("🔵 BLEManager: No data received for characteristic: \(characteristic.uuid.uuidString)")
            if let continuation = pendingReadContinuations[characteristic] {
                continuation.resume(throwing: BLEError.readFailed)
                pendingReadContinuations.removeValue(forKey: characteristic)
            }
            return
        }
        
        if let continuation = pendingReadContinuations[characteristic] {
            continuation.resume(returning: data)
            pendingReadContinuations.removeValue(forKey: characteristic)
        }
        
        switch characteristic.uuid {
        case IronCharacteristicUUIDs.bulkLiveData:
            handleBulkData(data)
        case IronCharacteristicUUIDs.build:
            handleBuildData(data)
        default:
            print("🔵 BLEManager: Received value for characteristic: \(characteristic.uuid.uuidString)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("🔵 BLEManager: Error writing value for characteristic \(characteristic.uuid.uuidString): \(error.localizedDescription)")
            if let continuation = pendingWriteContinuations[characteristic] {
                continuation.resume(throwing: error)
                pendingWriteContinuations.removeValue(forKey: characteristic)
            }
            return
        }
        
        if let continuation = pendingWriteContinuations[characteristic] {
            continuation.resume()
            pendingWriteContinuations.removeValue(forKey: characteristic)
        }
    }
    
    private func startDataUpdates() {
        dataUpdateTimer?.invalidate()
        dataUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self,
                  let peripheral = self.connectedIron?.peripheral,
                  let characteristic = self.bulkDataCharacteristic else { return }
            
            peripheral.readValue(for: characteristic)
            
            // Update Live Activity
            self.updateLiveActivity()
        }
    }
    
    private func handleBulkData(_ data: Data) {
        // Convert Data to [Int] array
        var values: [Int] = []
        for i in stride(from: 0, to: data.count, by: 4) {
            if i + 3 < data.count {  // Ensure we have 4 bytes to read
                let value = data.withUnsafeBytes { $0.load(fromByteOffset: i, as: UInt32.self) }
                values.append(Int(value))
            }
        }
        
        print("🔵 BLEManager: Received bulk data values: \(values)")
        
        // Ensure we have enough values
        guard values.count >= 14 else {
            print("🔵 BLEManager: Not enough values in bulk data. Expected at least 14, got \(values.count)")
            return
        }
        
        // Create IronData from the values
        let ironData = IronData(from: values)
        
        // Update the latest data and history
        DispatchQueue.main.async {
            self.latestData = ironData
            self.historicalData.append(ironData)
            // Keep only the last 60 entries
            if self.historicalData.count > 60 {
                self.historicalData.removeFirst(self.historicalData.count - 60)
            }
        }
    }
    
    private func handleBuildData(_ data: Data) {
        if let buildString = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.connectedIron?.build = buildString
            }
        }
    }

    // MARK: - Helper Methods
    
    func readValue(for characteristic: CBCharacteristic) async throws -> Data {
        guard let peripheral = connectedIron?.peripheral else {
            throw BLEError.notConnected
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            pendingReadContinuations[characteristic] = continuation
            peripheral.readValue(for: characteristic)
        }
    }
    
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) async throws {
        guard let peripheral = connectedIron?.peripheral else {
            throw BLEError.notConnected
        }
        
        // Determine the appropriate write type based on characteristic properties
        let writeType: CBCharacteristicWriteType
        if characteristic.properties.contains(.writeWithoutResponse) {
            writeType = .withoutResponse
        } else if characteristic.properties.contains(.write) {
            writeType = .withResponse
        } else {
            throw BLEError.writeFailed
        }
        
        print("🔵 BLEManager: Writing value to characteristic \(characteristic.uuid.uuidString) with type \(writeType == .withResponse ? "withResponse" : "withoutResponse")")
        
        return try await withCheckedThrowingContinuation { continuation in
            pendingWriteContinuations[characteristic] = continuation
            peripheral.writeValue(data, for: characteristic, type: writeType)
            
            // For write without response, we need to resume immediately
            if writeType == .withoutResponse {
                continuation.resume()
                pendingWriteContinuations.removeValue(forKey: characteristic)
            }
        }
    }

    // MARK: - Live Activity Management
    
    private func startLiveActivity() {
        guard let iron = connectedIron else { return }
        
        let attributes = IronOSCompanionLiveActivityAttributes(
            ironName: iron.name ?? "Iron",
            ironColor: iron.variation
        )
        
        let contentState = IronOSCompanionLiveActivityAttributes.ContentState(
            temperature: latestData?.currentTemp ?? 0,
            setpoint: latestData?.setpoint ?? 0,
            mode: latestData?.currentMode ?? .idle,
            handleTemp: latestData?.handleTemp ?? 0,
            power: latestData?.power ?? 0
        )
        
        do {
            liveActivity = try Activity<IronOSCompanionLiveActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("🔵 BLEManager: Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    private func updateLiveActivity() {
        guard let activity = liveActivity,
              let data = latestData else { return }
        
        let contentState = IronOSCompanionLiveActivityAttributes.ContentState(
            temperature: data.currentTemp,
            setpoint: data.setpoint,
            mode: data.currentMode,
            handleTemp: data.handleTemp,
            power: data.power
        )
        
        Task {
            await activity.update(.init(state: contentState, staleDate: nil))
        }
    }
    
    private func endLiveActivity() {
        Task {
            await liveActivity?.end(nil, dismissalPolicy: .immediate)
            liveActivity = nil
        }
    }
}


// Mock BLEManager for previews
class MockBLEManager: BLEManager {
    private var mockDataTimer: Timer?
    private var mockTemperature: Int = 25
    private var mockHandTemp: Double = 35.0
    private var mockWattage: Int = 65
    
    override init() {
        super.init()
        // Initialize with mock state
        isSwitchedOn = true
        bluetoothPermission = .allowedAlways
        
        // Add a mock iron
        let iron = Iron(uuid: UUID(), rssi: -80, name: "Test Iron", peripheral: nil)
        irons.append(iron)
    }
    
    private func startMockDataGeneration() {
        // Stop any existing timer
        mockDataTimer?.invalidate()
        
        // Create a new timer that generates data every 2 seconds
        mockDataTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Generate a new temperature value
            self.mockTemperature += Int.random(in: -2...2)
            self.mockTemperature = max(20, min(400, self.mockTemperature)) // Keep temperature between 20°C and 400°C
            
            // Generate hand temperature (slowly increases when iron is hot, decreases when cold)
            let handTempChange = Double.random(in: -0.2...0.2)
            self.mockHandTemp += handTempChange
            self.mockHandTemp = max(25.0, min(45.0, self.mockHandTemp)) // Keep hand temp between 25°C and 45°C
            
            // Generate wattage (higher when heating up, lower when at temperature)
            let targetTemp = 350 // Typical soldering temperature
            let tempDiff = targetTemp - self.mockTemperature
            let baseWattage = 65 // Base wattage when at temperature
            let heatingWattage = min(120, baseWattage + abs(tempDiff)) // Higher wattage when heating
            self.mockWattage = Int(Double(heatingWattage) * (0.95 + Double.random(in: 0...0.1))) // Add some variation
            
            // Create mock data
            let mockData = IronData(
                temperature: self.mockTemperature,
                setpoint: 350,
                power: self.mockWattage,
                handleTemp: self.mockHandTemp
            )
            
            // Update the latest data and history
            DispatchQueue.main.async {
                self.latestData = mockData
                self.historicalData.append(mockData)
                // Keep only the last 60 entries
                if self.historicalData.count > 60 {
                    self.historicalData.removeFirst(self.historicalData.count - 60)
                }
            }
        }
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
            self.connectedIron = iron
            iron.connected = true
            iron.connectedAt = Date()
        }
    }
    
    override func disconnect(from peripheral: Iron) {
        // Stop generating mock data
        mockDataTimer?.invalidate()
        mockDataTimer = nil
        
        connectionStatus = .disconnected
        connectedIron = nil
        peripheral.connected = false
        peripheral.connectedAt = nil
        
        // Clear the data
        DispatchQueue.main.async {
            self.latestData = nil
            self.historicalData.removeAll()
        }
    }
    
    deinit {
        mockDataTimer?.invalidate()
    }
}
