//
//  PinecilTopCard.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/31/25.
//
// Claude Sonnet 3.7 added MARKs and comments


import SwiftUI
import IronOSCompanionShared

/// A card component that displays the main device information and controls.
/// This view shows the device name, build version, and provides temperature
/// adjustment controls with haptic feedback.
struct PinecilTopCard: View {
    // MARK: - Properties
    let iron: Iron?
    let data: IronData?
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    // MARK: - State
    @State private var isPlusLongPressing = false
    @State private var isMinusLongPressing = false
    
    // MARK: - Haptic Feedback
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let longPressHaptic = UIImpactFeedbackGenerator(style: .heavy)

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let cardRadius: CGFloat = 18
            ZStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(iron?.name ?? "Disconnected")
                                .font(.title)
                                .fontWeight(.bold)
                            Text(iron?.build ?? "")
                                .font(.callout)
                                .padding(.top, 6)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Setpoint")
                                .font(.headline)
                            HStack(spacing: 20) {
                                Text(String(settingsViewModel.settings?.solderingSettings.solderingTemp ?? data?.setpoint ?? 0))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .frame(width: 70, alignment: .leading)
                                    .monospacedDigit()
                                HStack(spacing: 12) {
                                    Button(action: {
                                        if !isPlusLongPressing,
                                           let currentTemp = settingsViewModel.settings?.solderingSettings.solderingTemp ?? data?.setpoint {
                                            let stepSize = settingsViewModel.settings?.solderingSettings.tempChangeShortPress ?? 10
                                            hapticFeedback.impactOccurred()
                                            print("🔵 Short press plus: \(currentTemp + stepSize) - \(stepSize)")
                                            settingsViewModel.setSolderingTemp(currentTemp + stepSize)
                                        }
                                    }) {
                                        Circle()
                                            .stroke(Color.primary, lineWidth: 2)
                                            .overlay(
                                                Image(systemName: "plus")
                                                    .font(.title3)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .simultaneousGesture(
                                        LongPressGesture(minimumDuration: 0.5)
                                            .onEnded { _ in
                                                isPlusLongPressing = true
                                                longPressHaptic.impactOccurred()
                                                if let currentTemp = settingsViewModel.settings?.solderingSettings.solderingTemp ?? data?.setpoint {
                                                    let stepSize = settingsViewModel.settings?.solderingSettings.tempChangeLongPress ?? 50
                                                    print("🔵 Long press plus: \(currentTemp + stepSize) - \(stepSize)")
                                                    settingsViewModel.setSolderingTemp(currentTemp + stepSize)
                                                }
                                            }
                                    )
                                    .simultaneousGesture(
                                        DragGesture(minimumDistance: 0)
                                            .onEnded { _ in
                                                isPlusLongPressing = false
                                            }
                                    )
                                    
                                    Button(action: {
                                        if !isMinusLongPressing,
                                           let currentTemp = settingsViewModel.settings?.solderingSettings.solderingTemp ?? data?.setpoint {
                                            let stepSize = settingsViewModel.settings?.solderingSettings.tempChangeShortPress ?? 10
                                            hapticFeedback.impactOccurred()
                                            print("🔵 Short press minus: \(currentTemp - stepSize) - \(stepSize)")
                                            settingsViewModel.setSolderingTemp(currentTemp - stepSize)
                                        }
                                    }) {
                                        Circle()
                                            .stroke(Color.primary, lineWidth: 2)
                                            .overlay(
                                                Image(systemName: "minus")
                                                    .font(.title3)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .simultaneousGesture(
                                        LongPressGesture(minimumDuration: 0.5)
                                            .onEnded { _ in
                                                isMinusLongPressing = true
                                                longPressHaptic.impactOccurred()
                                                if let currentTemp = settingsViewModel.settings?.solderingSettings.solderingTemp ?? data?.setpoint {
                                                    let stepSize = settingsViewModel.settings?.solderingSettings.tempChangeLongPress ?? 50
                                                    print("🔵 Long press minus: \(currentTemp - stepSize) - \(stepSize)")
                                                    settingsViewModel.setSolderingTemp(currentTemp - stepSize)
                                                }
                                            }
                                    )
                                    .simultaneousGesture(
                                        DragGesture(minimumDistance: 0)
                                            .onEnded { _ in
                                                isMinusLongPressing = false
                                            }
                                    )
                                }
                            }
                        }
                    }
                    Spacer()
                    ZStack(alignment: .bottomTrailing) {
                        (iron?.cutImage ?? Image("pinecil.cut.default"))
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(1.6)
                            .offset(x: -30, y: 20)
                        VStack {
                            Spacer()
                            ZStack {
                                if let mode = data?.currentMode {
                                    Text(mode.displayText)
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .padding(.trailing, 8)
                                        .padding(.bottom, 4)
                                        .id(mode)
                                        .transition(.opacity)
                                } else {
                                    Text("Waiting")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .padding(.trailing, 8)
                                        .padding(.bottom, 4)
                                        .id("waiting")
                                        .transition(.opacity)
                                }
                            }
                            .animation(.easeInOut(duration: 0.3), value: data?.currentMode)
                        }
                    }
                }
                .padding(.vertical)
                .padding(.horizontal, 6)
            }
            .frame(minHeight: 160)
            .clipShape(RoundedRectangle(cornerRadius: cardRadius))
        }
        .frame(minHeight: 160)
    }
}

#Preview {
    PinecilTopCard(
        iron: Iron(uuid: UUID(), name: "Test Device", build: "2.23", devSN: "123", devID: "2.23"),
        data: IronData(from: [30, 80, 198, 307, 0, 3, 62, 618684, 600167, 441, 619, 0, 0, 0]),
        settingsViewModel: SettingsViewModel()
    )
    .frame(height: 160)
    .padding()
}
