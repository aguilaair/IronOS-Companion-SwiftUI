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
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(bleManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
