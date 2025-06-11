//
//  WattageCard.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 6/1/25.
//
// Claude Sonnet 3.7 added MARKs and comments

import SwiftUI
import Charts

/// A card component that displays power consumption information for the connected device.
/// This view shows the current wattage and provides a historical chart of power usage.
struct WattageCard: View {
    // MARK: - Properties
    let wattage: Int
    let unit: String
    @EnvironmentObject private var bleManager: BLEManager
    
    // MARK: - Body
    var body: some View {
        MetricCard(
            value: wattage,
            unit: unit,
            icon: "bolt.fill",
            iconColor: .yellow,
            chartData: Array(bleManager.historicalData.suffix(60).enumerated()).map { ($0.offset, Double($0.element.estimatedWattage)) },
            chartColor: .yellow
        )
    }
}

#Preview {
    WattageCard(wattage: 65, unit: "W")
        .frame(width: 230, height: 180)
        .environmentObject(MockBLEManager() as BLEManager)
} 
