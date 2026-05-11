import SwiftUI

struct TripHubView: View {
    let tripID: UUID
    @EnvironmentObject var store: TripStore
    @State private var selectedTab = 0
    @State private var showAddEvent = false

    var body: some View {
        guard let trip = store.trip(id: tripID) else {
            return AnyView(
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle").font(.largeTitle).foregroundStyle(.secondary)
                    Text("Trip not found").foregroundStyle(.secondary)
                }
            )
        }
        return AnyView(hub(trip: trip))
    }

    private func hub(trip: Trip) -> some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                TripTimelineView(tripID: tripID)
                    .tabItem { Label("Timeline", systemImage: "calendar.day.timeline.left") }.tag(0)
                MapTabView(tripID: tripID)
                    .tabItem { Label("Map", systemImage: "map") }.tag(1)
                WalletTabView(tripID: tripID)
                    .tabItem { Label("Wallet", systemImage: "wallet.pass.fill") }.tag(2)
                DocsTabView(tripID: tripID)
                    .tabItem { Label("Docs", systemImage: "folder.fill") }.tag(3)
                BudgetTabView(tripID: tripID)
                    .tabItem { Label("Budget", systemImage: "chart.pie.fill") }.tag(4)
            }

            if selectedTab == 0 || selectedTab == 1 {
                Button { showAddEvent = true } label: {
                    Image(systemName: "plus")
                        .font(.title2).fontWeight(.semibold).foregroundStyle(.black)
                        .frame(width: 56, height: 56)
                        .background(Color.waypointAmber)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.trailing, 20).padding(.bottom, 90)
            }
        }
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddEvent) {
            AddEventView(tripID: tripID)
                .presentationDetents([.medium, .large])
        }
    }
}
