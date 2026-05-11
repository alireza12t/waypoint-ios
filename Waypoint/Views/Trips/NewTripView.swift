import SwiftUI

struct NewTripView: View {
    @EnvironmentObject var store: TripStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    @State private var currency = "CAD"
    @State private var budget = ""
    @State private var emoji = "🌍"

    private let emojis   = ["🌍","🗺️","✈️","🧳","🏝️","🏔️","🇪🇸","🇫🇷","🇮🇹","🇯🇵","🇬🇷","🇵🇹","🇧🇷","🇲🇽","🇹🇭"]
    private let currencies = ["CAD","USD","EUR","GBP","JPY","AUD","CHF","SEK","MXN"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Name") {
                    TextField("e.g. Spain · May 2026", text: $name)
                }
                Section("Cover") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(emojis, id: \.self) { e in
                                Text(e).font(.title)
                                    .padding(10)
                                    .background(emoji == e ? Color.waypointAmber.opacity(0.3) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onTapGesture { emoji = e }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                Section("Dates") {
                    DatePicker("Departure", selection: $startDate, displayedComponents: .date)
                    DatePicker("Return",    selection: $endDate, in: startDate..., displayedComponents: .date)
                }
                Section("Budget") {
                    Picker("Currency", selection: $currency) {
                        ForEach(currencies, id: \.self) { Text($0).tag($0) }
                    }
                    HStack {
                        Text(currency).foregroundStyle(.secondary)
                        TextField("Optional budget amount", text: $budget).keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { save() }
                        .fontWeight(.semibold)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        var trip = Trip(name: name.trimmingCharacters(in: .whitespaces),
                        startDate: startDate, endDate: endDate,
                        currency: currency, coverEmoji: emoji)
        trip.budget = Double(budget)
        store.addTrip(trip)
        dismiss()
    }
}
