//
//  BluetoothPermissionSheet.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/28/25.
//

import SwiftUI
import CoreBluetooth

struct BluetoothPermissionSheet: View {
    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) var dismiss
    @ObservedObject var bleManager = BLEManager()
    var onDismiss: () -> Void

    var body: some View {
        VStack {
            Image("bt")
                .resizable()
                .frame(width: 100, height: 100)
                .padding(.top)
                .padding(.top)
            Text("Bluetooth Permission Needed")
                .font(.title2)
                .bold()
            if bleManager.bluetoothPermission == .notDetermined {
                Text("This app needs Bluetooth access to discover and connect to devices. Please accept the Bluetooth permission dialog when it appears.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: {
                    // Try to trigger the system dialog by starting a scan
                    bleManager.startScanning()
                }) {
                    Text("Allow Bluetooth Access")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                Text("This app requires Bluetooth access to discover and connect to devices. Please allow Bluetooth in Settings.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }) {
                    Text("Open Settings")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .onChange(of: bleManager.bluetoothPermission) { newValue, oldValue in
            if newValue == .allowedAlways {
                dismiss()
                onDismiss()
            }
        }
    }
} 
