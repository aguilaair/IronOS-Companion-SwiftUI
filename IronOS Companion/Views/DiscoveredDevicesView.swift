//
//  DiscoveredDevicesView.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/28/25.
//

import SwiftUI
import CoreBluetooth

struct DiscoveredDevicesView: View {
    @StateObject private var bleManager = BLEManager()
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showPermissionSheet = false;
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Discovered Devices")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 8)
            
            if bleManager.irons.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Searching for devices...")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                ScrollView {
                    VStack(spacing: 18) {
                        ForEach(bleManager.irons) { iron in
                            DeviceCard(iron: iron)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            Spacer()
            Button(action: {
                bleManager.irons.removeAll()
                bleManager.startScanning()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Rescan")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .cornerRadius(15)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("")
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: bleManager.bluetoothPermission) { newValue, oldValue in
            showPermissionSheet = (newValue == .denied || newValue == .notDetermined)
        }
        .onAppear {
            showPermissionSheet = (bleManager.bluetoothPermission == .denied || bleManager.bluetoothPermission == .notDetermined)
        }
        .sheet(isPresented: $showPermissionSheet) {
            BluetoothPermissionSheet(onDismiss: {
                showPermissionSheet = false
            })
            .interactiveDismissDisabled(true)
        }
    }
}

struct DeviceCard: View {
    let iron: Iron
    @State private var animateRadar = false
    var body: some View {
        HStack(spacing: 18) {
            Image("pinecil")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .cornerRadius(12)
                .shadow(radius: 2)
                .rotationEffect(.degrees(-50))
                
            VStack(alignment: .leading, spacing: 6) {
                Text(iron.name ?? "IronOS Device")
                    .font(.headline)
                Text(iron.id.uuidString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 8) {
                    Chip(text: "Signal: \(iron.signalQualityString)", color: iron.signalColor)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
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
