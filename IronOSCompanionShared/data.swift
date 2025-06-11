import Foundation

public class IronData: Codable {
    public var currentTemp: Int
    public var setpoint: Int
    public var inputVoltage: Double
    public var handleTemp: Double
    public var power: Int
    public var powerSrc: Int
    public var tipResistance: Int
    public var uptime: Double
    public var lastMovementTime: Double
    public var maxTemp: Int
    public var rawTip: Int
    public var hallSensor: Int
    public var currentMode: OperatingMode
    public var estimatedWattage: Double
    
    public init(from chars: [Int]) {
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

    // This is for testing purposes
    public init(temperature: Int, setpoint: Int = 350, power: Int = 65, handleTemp: Double = 35.0) {
        self.currentTemp = temperature
        self.setpoint = setpoint
        self.inputVoltage = 12.0
        self.handleTemp = handleTemp
        self.power = power
        self.powerSrc = 0
        self.tipResistance = 100
        self.uptime = 0.0
        self.lastMovementTime = 0.0
        self.maxTemp = 400
        self.rawTip = temperature
        self.hallSensor = 0
        self.currentMode = .soldering
        self.estimatedWattage = Double(power)
    }
} 