import SwiftUI

@main
struct WaypointApp: App {
    @StateObject private var store = TripStore()

    var body: some Scene {
        WindowGroup {
            TripsView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
