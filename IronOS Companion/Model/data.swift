//
//  data.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/26/25.
//

struct IronData: Codable, Equatable {
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
}
