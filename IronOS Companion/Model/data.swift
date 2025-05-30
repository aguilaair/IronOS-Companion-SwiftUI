//
//  data.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/26/25.
//

class IronData: Codable {
    var currentTemp: Int
    var setpoint: Int
    var inputVoltage: Double
    var handleTemp: Double
    var power: Int
    var powerSrc: Int
    var tipResistance: Int
    var uptime: Double
    var lastMovementTime: Double
    var maxTemp: Int
    var rawTip: Int
    var hallSensor: Int
    var currentMode: OperatingMode
    var estimatedWattage: Double
    
    init(from chars: [Int]) {
        print("🔵 IronData: Processing values: \(chars)")
        
        // Ensure we have enough values
        guard chars.count >= 14 else {
            fatalError("Not enough values in data array. Expected at least 14, got \(chars.count)")
        }
        
        // Each value is a single 32-bit integer, no need for bit shifting
        self.currentTemp = chars[0]
        self.setpoint = chars[1]
        self.inputVoltage = Double(chars[2]) / 10.0
        self.handleTemp = Double(chars[3]) / 10.0
        self.power = chars[4]
        self.powerSrc = chars[5]
        self.tipResistance = chars[6]
        self.uptime = Double(chars[7]) / 10.0
        self.lastMovementTime = Double(chars[8]) / 10.0
        self.maxTemp = chars[9]
        self.rawTip = chars[10]
        self.hallSensor = chars[11]
        self.currentMode = OperatingMode.fromInt(chars[12])
        self.estimatedWattage = Double(chars[13]) / 10.0
    }
}
