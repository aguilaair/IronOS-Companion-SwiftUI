//
//  BLEPermissionModifier.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/28/25.
//

import SwiftUI
import CoreBluetooth

struct BLEPermissionModifier: ViewModifier {
    @State private var showPermissionAlert = false
    @State private var bluetoothManager = CBCentralManager()
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                checkBluetoothPermission()
            }
            .onChange(of: bluetoothManager.state) { _, newState in
                if newState == .unauthorized {
                    showPermissionAlert = true
                }
            }
            .alert("Bluetooth Permission Required", isPresented: $showPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This app requires Bluetooth access to connect to your soldering iron. Please enable Bluetooth in Settings.")
            }
    }
    
    private func checkBluetoothPermission() {
        switch bluetoothManager.state {
        case .unauthorized:
            showPermissionAlert = true
        default:
            break
        }
    }
}

extension View {
    func checkBLEPermission() -> some View {
        modifier(BLEPermissionModifier())
    }
} 