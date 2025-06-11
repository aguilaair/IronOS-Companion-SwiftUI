import SwiftUI
import SwiftData
import IronOSCompanionShared

@Model
class AppState {
    var savedIrons: [Iron]
    var lastConnectedIronID: UUID?
    var hasCompletedOnboarding: Bool
    @Transient var bleManager: BLEManager? {
        didSet {
            if let bleManager = bleManager, let lastID = lastConnectedIronID {
                // Start scanning for devices
                bleManager.startScanning()
                
                // Wait for devices to be discovered before attempting to connect
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if let iron = bleManager.irons.first(where: { $0.id == lastID }) {
                        bleManager.attemptConnectToLastIron(iron: iron)
                    }
                }
            }
        }
    }
    @Transient var latestData: IronData?

    init(savedIrons: [Iron] = [], lastConnectedIronID: UUID? = nil, hasCompletedOnboarding: Bool = false) {
        self.savedIrons = savedIrons
        self.lastConnectedIronID = lastConnectedIronID
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    // Method that checks wether BLEManager is connected to an iron
    func isConnectedToIron() -> Bool {
        return bleManager?.connectionStatus == .connected
    }

    func getConnectedIron() -> Iron? {
        return bleManager?.connectedIron
    }
    
    // Helper methods
    func addIron(_ iron: Iron) {
        if !savedIrons.contains(where: { $0.id == iron.id }) {
            savedIrons.append(iron)
        }
    }
    
    func removeIron(_ iron: Iron) {
        savedIrons.removeAll { $0.id == iron.id }
        if lastConnectedIronID == iron.id {
            lastConnectedIronID = nil
        }
    }
    
    func getIron(by id: UUID) -> Iron? {
        savedIrons.first { $0.id == id }
    }
    
    func updateLastConnectedIron(_ iron: Iron) {
        lastConnectedIronID = iron.id
    }
    
    func markOnboardingComplete() {
        hasCompletedOnboarding = true
    }
} 
