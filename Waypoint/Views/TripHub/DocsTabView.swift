import SwiftUI

struct DocsTabView: View {
    let tripID: UUID
    @EnvironmentObject var store: TripStore
    @State private var selectedEvent: TripEvent?
    @State private var selectedAttachment: Attachment?

    private var trip: Trip? { store.trip(id: tripID) }

    var body: some View {
        List {
            ticketsSection
            cityDocsSections
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Documents")
        .overlay {
            if (trip?.events ?? []).isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "folder").font(.system(size: 48)).foregroundStyle(.secondary)
                    Text("No Documents").font(.title2).fontWeight(.semibold)
                    Text("Add events to see their documents here.")
                        .foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal)
                }
            }
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event, tripID: tripID)
        }
        .sheet(item: $selectedAttachment) { att in
            if att.hasPDF {
                PDFViewerView(attachment: att)
            } else if let qr = att.qrCodeContent {
                QRDisplayView(content: qr, title: att.displayName)
            }
        }
    }

    // MARK: - Vouchers & Tickets (with real attachments)

    @ViewBuilder
    private var ticketsSection: some View {
        let withAttachments = (trip?.events ?? []).filter { !$0.attachments.isEmpty }
        if !withAttachments.isEmpty {
            Section("Vouchers & Tickets") {
                ForEach(withAttachments) { event in
                    ForEach(event.attachments) { att in
                        Button {
                            selectedAttachment = att
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(event.type.color.opacity(0.15))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: att.kind.icon)
                                        .font(.body).foregroundStyle(event.type.color)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(att.displayName).font(.subheadline)
                                    Text(event.title).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                HStack(spacing: 4) {
                                    if att.hasQR {
                                        Image(systemName: "qrcode")
                                            .font(.caption2).foregroundStyle(.green)
                                    }
                                    if att.hasPDF {
                                        Image(systemName: "doc.fill")
                                            .font(.caption2).foregroundStyle(.red)
                                    }
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
        }
    }

    // MARK: - Per-city organisation

    @ViewBuilder
    private var cityDocsSections: some View {
        let cities = trip?.cities ?? []
        if !cities.isEmpty {
            ForEach(cities) { city in
                let cityEvents = cityDocEvents(for: city)
                if !cityEvents.isEmpty {
                    Section {
                        ForEach(cityEvents) { event in
                            eventRow(event)
                        }
                    } header: {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill").foregroundStyle(.red)
                            Text(city.name).fontWeight(.semibold)
                            Spacer()
                            Text(city.arrivalDate.shortDate).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        } else {
            // Fallback: flat sections by type if no cities configured
            flatSections
        }
    }

    private func cityDocEvents(for city: City) -> [TripEvent] {
        guard let trip else { return [] }
        return trip.events.filter { event in
            guard isDocEvent(event) else { return false }
            let d = event.startTime
            return d >= city.arrivalDate && d < city.departureDate
        }
        .sorted { $0.startTime < $1.startTime }
    }

    private func isDocEvent(_ e: TripEvent) -> Bool {
        e.type.isAccommodation || e.type == .flight || e.type == .train || e.type == .bus ||
        e.type == .guidedTour || e.type == .attraction || e.type == .show || !e.attachments.isEmpty
    }

    // MARK: - Flat fallback

    @ViewBuilder
    private var flatSections: some View {
        let events = trip?.events ?? []
        let accomms   = events.filter { $0.type.isAccommodation }
        let flights   = events.filter { $0.type == .flight }
        let transport = events.filter { $0.type == .train || $0.type == .bus }

        if !accomms.isEmpty   { Section("Accommodations")    { ForEach(accomms,   id: \.id) { eventRow($0) } } }
        if !flights.isEmpty   { Section("Flights")           { ForEach(flights,   id: \.id) { eventRow($0) } } }
        if !transport.isEmpty { Section("Ground Transport")  { ForEach(transport, id: \.id) { eventRow($0) } } }
    }

    // MARK: - Row

    private func eventRow(_ event: TripEvent) -> some View {
        Button { selectedEvent = event } label: {
            HStack(spacing: 12) {
                Image(systemName: event.type.icon)
                    .foregroundStyle(event.type.color)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title).font(.subheadline)
                    Text(event.startTime.shortDate).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    if !event.attachments.isEmpty {
                        if event.attachments.contains(where: { $0.hasQR }) {
                            Image(systemName: "qrcode").font(.caption2).foregroundStyle(.green)
                        }
                        if event.attachments.contains(where: { $0.hasPDF }) {
                            Image(systemName: "doc.fill").font(.caption2).foregroundStyle(.red)
                        }
                    } else if event.confirmationNumber != nil {
                        Image(systemName: "qrcode").font(.caption).foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .foregroundStyle(.primary)
    }
}
