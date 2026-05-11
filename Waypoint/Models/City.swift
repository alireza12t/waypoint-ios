import Foundation
import CoreLocation

struct City: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var country: String
    var countryCode: String = ""
    var latitude: Double
    var longitude: Double
    var arrivalDate: Date
    var departureDate: Date

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var displayName: String { "\(name), \(country)" }
}
