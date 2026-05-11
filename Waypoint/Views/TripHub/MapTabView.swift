import SwiftUI
import MapKit

struct MapPin: Identifiable {
    let id = UUID()
    let event: TripEvent
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: event.latitude ?? 0, longitude: event.longitude ?? 0)
    }
}

struct MapTabView: View {
    let tripID: UUID
    @EnvironmentObject var store: TripStore
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var cityIndex = 0
    @State private var selectedPin: TripEvent?

    var body: some View {
        guard let trip = store.trip(id: tripID) else { return AnyView(EmptyView()) }
        let pins = trip.events.filter { $0.hasLocation }.map { MapPin(event: $0) }
        return AnyView(mapContent(trip: trip, pins: pins))
    }

    private func mapContent(trip: Trip, pins: [MapPin]) -> some View {
        ZStack(alignment: .top) {
            Map(coordinateRegion: $region, annotationItems: pins) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    MapPinView(event: pin.event)
                        .onTapGesture { selectedPin = pin.event }
                }
            }
            .ignoresSafeArea(edges: .top)

            if trip.cities.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(trip.cities.enumerated()), id: \.element.id) { i, city in
                            Button {
                                cityIndex = i
                                withAnimation {
                                    region = MKCoordinateRegion(center: city.coordinate,
                                                                 span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
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
        }
        .sheet(item: $selectedPin) { event in
            EventDetailView(event: event, tripID: tripID)
                .presentationDetents([.medium])
        }
        .onAppear {
            if let city = trip.cities.first {
                region = MKCoordinateRegion(center: city.coordinate,
                                             span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
            }
        }
    }
}

struct MapPinView: View {
    let event: TripEvent
    var body: some View {
        ZStack {
            Circle().fill(event.type.color).frame(width: 34, height: 34)
                .shadow(color: .black.opacity(0.3), radius: 3)
            Image(systemName: event.type.icon).font(.system(size: 14)).foregroundStyle(.white)
        }
    }
}
