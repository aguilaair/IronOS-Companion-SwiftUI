//
//  IronOS_CompanionApp.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/26/25.
//

import SwiftUI
import SwiftData
import CoreBluetooth

@main
struct IronOS_CompanionApp: App {
    @StateObject private var bleManager = BLEManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Iron.self,
            AppState.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            // Initialize AppState if it doesn't exist
            let context = container.mainContext
            let descriptor = FetchDescriptor<AppState>()
            if try context.fetch(descriptor).isEmpty {
                let appState = AppState()
                appState.bleManager = BLEManager.shared
                context.insert(appState)
                try context.save()
            } else {
                // Update existing AppState with BLEManager
                if let appState = try context.fetch(descriptor).first {
                    appState.bleManager = BLEManager.shared
                    try context.save()
                }
            }
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bleManager)
        }
        .modelContainer(sharedModelContainer)
    }
}

struct ContentView: View {
    @Query private var appState: [AppState]
    
    var body: some View {
        if let state = appState.first {
            if state.hasCompletedOnboarding {
                DeviceDashView()
            } else {
                WelcomeView()
            }
        } else {
            // This should never happen as we initialize AppState in the container
            WelcomeView()
        }
    }
}
