import SwiftUI

struct TripsView: View {
    @EnvironmentObject var store: TripStore
    @State private var showNewTrip = false
    @State private var showSettings = false

    private var activeTrips: [Trip] {
        store.trips.filter { !$0.isArchived && $0.status != .past }
            .sorted { $0.startDate < $1.startDate }
    }
    private var pastTrips: [Trip] {
        store.trips.filter { !$0.isArchived && $0.status == .past }
            .sorted { $0.startDate > $1.startDate }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.waypointBg.ignoresSafeArea()
                if store.trips.isEmpty { emptyState } else { tripList }
            }
            .navigationTitle("Waypoint")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showSettings = true } label: { Image(systemName: "gear") }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showNewTrip = true } label: {
                        Image(systemName: "plus").fontWeight(.semibold)
                    }
                }
            }
            .navigationDestination(for: UUID.self) { id in
                TripHubView(tripID: id)
            }
        }
        .sheet(isPresented: $showNewTrip)  { NewTripView() }
        .sheet(isPresented: $showSettings) { SettingsView() }
    }

    private var tripList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(activeTrips) { trip in
                    NavigationLink(value: trip.id) { TripCard(trip: trip) }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) { store.deleteTrip(id: trip.id) } label: {
                                Label("Delete Trip", systemImage: "trash")
                            }
                        }
                }
                if !pastTrips.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Past Trips")
                            .font(.headline).foregroundStyle(.secondary).padding(.horizontal)
                        ForEach(pastTrips) { trip in
                            NavigationLink(value: trip.id) { TripCard(trip: trip) }
                                .buttonStyle(.plain).opacity(0.65)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("🌍").font(.system(size: 64))
            Text("No trips yet").font(.title2).fontWeight(.semibold)
            Text("Tap + to plan your first trip").foregroundStyle(.secondary)
            Button("New Trip") { showNewTrip = true }
                .buttonStyle(.borderedProminent).tint(.waypointAmber)
        }
    }
}
