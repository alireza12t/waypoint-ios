import SwiftUI

enum EventType: String, Codable, CaseIterable {
    case flight, train, bus, ferry
    case hotel, airbnb, hostel
    case attraction, guidedTour, restaurant, nightlife, show, viewpoint, beach, custom

    var displayName: String {
        switch self {
        case .flight: return "Flight"
        case .train: return "Train"
        case .bus: return "Bus"
        case .ferry: return "Ferry"
        case .hotel: return "Hotel"
        case .airbnb: return "Airbnb"
        case .hostel: return "Hostel"
        case .attraction: return "Attraction"
        case .guidedTour: return "Guided Tour"
        case .restaurant: return "Restaurant"
        case .nightlife: return "Nightlife"
        case .show: return "Show / Match"
        case .viewpoint: return "Viewpoint"
        case .beach: return "Beach"
        case .custom: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .flight: return "airplane"
        case .train: return "tram.fill"
        case .bus: return "bus.fill"
        case .ferry: return "ferry.fill"
        case .hotel: return "bed.double.fill"
        case .airbnb: return "house.fill"
        case .hostel: return "bunk.bed.fill"
        case .attraction: return "building.columns.fill"
        case .guidedTour: return "person.2.fill"
        case .restaurant: return "fork.knife"
        case .nightlife: return "music.note.list"
        case .show: return "theatermasks.fill"
        case .viewpoint: return "binoculars.fill"
        case .beach: return "beach.umbrella.fill"
        case .custom: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .flight: return .blue
        case .train: return .teal
        case .bus: return .green
        case .ferry: return .cyan
        case .hotel: return Color(red: 0.4, green: 0.3, blue: 0.9)
        case .airbnb: return .pink
        case .hostel: return .purple
        case .attraction: return .orange
        case .guidedTour: return .red
        case .restaurant: return Color(red: 0.9, green: 0.7, blue: 0.1)
        case .nightlife: return Color(red: 0.6, green: 0.1, blue: 0.8)
        case .show: return Color(red: 0.85, green: 0.1, blue: 0.3)
        case .viewpoint: return .cyan
        case .beach: return Color(red: 0.9, green: 0.75, blue: 0.3)
        case .custom: return .gray
        }
    }

    var isTransport: Bool { [.flight, .train, .bus, .ferry].contains(self) }
    var isAccommodation: Bool { [.hotel, .airbnb, .hostel].contains(self) }
    var isTicketed: Bool { isTransport || [.attraction, .guidedTour, .show].contains(self) }
}
