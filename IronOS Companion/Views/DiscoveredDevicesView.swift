//
//  DiscoveredDevicesView.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/28/25.
//

import SwiftUI
import CoreBluetooth
import SwiftData

struct DiscoveredDevicesView: View {
    @EnvironmentObject var bleManager: BLEManager
    @Query private var appState: [AppState]
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showPermissionSheet = false;
    @State private var deviceToConnect: Iron? = nil // Track selected device
    @State private var navigateToHome = false // Add navigation state
    
    private var state: AppState? {
        appState.first
    }
    
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
                            DeviceCard(iron: iron, isSaved: state?.savedIrons.contains(where: { $0.id == iron.id }) ?? false) {
                                deviceToConnect = iron
                            }
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
        .onChange(of: bleManager.bluetoothPermission) { oldValue, newValue in
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
        .sheet(item: $deviceToConnect) { iron in
            SetUpAccessorySheet(iron: iron){
                navigateToHome = true
            }
                .interactiveDismissDisabled()
        }
        .navigationDestination(isPresented: $navigateToHome) {
            DeviceDashView()
        }
    }
}

struct DeviceCard: View {
    let iron: Iron
    let isSaved: Bool
    var onTap: (() -> Void)? = nil
    @State private var animateRadar = false
    
    var body: some View {
        HStack(spacing: 18) {
            iron.image
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .shadow(radius: 2)
                
            VStack(alignment: .leading) {
                Text(iron.name ?? "IronOS Device")
                    .font(.headline)
                Text(iron.id.uuidString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 8) {
                    Chip(text: "Signal: \(iron.signalQualityString)", color: iron.signalColor)
                    if isSaved {
                        Chip(text: "Linked", color: .purple)
                    }
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
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}


#Preview {
    NavigationView {
        DiscoveredDevicesView()
            .environmentObject(MockBLEManager() as BLEManager)
    }
} 
