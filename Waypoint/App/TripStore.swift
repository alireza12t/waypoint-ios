import Foundation

@MainActor
final class TripStore: ObservableObject {
    @Published var trips: [Trip] = []

    private static let storeURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("waypoint_trips.json")
    }()

    init() {
        Task { await bootstrap() }
    }

    // MARK: - Persistence (async)

    private func bootstrap() async {
        await load()
    }

    func save() async {
        let snapshot = trips
        let url = Self.storeURL
        await Task.detached(priority: .utility) {
            do {
                let data = try JSONEncoder().encode(snapshot)
                try data.write(to: url, options: .atomicWrite)
            } catch {
                print("[TripStore] save error: \(error)")
            }
        }.value
    }

    func load() async {
        let url = Self.storeURL
        let result: [Trip]? = await Task.detached(priority: .utility) {
            guard FileManager.default.fileExists(atPath: url.path) else { return nil }
            do {
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode([Trip].self, from: data)
            } catch {
                print("[TripStore] load error: \(error)")
                return nil
            }
        }.value
        if let result { trips = result }
    }

    // MARK: - Trip CRUD

    func addTrip(_ trip: Trip) {
        trips.append(trip)
        Task { await save() }
    }

    func updateTrip(_ trip: Trip) {
        guard let i = trips.firstIndex(where: { $0.id == trip.id }) else { return }
        trips[i] = trip
        Task { await save() }
    }

    func trip(id: UUID) -> Trip? { trips.first { $0.id == id } }

    // MARK: - Event CRUD

    func addEvent(_ event: TripEvent, to tripID: UUID) {
        guard let i = trips.firstIndex(where: { $0.id == tripID }) else { return }
        trips[i].events.append(event)
        NotificationManager.shared.schedule(event)
        Task { await save() }
    }

    func updateEvent(_ event: TripEvent, in tripID: UUID) {
        guard let ti = trips.firstIndex(where: { $0.id == tripID }),
              let ei = trips[ti].events.firstIndex(where: { $0.id == event.id }) else { return }
        trips[ti].events[ei] = event
        NotificationManager.shared.schedule(event)
        Task { await save() }
    }

    func toggleDone(_ eventID: UUID, in tripID: UUID) {
        guard let ti = trips.firstIndex(where: { $0.id == tripID }),
              let ei = trips[ti].events.firstIndex(where: { $0.id == eventID }) else { return }
        trips[ti].events[ei].isDone.toggle()
        let updated = trips[ti].events[ei]
        if updated.isDone { NotificationManager.shared.cancel(eventID) }
        else               { NotificationManager.shared.schedule(updated) }
        Task { await save() }
    }

    func deleteEvent(id: UUID, from tripID: UUID) {
        guard let ti = trips.firstIndex(where: { $0.id == tripID }) else { return }
        trips[ti].events.removeAll { $0.id == id }
        NotificationManager.shared.cancel(id)
        Task { await save() }
    }

    func deleteTrip(id: UUID) {
        if let trip = trips.first(where: { $0.id == id }) {
            NotificationManager.shared.cancelAll(for: trip.events)
        }
        trips.removeAll { $0.id == id }
        Task { await save() }
    }

    // MARK: - Receipt CRUD

    func addReceipt(_ receipt: Receipt, to tripID: UUID) {
        guard let i = trips.firstIndex(where: { $0.id == tripID }) else { return }
        trips[i].receipts.append(receipt)
        Task { await save() }
    }

    func deleteReceipt(id: UUID, from tripID: UUID) {
        guard let i = trips.firstIndex(where: { $0.id == tripID }) else { return }
        trips[i].receipts.removeAll { $0.id == id }
        Task { await save() }
    }
}
