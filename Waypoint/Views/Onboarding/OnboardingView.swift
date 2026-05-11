import SwiftUI
import AVFoundation
import CoreLocation
import UserNotifications

struct OnboardingView: View {
    @Binding var isComplete: Bool
    @State private var page = 0

    var body: some View {
        ZStack {
            Color.waypointNavy.ignoresSafeArea()
            TabView(selection: $page) {
                welcomePage.tag(0)
                PermissionPage(
                    icon: "camera.fill", color: .blue,
                    title: "Scan Tickets & QR Codes",
                    description: "Point your camera at any booking confirmation, QR code, or barcode to import it instantly.",
                    buttonLabel: "Allow Camera", action: requestCamera, onSkip: advance
                ).tag(1)
                PermissionPage(
                    icon: "location.fill", color: .green,
                    title: "Show Events on the Map",
                    description: "Your location helps centre the map on where you are during the trip. Never used for tracking.",
                    buttonLabel: "Allow Location", action: requestLocation, onSkip: advance
                ).tag(2)
                PermissionPage(
                    icon: "bell.badge.fill", color: Color.waypointAmber,
                    title: "Event Reminders",
                    description: "Get a nudge before flights, tours, and timed bookings — max 2 per event, nothing spammy.",
                    buttonLabel: "Allow Notifications", action: requestNotifications, onSkip: advance
                ).tag(3)
                readyPage.tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Pages

    private var welcomePage: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 16) {
                Text("✈️").font(.system(size: 80))
                Text("Waypoint").font(.largeTitle).fontWeight(.bold).foregroundStyle(.white)
                Text("Your travel companion.\nEverything for the trip, nothing extra.")
                    .font(.title3).foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center).padding(.horizontal)
            }
            Spacer()
            Button { withAnimation { page = 1 } } label: {
                Text("Get Started")
                    .fontWeight(.semibold).frame(maxWidth: .infinity).padding()
                    .background(Color.waypointAmber).foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32).padding(.bottom, 60)
        }
    }

    private var readyPage: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 72)).foregroundStyle(Color.waypointAmber)
                Text("You're all set").font(.largeTitle).fontWeight(.bold).foregroundStyle(.white)
                Text("Add your first trip to get started.")
                    .font(.title3).foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center).padding(.horizontal)
            }
            Spacer()
            Button { withAnimation { isComplete = true } } label: {
                Text("Start Planning")
                    .fontWeight(.semibold).frame(maxWidth: .infinity).padding()
                    .background(Color.waypointAmber).foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32).padding(.bottom, 60)
        }
    }

    // MARK: - Permission requests

    private func advance() { withAnimation { page += 1 } }

    private func requestCamera() {
        AVCaptureDevice.requestAccess(for: .video) { _ in
            DispatchQueue.main.async { self.advance() }
        }
    }

    private func requestLocation() {
        LocationPermissionRequester.shared.request { advance() }
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                DispatchQueue.main.async { self.advance() }
            }
    }
}

// MARK: - Reusable permission page

private struct PermissionPage: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    let buttonLabel: String
    let action: () -> Void   // requests permission AND advances
    let onSkip: () -> Void   // advances without requesting

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 120, height: 120)
                Image(systemName: icon).font(.system(size: 52)).foregroundStyle(color)
            }
            .padding(.bottom, 32)

            Text(title).font(.title2).fontWeight(.bold).foregroundStyle(.white)
                .multilineTextAlignment(.center).padding(.horizontal, 32)
            Text(description).font(.body).foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center).padding(.horizontal, 40).padding(.top, 12)

            Spacer()
            VStack(spacing: 12) {
                Button(action: action) {
                    Text(buttonLabel)
                        .fontWeight(.semibold).frame(maxWidth: .infinity).padding()
                        .background(color).foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                Button("Skip for now") { onSkip() }
                    .font(.subheadline).foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 32).padding(.bottom, 60)
        }
    }
}

// MARK: - Location helper

private final class LocationPermissionRequester: NSObject, CLLocationManagerDelegate {
    static let shared = LocationPermissionRequester()
    private let manager = CLLocationManager()
    private var completion: (() -> Void)?

    func request(completion: @escaping () -> Void) {
        self.completion = completion
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus != .notDetermined else { return }
        DispatchQueue.main.async { self.completion?(); self.completion = nil }
    }
}
