import SwiftUI

struct TripTimelineView: View {
    let tripID: UUID
    @EnvironmentObject var store: TripStore
    @State private var expanded: Set<Date> = []
    @State private var selectedEvent: TripEvent?

    var body: some View {
        guard let trip = store.trip(id: tripID) else { return AnyView(EmptyView()) }
        return AnyView(
            ScrollViewReader { proxy in
                List {
                    ForEach(trip.allDates, id: \.self) { date in
                        let events  = trip.events(for: date)
                        let city    = trip.city(for: date)
                        let isToday = Calendar.current.isDateInToday(date)
                        let isOpen  = expanded.contains(date) || isToday

                        Section {
                            if isOpen {
                                if events.isEmpty {
                                    Text("Free day").font(.subheadline).foregroundStyle(.tertiary)
                                        .padding(.vertical, 4)
                                } else {
                                    ForEach(events) { event in
                                        EventCard(event: event, tripID: tripID)
                                            .contentShape(Rectangle())
                                            .onTapGesture { selectedEvent = event }
                                            .swipeActions(edge: .leading) {
                                                Button {
                                                    store.toggleDone(event.id, in: tripID)
                                                } label: { Label("Done", systemImage: "checkmark") }
                                                    .tint(.green)
                                            }
                                            .swipeActions(edge: .trailing) {
                                                Button(role: .destructive) {
                                                    store.deleteEvent(id: event.id, from: tripID)
                                                } label: { Label("Delete", systemImage: "trash") }
                                            }
                                    }
                                }
                            }
                        } header: {
                            DayHeader(date: date, city: city, isToday: isToday, isOpen: isOpen) {
                                withAnimation(.spring(duration: 0.25)) {
                                    if expanded.contains(date) { expanded.remove(date) }
                                    else { expanded.insert(date) }
                                }
                            }
                            .id(date)
                        }
                        .listSectionSeparator(.hidden)
                    }
                }
                .listStyle(.insetGrouped)
                .onAppear {
                    if let today = trip.allDates.first(where: { Calendar.current.isDateInToday($0) }) {
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 300_000_000)
                            proxy.scrollTo(today, anchor: .top)
                        }
                    }
                }
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event, tripID: tripID)
            }
        )
    }
}

// MARK: - Day Header

struct DayHeader: View {
    let date: Date
    let city: City?
    let isToday: Bool
    let isOpen: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        if isToday {
                            Text("TODAY")
                                .font(.caption2).fontWeight(.bold).foregroundStyle(.black)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.waypointAmber).clipShape(Capsule())
                        }
                        Text(date.dayLabel)
                            .font(.subheadline)
                            .fontWeight(isToday ? .bold : .semibold)
                            .foregroundStyle(isToday ? .primary : .secondary)
                    }
                    if let city {
                        Text(city.name).font(.caption).foregroundStyle(.tertiary)
                    }
                }
                Spacer()
                Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                    .font(.caption2).foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}
