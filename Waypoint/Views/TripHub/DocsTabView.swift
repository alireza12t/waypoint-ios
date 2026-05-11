import SwiftUI

struct DocsTabView: View {
    let tripID: UUID
    @EnvironmentObject var store: TripStore
    @State private var selectedEvent: TripEvent?

    private var trip: Trip? { store.trip(id: tripID) }

    var body: some View {
        List {
            let accomms   = trip?.events.filter { $0.type.isAccommodation } ?? []
            let flights   = trip?.events.filter { $0.type == .flight } ?? []
            let transport = trip?.events.filter { $0.type == .train || $0.type == .bus } ?? []

            if !accomms.isEmpty {
                Section("Accommodations") {
                    ForEach(accomms) { event in
                        eventRow(event)
                    }
                }
            }
            if !flights.isEmpty {
                Section("Flights") {
                    ForEach(flights) { event in
                        eventRow(event)
                    }
                }
            }
            if !transport.isEmpty {
                Section("Ground Transport") {
                    ForEach(transport) { event in
                        eventRow(event)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            let all = (trip?.events ?? []).filter { $0.type.isAccommodation || $0.type == .flight || $0.type == .train || $0.type == .bus }
            if all.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "folder").font(.system(size: 48)).foregroundStyle(.secondary)
                    Text("No Documents").font(.title2).fontWeight(.semibold)
                    Text("Add flights, hotels, and transport events to see them here.")
                        .foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal)
                }
            }
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event, tripID: tripID)
        }
    }

    private func eventRow(_ event: TripEvent) -> some View {
        Button {
            selectedEvent = event
        } label: {
            HStack(spacing: 12) {
                Image(systemName: event.type.icon)
                    .foregroundStyle(event.type.color)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title).font(.subheadline)
                    Text(event.startTime.shortDate).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if event.confirmationNumber != nil {
                    Image(systemName: "qrcode").font(.caption).foregroundStyle(.tertiary)
                }
            }
        }
        .foregroundStyle(.primary)
    }
}
