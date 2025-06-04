import SwiftUI
import SwiftData
import Charts

struct TemperatureDisplay: View {
    let temperature: Int
    let setpoint: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(temperature)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                Text(unit)
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "target")
                    .foregroundColor(.secondary)
                Text("Setpoint: \(setpoint)\(unit)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct DeviceDashView: View {
    @EnvironmentObject var bleManager: BLEManager
    @Query private var appState: [AppState]
    @State private var showDeviceList = false
    @State private var currentColors: [Color] = [Color(.systemGray4), Color(.systemBackground)]
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    private var state: AppState? {
        appState.first
    }
    
    private var gradientConfig: GradientConfig {
        guard let data = bleManager.latestData else {
            return .disconnected
        }
        return GradientConfig.forMode(data.currentMode)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                if bleManager.connectedIron != nil {
                    RadialGradient(
                        gradient: Gradient(colors: currentColors),
                        center: .top,
                        startRadius: 100,
                        endRadius: 600
                    )
                    .ignoresSafeArea()
                    .onAppear {
                        if gradientConfig.isAnimating {
                            withAnimation(.easeInOut(duration: gradientConfig.animationDuration).repeatForever(autoreverses: true)) {
                                currentColors = gradientConfig.colors.map { $0.opacity(0.4) }
                            }
                        }
                    }
                    .onChange(of: bleManager.latestData?.currentMode) { _, newMode in
                        if let mode = newMode {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currentColors = GradientConfig.forMode(mode).colors
                            }
                        }
                    }
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        PinecilTopCard(
                            iron: bleManager.connectedIron,
                            data: bleManager.latestData,
                            settingsViewModel: settingsViewModel
                        )
                        
                        if bleManager.connectedIron != nil {
                            // Connected Device View
                            VStack {
                                if let data = bleManager.latestData {
                                    LazyVGrid(
                                        columns: [
                                            GridItem(.adaptive(minimum: 150), alignment: .top)
                                        ],
                                        alignment: .leading,
                                        spacing: 16
                                    ) {
                                        TemperatureChartCard(
                                            temperature: data.currentTemp,
                                            setpoint: data.setpoint,
                                            unit: "°C"
                                        )
                                        
                                        HandTemperatureCard(
                                            temperature: Int(data.handleTemp),
                                            unit: "°C"
                                        )
                                        
                                        WattageCard(
                                            wattage: Int(data.estimatedWattage),
                                            unit: "W"
                                        )
                                        // Voltage Card
                                        VoltageCard(
                                            voltage: data.inputVoltage,
                                            isBattery: data.powerSrc == 0, // 0 = battery, 1 = PD
                                            unit: "V"
                                        )
                                    }
                                } else {
                                    ProgressView("Waiting for data...")
                                        .padding()
                                }
                            }
                        } else {
                            // No Device Connected View
                            VStack(spacing: 16) {
                                Image(systemName: "bolt.horizontal.circle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.blue)
                                
                                Text("No Device Connected")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                
                                Button(action: {
                                    showDeviceList = true
                                }) {
                                    Text("Connect Device")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(12)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Dashboard")
            .navigationDestination(isPresented: $showDeviceList) {
                DiscoveredDevicesView()
            }
        }
    }
}

#Preview {
    DeviceDashView()
        .environmentObject(MockBLEManager() as BLEManager)
} 
