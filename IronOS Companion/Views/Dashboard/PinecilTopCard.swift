//
//  PinecilTopCard.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/31/25.
//

import SwiftUI

struct PinecilTopCard: View {
    let iron: Iron?
    let data: IronData?

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
                                Text(String(data?.setpoint ?? 0))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                HStack(spacing: 12) {
                                    Circle()
                                        .stroke(Color.primary, lineWidth: 2)
                                        .overlay(
                                            Image(systemName: "plus")
                                                .font(.title3)
                                        )
                                    Circle()
                                        .stroke(Color.primary, lineWidth: 2)
                                        .overlay(
                                            Image(systemName: "minus")
                                                .font(.title3)
                                        )
                                }
                            }
                        }
                    }
                    Spacer()
                    ZStack(alignment: .bottomTrailing) {
                        (iron?.image ?? Image("default"))
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
        data: IronData(from: [30, 80, 198, 307, 0, 3, 62, 618684, 600167, 441, 619, 0, 0, 0])
    )
    .frame(height: 160)
    .padding()
}
