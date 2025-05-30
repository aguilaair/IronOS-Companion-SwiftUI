import SwiftUI
import SwiftData

struct DeviceDashView: View {
    @EnvironmentObject var bleManager: BLEManager
    @Query private var appState: [AppState]
    @State private var showDeviceList = false
    
    private var state: AppState? {
        appState.first
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("My Irons")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 8)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(MockBLEManager() as BLEManager)
} 
