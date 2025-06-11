//
//  HandTemperatureCard.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 6/1/25.
//
// Claude Sonnet 3.7 added MARKs and comments

import SwiftUI
import Charts

/// A card component that displays the handle temperature of the connected device.
/// This view shows the current handle temperature and provides a historical chart
/// of temperature readings to monitor heat buildup in the handle.
struct HandTemperatureCard: View {
    // MARK: - Properties
    let temperature: Int
    let unit: String
    @EnvironmentObject private var bleManager: BLEManager
    
    // MARK: - Body
    var body: some View {
        MetricCard(
            value: temperature,
            unit: unit,
            icon: "hand.raised.fill",
            iconColor: .teal,
            chartData: Array(bleManager.historicalData.suffix(60).enumerated()).map { ($0.offset, Double($0.element.handleTemp)) },
            chartColor: .teal
        )
    }
}

#Preview {
    HandTemperatureCard(temperature: 35, unit: "°F")
        .frame(width: 230, height: 180)
        .environmentObject(MockBLEManager() as BLEManager)
} 
