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
    @State private var gradientOpacity: Double = 0.2

    var body: some View {
        GeometryReader { geometry in
            let cardRadius: CGFloat = 18
            let cardSize = max(geometry.size.width, geometry.size.height)
            ZStack {
                // Background
                if iron != nil && data != nil {
                    // Radial gradient background
                    RadialGradient(
                        gradient: Gradient(colors: [Color(.green).opacity(gradientOpacity), Color(.secondarySystemBackground)]),
                        center: .bottom,
                        startRadius: 20,
                        endRadius: cardSize/1.5
                    )
                    .cornerRadius(cardRadius)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                            gradientOpacity = 0.4
                        }
                    }
                } else {
                    Color(.secondarySystemBackground)
                        .cornerRadius(cardRadius)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }

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
                            Text("Stand-by")
                                .font(.headline)
                                .fontWeight(.medium)
                                .padding(.trailing, 8)
                                .padding(.bottom, 4)
                        }
                    }
                }
                .padding(20)
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
