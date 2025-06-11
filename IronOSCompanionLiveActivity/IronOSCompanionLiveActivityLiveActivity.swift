//
//  IronOSCompanionLiveActivityLiveActivity.swift
//  IronOSCompanionLiveActivity
//
//  Created by Eduardo Moreno Adanez on 6/11/25.
//

import ActivityKit
import WidgetKit
import SwiftUI
import IronOSCompanionShared

struct IronOSCompanionLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IronOSCompanionLiveActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            ZStack {
                // Background gradient
                RadialGradient(
                    gradient: Gradient(colors: [
                        GradientConfig.forMode(context.state.mode).colors[0].opacity(0.4),
                        Color("WidgetBackground")
                    ]),
                    center: .top,
                    startRadius: 100,
                    endRadius: 600
                )
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(context.attributes.ironName)
                            .font(.headline)
                        Text(context.state.mode.displayText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("\(context.state.temperature)°C")
                            .font(.title2)
                            .bold()
                        Text("Set: \(context.state.setpoint)°C")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text(context.attributes.ironName)
                            .font(.headline)
                        Text(context.state.mode.displayText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        Text("\(context.state.temperature)°C")
                            .font(.title2)
                            .bold()
                        Text("Set: \(context.state.setpoint)°C")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Label("\(Int(context.state.handleTemp))°C", systemImage: "hand.raised.fill")
                        Spacer()
                        Label("\(context.state.power)W", systemImage: "bolt.fill")
                    }
                    .font(.caption)
                }
            } compactLeading: {
                Text("\(context.state.temperature)°C")
                    .font(.headline)
            } compactTrailing: {
                Image(systemName: context.state.mode == .soldering ? "flame.fill" : "flame")
                    .foregroundColor(context.state.mode == .soldering ? .orange : .gray)
            } minimal: {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
            }
        }
    }
}

extension IronOSCompanionLiveActivityAttributes {
    fileprivate static var preview: IronOSCompanionLiveActivityAttributes {
        IronOSCompanionLiveActivityAttributes(
            ironName: "Pinecil",
            ironColor: .teal
        )
    }
}

extension IronOSCompanionLiveActivityAttributes.ContentState {
    fileprivate static var soldering: IronOSCompanionLiveActivityAttributes.ContentState {
        IronOSCompanionLiveActivityAttributes.ContentState(
            temperature: 350,
            setpoint: 350,
            mode: .soldering,
            handleTemp: 35.0,
            power: 65
        )
    }
    
    fileprivate static var idle: IronOSCompanionLiveActivityAttributes.ContentState {
        IronOSCompanionLiveActivityAttributes.ContentState(
            temperature: 25,
            setpoint: 350,
            mode: .idle,
            handleTemp: 25.0,
            power: 0
        )
    }
}

#Preview("Notification", as: .content, using: IronOSCompanionLiveActivityAttributes.preview) {
   IronOSCompanionLiveActivityLiveActivity()
} contentStates: {
    IronOSCompanionLiveActivityAttributes.ContentState.soldering
    IronOSCompanionLiveActivityAttributes.ContentState.idle
}
