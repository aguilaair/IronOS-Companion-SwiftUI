import SwiftUI
import SwiftData

@Model
class AppState {
    var savedIrons: [Iron]
    var lastConnectedIronID: UUID?
    var hasCompletedOnboarding: Bool
    @EnvironmentObject var bleManager: BLEManager

    init(savedIrons: [Iron] = [], lastConnectedIronID: UUID? = nil, hasCompletedOnboarding: Bool = false) {
        self.savedIrons = savedIrons
        self.lastConnectedIronID = lastConnectedIronID
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    // Method that checks wether BLEManager is connected to an iron
    func isConnectedToIron() -> Bool {
        return bleManager.connectionStatus == .connected
    }

    func getConnectedIron() -> Iron? {
        return bleManager.connectedIron
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
