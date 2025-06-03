import SwiftUI
import Charts

struct VoltageCard: View {
    let voltage: Double
    let isBattery: Bool
    let unit: String
    @EnvironmentObject private var bleManager: BLEManager
    
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