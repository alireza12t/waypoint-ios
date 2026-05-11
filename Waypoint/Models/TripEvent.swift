import Foundation

enum NotificationOffset: String, Codable, CaseIterable {
    case atTime = "At time"
    case thirtyMin = "30 min before"
    case oneHour = "1 hour before"
    case twoHours = "2 hours before"
}

struct TripEvent: Identifiable, Codable {
    var id: UUID = UUID()
    var type: EventType
    var title: String
    var startTime: Date
    var endTime: Date? = nil
    var locationName: String? = nil     // departure station / starting point
    var latitude: Double? = nil
    var longitude: Double? = nil
    var arrivalLocationName: String? = nil  // arrival station / end point (transport only)
    var arrivalLatitude: Double? = nil
    var arrivalLongitude: Double? = nil
    var confirmationNumber: String? = nil
    var warningNotes: [String] = []
    var notes: String = ""
    var attachments: [Attachment] = []
    var calendarEventID: String? = nil
    var isDone: Bool = false
    var notificationEnabled: Bool = false
    var notificationOffset: NotificationOffset = .thirtyMin
    var payload: EventPayload = .none

    var hasLocation: Bool { latitude != nil && longitude != nil }
    var hasArrivalLocation: Bool { arrivalLatitude != nil && arrivalLongitude != nil }

    var durationText: String? {
        guard let end = endTime else { return nil }
        let mins = Int(end.timeIntervalSince(startTime) / 60)
        guard mins > 0 else { return nil }
        let h = mins / 60; let m = mins % 60
        return h == 0 ? "\(m)m" : m == 0 ? "\(h)h" : "\(h)h \(m)m"
    }
}
