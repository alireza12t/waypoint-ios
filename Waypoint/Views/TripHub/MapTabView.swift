import SwiftUI
import MapKit

enum MapPinKind { case departure, arrival, single }

struct MapPin: Identifiable {
    let id: UUID
    let event: TripEvent
    let kind: MapPinKind
    let orderNumber: Int?  // shown only when day-filter active
    var coordinate: CLLocationCoordinate2D {
        switch kind {
        case .arrival:
            return CLLocationCoordinate2D(latitude: event.arrivalLatitude ?? 0,
                                          longitude: event.arrivalLongitude ?? 0)
        default:
            return CLLocationCoordinate2D(latitude: event.latitude ?? 0, longitude: event.longitude ?? 0)
        }
    }
}

struct MapTabView: View {
    let tripID: UUID
    @EnvironmentObject var store: TripStore
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var cityIndex: Int = 0
    @State private var selectedDay: Date? = nil
    @State private var selectedPin: TripEvent?

    var body: some View {
        guard let trip = store.trip(id: tripID) else { return AnyView(EmptyView()) }
        return AnyView(mapContent(trip: trip))
    }

    private func mapContent(trip: Trip) -> some View {
        let filteredEvents = eventsToShow(trip: trip)
        let pins = makePins(filteredEvents, dayFiltered: selectedDay != nil)

        return ZStack(alignment: .top) {
            Map(coordinateRegion: $region, annotationItems: pins) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    MapPinView(event: pin.event, kind: pin.kind, orderNumber: pin.orderNumber)
                        .onTapGesture { selectedPin = pin.event }
                }
            }
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                // City switcher
                if trip.cities.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(trip.cities.enumerated()), id: \.element.id) { i, city in
                                Button {
                                    cityIndex = i
                                    selectedDay = nil
                                    withAnimation {
                                        region = MKCoordinateRegion(
                                            center: city.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06))
                                    }
                                } label: {
                                    Text(city.name)
                                        .font(.subheadline)
                                        .fontWeight(cityIndex == i ? .semibold : .regular)
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(cityIndex == i ? Color.waypointAmber : Color.waypointCard)
                                        .foregroundStyle(cityIndex == i ? .black : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal).padding(.vertical, 8)
                    }
                    .background(.ultraThinMaterial)
                }

                // Day filter for multi-day city stays
                let currentCity = trip.cities.indices.contains(cityIndex) ? trip.cities[cityIndex] : nil
                if let city = currentCity {
                    let days = allDays(in: city)
                    if days.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                Button {
                                    withAnimation { selectedDay = nil }
                                } label: {
                                    Text("All days")
                                        .font(.caption).fontWeight(selectedDay == nil ? .semibold : .regular)
                                        .padding(.horizontal, 10).padding(.vertical, 5)
                                        .background(selectedDay == nil ? Color.white.opacity(0.9) : Color.white.opacity(0.35))
                                        .foregroundStyle(.black)
                                        .clipShape(Capsule())
                                }
                                ForEach(days, id: \.self) { day in
                                    let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDay ?? .distantPast)
                                    Button {
                                        withAnimation { selectedDay = isSelected ? nil : day }
                                    } label: {
                                        Text(dayLabel(day))
                                            .font(.caption).fontWeight(isSelected ? .semibold : .regular)
                                            .padding(.horizontal, 10).padding(.vertical, 5)
                                            .background(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.35))
                                            .foregroundStyle(.black)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 12).padding(.vertical, 6)
                        }
                        .background(.ultraThinMaterial)
                    }
                }
            }
        }
        .sheet(item: $selectedPin) { event in
            EventDetailView(event: event, tripID: tripID)
                .presentationDetents([.medium])
        }
        .onAppear {
            if let city = trip.cities.first {
                region = MKCoordinateRegion(center: city.coordinate,
                                             span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06))
            }
        }
    }

    // MARK: - Helpers

    private func eventsToShow(trip: Trip) -> [TripEvent] {
        let located = trip.events.filter { $0.hasLocation }
        guard let day = selectedDay else {
            // All days → filter to current city's date range
            if let city = trip.cities.indices.contains(cityIndex) ? trip.cities[cityIndex] : nil {
                return located.filter { $0.startTime >= city.arrivalDate && $0.startTime < city.departureDate }
                              .sorted { $0.startTime < $1.startTime }
            }
            return located
        }
        let cal = Calendar.current
        return located.filter { cal.isDate($0.startTime, inSameDayAs: day) }
                      .sorted { $0.startTime < $1.startTime }
    }

    private func makePins(_ events: [TripEvent], dayFiltered: Bool) -> [MapPin] {
        var pins: [MapPin] = []
        for (i, e) in events.enumerated() {
            let order = dayFiltered ? i + 1 : nil
            if e.hasLocation {
                let kind: MapPinKind = e.type.isTransport ? .departure : .single
                pins.append(MapPin(id: e.id, event: e, kind: kind, orderNumber: order))
            }
            if e.type.isTransport && e.hasArrivalLocation {
                pins.append(MapPin(id: UUID(), event: e, kind: .arrival, orderNumber: nil))
            }
        }
        return pins
    }

    private func allDays(in city: City) -> [Date] {
        var days: [Date] = []; var d = city.arrivalDate; let cal = Calendar.current
        while d < city.departureDate {
            days.append(d)
            d = cal.date(byAdding: .day, value: 1, to: d) ?? d.addingTimeInterval(86400)
        }
        return days
    }

    private func dayLabel(_ date: Date) -> String {
        let fmt = DateFormatter(); fmt.dateFormat = "EEE d"
        return fmt.string(from: date)
    }
}

// MARK: - Pin view with optional order badge

struct MapPinView: View {
    let event: TripEvent
    let kind: MapPinKind
    let orderNumber: Int?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if kind == .arrival {
                // Outlined pin = arrival point
                ZStack {
                    Circle()
                        .strokeBorder(event.type.color, lineWidth: 3)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color(UIColor.systemBackground)))
                        .shadow(color: .black.opacity(0.2), radius: 3)
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(event.type.color)
                }
            } else {
                // Filled pin = departure or single location
                ZStack {
                    Circle().fill(event.type.color).frame(width: 36, height: 36)
                        .shadow(color: .black.opacity(0.3), radius: 3)
                    Image(systemName: event.type.icon).font(.system(size: 14)).foregroundStyle(.white)
                }
            }
            if let n = orderNumber {
                Text("\(n)")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 18, height: 18)
                    .background(Color.black)
                    .clipShape(Circle())
                    .offset(x: 6, y: -6)
            }
        }
        .frame(width: 42, height: 42)
    }
}
