import SwiftUI

struct WalletTabView: View {
    let tripID: UUID
    @EnvironmentObject var store: TripStore
    @State private var selected: TripEvent?

    var body: some View {
        guard let trip = store.trip(id: tripID) else { return AnyView(EmptyView()) }
        let tickets = trip.ticketEvents
        let today   = Calendar.current.startOfDay(for: Date())

        let todayList    = tickets.filter { Calendar.current.isDateInToday($0.startTime) }
        let upcomingList = tickets.filter { $0.startTime > today && !Calendar.current.isDateInToday($0.startTime) }
        let pastList     = tickets.filter { $0.startTime < today }

        return AnyView(
            Group {
                if tickets.isEmpty {
                    emptyWallet
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            if !todayList.isEmpty    { section("Today",    events: todayList) }
                            if !upcomingList.isEmpty { section("Upcoming", events: upcomingList) }
                            if !pastList.isEmpty     { section("Past",     events: pastList) }
                        }
                        .padding()
                    }
                }
            }
            .sheet(item: $selected) { event in
                if let conf = event.confirmationNumber {
                    QRDisplayView(content: conf, title: event.title)
                } else {
                    EventDetailView(event: event, tripID: tripID)
                }
            }
        )
    }

    private func section(_ title: String, events: [TripEvent]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline).foregroundStyle(.secondary)
            ForEach(events) { event in
                TicketCard(event: event).onTapGesture { selected = event }
            }
        }
    }

    @ViewBuilder
    private var emptyWallet: some View {
        VStack(spacing: 16) {
            Image(systemName: "wallet.pass").font(.system(size: 48)).foregroundStyle(.secondary)
            Text("No Tickets Yet").font(.title2).fontWeight(.semibold)
            Text("Tap + to scan a QR code or import a ticket").foregroundStyle(.secondary)
                .multilineTextAlignment(.center).padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
