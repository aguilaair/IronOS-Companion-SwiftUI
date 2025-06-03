import SwiftUI
import Charts

struct ChartDataPoint: Equatable {
    let index: Int
    let value: Double
}

struct MetricCard: View {
    let value: Int
    let unit: String
    let icon: String
    let iconColor: Color
    let chartData: [ChartDataPoint]
    let chartColor: Color
    let contractedByDefault: Bool
    @EnvironmentObject private var bleManager: BLEManager
    @State private var isExpanded: Bool
    
    init(
        value: Int,
        unit: String,
        icon: String,
        iconColor: Color,
        chartData: [(Int, Double)],
        chartColor: Color,
        contractedByDefault: Bool = false
    ) {
        self.value = value
        self.unit = unit
        self.icon = icon
        self.iconColor = iconColor
        self.chartData = chartData.map { ChartDataPoint(index: $0.0, value: $0.1) }
        self.chartColor = chartColor
        self.contractedByDefault = contractedByDefault
        _isExpanded = State(initialValue: !contractedByDefault)
    }
    
    var body: some View {
        ZStack {
            // Background color and faded unit
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemFill))
                .overlay(
                    ZStack {
                        Text(unit)
                            .font(.system(size: isExpanded ? 150 : 120, weight: .bold, design: .rounded))
                            .foregroundColor(Color.primary.opacity(0.07))
                            .offset(x: isExpanded ? 25 : 15, y: isExpanded ? -40 : 0)
                    }
                )
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Image(systemName: icon)
                        .font(.system(size: isExpanded ? 28 : 24, weight: .bold))
                        .foregroundColor(iconColor)
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary.opacity(0.5))
                            .rotationEffect(.degrees(isExpanded ? 0 : -90))
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(value)")
                        .font(.system(size: isExpanded ? 74 : 54, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Spacer()
                }.padding(.horizontal)
                    .padding(.vertical, 2)
                
                if isExpanded {
                    Spacer()
                    // Chart
                    ZStack {
                        Chart {
                            ForEach(chartData, id: \.index) { data in
                                AreaMark(
                                    x: .value("Time", data.index),
                                    y: .value("Value", data.value)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            chartColor.opacity(0.5),
                                            chartColor.opacity(0.1)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                
                                LineMark(
                                    x: .value("Time", data.index),
                                    y: .value("Value", data.value)
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(chartColor)
                                .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                            }
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .frame(height: 60)
                        .padding(.bottom, 2)
                        .animation(.linear(duration: 1), value: chartData)
                    }
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        )
                    )
                    .id(isExpanded)
                }
            }
        }
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExpanded)
        .frame(height: isExpanded ? 210 : 120)
    }
}

#Preview {
    MetricCard(
        value: 100,
        unit: "°F",
        icon: "thermometer",
        iconColor: .red,
        chartData: Array(0..<60).map { ($0, Double.random(in: 90...110)) },
        chartColor: .red,
        contractedByDefault: true
    )
    .frame(width: 230)
    .environmentObject(MockBLEManager() as BLEManager)
} 
