import ActivityKit
import SwiftUI
import WidgetKit
import IronOSCompanionShared

struct IronLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IronActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
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
            .background(Color(.systemBackground))
            
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
