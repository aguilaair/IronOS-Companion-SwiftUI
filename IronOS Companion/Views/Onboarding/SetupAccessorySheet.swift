//
//  SetupAccessorySheet.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/28/25.
//

import SwiftUI
import CoreBluetooth
import SwiftData

struct SetUpAccessorySheet: View {
    // MARK: - Data owned by the parent view
    let iron: Iron

    // MARK: - Data owned by the sheet
    @EnvironmentObject var bleManager: BLEManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var appState: [AppState]
    @State private var selectedColor: IronColor = .teal
    @State private var showNameStep = false
    @State private var ironName = ""

    // MARK: - Callback functions
    var onContinue: () -> Void
    
    private var state: AppState? {
        appState.first
    }
    
    // MARK: - Body
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
                
                if !showNameStep {
                    Text("Let's get your \(iron.name ?? "Iron") ready to use")
                        .padding(.bottom)
                        .multilineTextAlignment(.center)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                    
                    HStack(spacing: 20) {
                        iron.image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 120)
                            .animatedBlob(color: bleManager.connectionStatus == .connected ? .green : .blue, opacity: 0.4)
                            .transition(.opacity)
                            .animation(.spring(duration: 0.5), value: iron.variation)
                        
                        if bleManager.connectionStatus == .connected {
                            Picker("Iron Color", selection: $selectedColor) {
                                ForEach([IronColor.teal, .red, .transparent], id: \.self) { color in
                                    Text(color.rawValue.capitalized)
                                        .tag(color)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            .onChange(of: selectedColor) { oldValue, newValue in
                                withAnimation(.spring(duration: 0.5)) {
                                    iron.variation = newValue
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .animation(.spring(duration: 0.5), value: bleManager.connectionStatus)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    
                    Text((iron.name ?? "IronOS Device"))
                        .font(.footnote)
                        .padding(.vertical)
                        .transition(.move(edge: .leading).combined(with: .opacity))
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
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))

                    Button(action: {
                        if(bleManager.connectionStatus != .connected) {
                            bleManager.disconnect(from: iron)
                            dismiss()
                        } else {
                            withAnimation(.spring(duration: 0.5)) {
                                showNameStep = true
                            }
                        }
                    }) {
                        Text(bleManager.connectionStatus == .connected ? "Continue" : "Cancel")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(15)
                    }
                    .padding()
                    .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    Text("Nearly done, give your iron a name")
                        .padding(.bottom)
                        .multilineTextAlignment(.center)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    
                    TextField("Iron Name", text: $ironName)
                        .font(.headline)
                        .frame(height: 55)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding([.horizontal], 4)
                        .cornerRadius(15)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray))
                        .padding([.horizontal], 24)
                        .multilineTextAlignment(.center)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    
                    Spacer()
                    
                    Button(action: {
                        iron.name = ironName
                        state?.addIron(iron)
                        state?.updateLastConnectedIron(iron)
                        state?.markOnboardingComplete()
                        try? modelContext.save()
                        onContinue()
                        dismiss()
                    }) {
                        Text("Finish")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(15)
                    }
                    .padding()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 18)
            .animation(.spring(duration: 0.5), value: showNameStep)
        }
        .padding(.horizontal, 8)
        .presentationDetents([.medium])
        .presentationBackground(.clear)
        .onAppear {
            bleManager.connect(to: iron)
            ironName = iron.name ?? ""
        }
        .onChange(of: bleManager.connectionStatus) { oldValue, newValue in
            
        }
    }
}

#Preview {
    SetUpAccessorySheet(iron: Iron(uuid: UUID(), rssi: -80, name: "Test", peripheral: nil)){
        
    }
        .environmentObject(MockBLEManager() as BLEManager)
}
