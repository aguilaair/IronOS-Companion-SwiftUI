//
//  SetupAccessorySheet.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/28/25.
//

import SwiftUI

struct SetUpAccessorySheet: View {
    let iron: Iron
    @EnvironmentObject var bleManager: BLEManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color(.systemBackground))
            VStack() {
                Text("Set Up Your Iron")
                    .font(.title)
                    .padding(.top)
                    .padding(.bottom, 8)
                    .bold()
                Text("Please wait, pairing \(iron.name ?? "Iron") with your device")
                    .padding(.bottom)
                    .multilineTextAlignment(.center)
                Spacer().frame(height: 56)
                Image("pinecil")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotationEffect(.degrees(-50))
                    .frame(maxWidth: 260, maxHeight: 110)
                    .animatedBlob(color: bleManager.connectionStatus == .connected ? .green : .blue, opacity: 0.4)
                Text((iron.name ?? "IronOS Device"))
                    .font(.footnote)
                    .padding(.top, 48)
                    .padding(.bottom, 16)
                Spacer()
                HStack(spacing: 8) {
                    if bleManager.connectionStatus == .connecting || 
                       bleManager.connectionStatus == .discoveringServices || 
                       bleManager.connectionStatus == .discoveringCharacteristics {
                        ProgressView()
                    } else {
                        Image(systemName: bleManager.connectionStatus == .connected ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(bleManager.connectionStatus == .connected ? .green : .red)
                    }
                    Text(bleManager.connectionStatus.message)
                        .foregroundColor(bleManager.connectionStatus == .connected ? .green : .primary)
                }.padding()

                if(bleManager.connectionStatus != .connected) {Button(action: {
                    bleManager.disconnect(from: iron.peripheral!)
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(15)
                }
                .padding()
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 18)
        }
        .padding(.horizontal, 8)
        .presentationDetents([.medium])
        .presentationBackground(.clear)
        .onAppear {
            bleManager.connect(to: iron)
        }
        .onChange(of: bleManager.connectionStatus) { newValue, oldValue in
            if newValue == .connected {
                // Dismiss the sheet after a short delay when connected
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    SetUpAccessorySheet(iron: Iron(uuid: UUID(), rssi: 0, name: "Test", peripheral: nil))
        .environmentObject(BLEManager.shared)
}
