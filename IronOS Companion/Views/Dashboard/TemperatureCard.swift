//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 6/1/25.
//

import SwiftUI
import Charts

struct TemperatureChartCard: View {
    let temperature: Int
    let setpoint: Int
    let unit: String
    @EnvironmentObject private var bleManager: BLEManager
    
    var body: some View {
        MetricCard(
            value: temperature,
            unit: unit,
            icon: "thermometer",
            iconColor: .red,
            chartData: Array(bleManager.historicalData.suffix(60).enumerated()).map { ($0.offset, Double($0.element.currentTemp)) },
            chartColor: .red
        )
    }
}

#Preview {
    TemperatureChartCard(temperature: 100, setpoint: 100, unit: "°C")
        .frame(width: 230, height: 180)
        .environmentObject(MockBLEManager() as BLEManager)
}
