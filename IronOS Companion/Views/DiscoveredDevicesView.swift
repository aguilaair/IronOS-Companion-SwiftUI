//
//  DiscoveredDevicesView.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/28/25.
//

import SwiftUI
import CoreBluetooth

struct DiscoveredDevicesView: View {
    @State private var discoveredDevices: [CBPeripheral] = []
    @State private var isScanning = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        List {
            Section {
                if discoveredDevices.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Searching for devices...")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(discoveredDevices, id: \.identifier) { device in
                        DeviceRow(device: device)
                    }
                }
            } header: {
                HStack {
                    Text("Discovered Devices")
                    Spacer()
                    if isScanning {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .searchBLEDevices(discoveredDevices: $discoveredDevices, isScanning: $isScanning)
        .navigationTitle("Bluetooth Devices")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    discoveredDevices.removeAll()
                    isScanning = false
                    // The view modifier will automatically restart scanning
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}

struct DeviceRow: View {
    let device: CBPeripheral
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name ?? "Unknown Device")
                    .font(.headline)
                Text(device.identifier.uuidString)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // TODO: Implement device connection
        }
    }
}

#Preview {
    NavigationView {
        DiscoveredDevicesView()
    }
} 