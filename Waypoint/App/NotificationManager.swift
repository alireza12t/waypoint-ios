import UserNotifications
import Foundation

final class NotificationManager {
    static let shared = NotificationManager()

    // MARK: - Schedule

    func schedule(_ event: TripEvent) {
        cancel(event.id)
        guard event.notificationEnabled, !event.isDone else { return }

        let fireDate = event.startTime.addingTimeInterval(-event.notificationOffset.seconds)
        guard fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body  = notificationBody(for: event)
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("[Notifications] schedule error: \(error)") }
        }
    }

    // MARK: - Cancel

    func cancel(_ id: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }

    func cancelAll(for events: [TripEvent]) {
        let ids = events.map { $0.id.uuidString }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Helpers

    private func notificationBody(for event: TripEvent) -> String {
        var parts: [String] = []
        if let loc = event.locationName { parts.append(loc) }
        parts.append("at \(event.startTime.timeLabel)")
        if event.notificationOffset != .atTime {
            parts.append("(\(event.notificationOffset.rawValue))")
        }
        return parts.joined(separator: " · ")
    }
}

extension NotificationOffset {
    var seconds: TimeInterval {
        switch self {
        case .atTime:    return 0
        case .thirtyMin: return 30 * 60
        case .oneHour:   return 60 * 60
        case .twoHours:  return 2 * 60 * 60
        }
    }
}
