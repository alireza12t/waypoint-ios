import SwiftUI

@main
struct WaypointApp: App {
    @StateObject private var store = TripStore()
    @AppStorage("onboardingComplete") private var onboardingComplete = false

    var body: some Scene {
        WindowGroup {
            if onboardingComplete {
                TripsView()
                    .environmentObject(store)
                    .preferredColorScheme(.dark)
            } else {
                OnboardingView(isComplete: $onboardingComplete)
            }
        }
    }
}
