import SwiftUI
import SwiftData

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
    
    private var state: AppState? {
        appState.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    PinecilTopCard(iron: bleManager.connectedIron, data: bleManager.latestData)
                    if let iron = bleManager.connectedIron {
                        // Connected Device View
                        VStack(spacing: 16) {
                            HStack {
                                iron.image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                
                                VStack(alignment: .leading) {
                                    Text(iron.name ?? "IronOS Device")
                                        .font(.headline)
                                    if let build = iron.build {
                                        Text("Firmware: \(build)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    bleManager.disconnect(from: iron)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            
                            if let data = bleManager.latestData {
                                TemperatureDisplay(
                                    temperature: data.currentTemp,
                                    setpoint: data.setpoint,
                                    unit: "°C"
                                )
                                
                                // Additional data cards can be added here
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
