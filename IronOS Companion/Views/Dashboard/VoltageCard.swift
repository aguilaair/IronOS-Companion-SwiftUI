//
//  VoltageCard.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 6/1/25.
//
import SwiftUI
import Charts

/// A card component that displays voltage information for the connected device.
/// This view shows the current voltage and whether the device is running on battery
/// or power supply, with a historical chart of voltage readings.
struct VoltageCard: View {
    // MARK: - Properties
    let voltage: Double
    let isBattery: Bool
    let unit: String
    @EnvironmentObject private var bleManager: BLEManager
    
    // MARK: - Body
    var body: some View {
        MetricCard(
            value: Int(voltage.rounded()),
            unit: unit,
            icon: isBattery ? "battery.100" : "bolt.horizontal.fill",
            iconColor: isBattery ? .green : .blue,
            chartData: Array(bleManager.historicalData.suffix(60).enumerated()).map { ($0.offset, $0.element.inputVoltage) },
            chartColor: isBattery ? .green : .blue,
            contractedByDefault: true
        )
    }
}

#Preview {
    VoltageCard(voltage: 12.3, isBattery: true, unit: "V")
        .frame(width: 230, height: 180)
        .environmentObject(MockBLEManager() as BLEManager)
} 