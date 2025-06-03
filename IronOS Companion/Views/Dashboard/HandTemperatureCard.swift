import SwiftUI
import Charts

struct HandTemperatureCard: View {
    let temperature: Int
    let unit: String
    @EnvironmentObject private var bleManager: BLEManager
    
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
