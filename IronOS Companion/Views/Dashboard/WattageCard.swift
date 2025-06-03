import SwiftUI
import Charts

struct WattageCard: View {
    let wattage: Int
    let unit: String
    @EnvironmentObject private var bleManager: BLEManager
    
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
