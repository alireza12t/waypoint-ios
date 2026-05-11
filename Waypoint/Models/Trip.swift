import Foundation

enum TripStatus { case upcoming, active, past }

struct Trip: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var cities: [City] = []
    var startDate: Date
    var endDate: Date
    var currency: String = "CAD"
    var budget: Double? = nil
    var events: [TripEvent] = []
    var receipts: [Receipt] = []
    var coverEmoji: String = "🌍"
    var isArchived: Bool = false

    var status: TripStatus {
        let now = Date()
        if now < startDate { return .upcoming }
        if now > endDate { return .past }
        return .active
    }

    var daysUntilDeparture: Int? {
        guard status == .upcoming else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: startDate).day
    }

    var totalDays: Int {
        max(1, Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0)
    }

    var currentDayNumber: Int? {
        let now = Date()
        guard now >= startDate, now <= endDate else { return nil }
        return (Calendar.current.dateComponents([.day], from: startDate, to: now).day ?? 0) + 1
    }

    var totalSpent: Double { receipts.reduce(0) { $0 + $1.amount } }

    var allDates: [Date] {
        var result: [Date] = []
        var d = Calendar.current.startOfDay(for: startDate)
        let end = Calendar.current.startOfDay(for: endDate)
        while d <= end {
            result.append(d)
            d = Calendar.current.date(byAdding: .day, value: 1, to: d)!
        }
        return result
    }

    func events(for date: Date) -> [TripEvent] {
        events
            .filter { Calendar.current.isDate($0.startTime, inSameDayAs: date) }
            .sorted { $0.startTime < $1.startTime }
    }

    func city(for date: Date) -> City? {
        let cal = Calendar.current
        let d = cal.startOfDay(for: date)
        return cities.first {
            d >= cal.startOfDay(for: $0.arrivalDate) && d <= cal.startOfDay(for: $0.departureDate)
        }
    }

    var ticketEvents: [TripEvent] {
        events.filter { $0.type.isTicketed }.sorted { $0.startTime < $1.startTime }
    }
}
