import SwiftUI

struct BudgetTabView: View {
    let tripID: UUID
    @EnvironmentObject var store: TripStore

    var body: some View {
        guard let trip = store.trip(id: tripID) else { return AnyView(EmptyView()) }
        return AnyView(
            List {
                Section {
                    spendHeader(trip: trip)
                }
                if trip.receipts.isEmpty {
                    Section {
                        VStack(spacing: 10) {
                            Image(systemName: "receipt").font(.system(size: 36)).foregroundStyle(.secondary)
                            Text("No receipts yet").foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity).padding()
                        .listRowBackground(Color.clear)
                    }
                } else {
                    Section("Receipts") {
                        ForEach(trip.receipts.sorted { $0.date > $1.date }) { receipt in
                            HStack(spacing: 12) {
                                Image(systemName: receipt.category.icon)
                                    .foregroundStyle(receipt.category.color)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(receipt.merchant).font(.subheadline)
                                    Text(receipt.category.rawValue).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(trip.currency) \(String(format: "%.2f", receipt.amount))")
                                    .fontWeight(.medium).monospacedDigit()
                            }
                        }
                        .onDelete { offsets in
                            let sorted = trip.receipts.sorted { $0.date > $1.date }
                            offsets.forEach { store.deleteReceipt(id: sorted[$0].id, from: tripID) }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        )
    }

    private func spendHeader(trip: Trip) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Spent").font(.caption).foregroundStyle(.secondary)
                    Text("\(trip.currency) \(String(format: "%.0f", trip.totalSpent))")
                        .font(.title2).fontWeight(.bold)
                }
                Spacer()
                if let budget = trip.budget, budget > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Budget").font(.caption).foregroundStyle(.secondary)
                        Text("\(trip.currency) \(String(format: "%.0f", budget))")
                            .font(.title2).fontWeight(.bold).foregroundStyle(.secondary)
                    }
                }
            }
            if let budget = trip.budget, budget > 0 {
                ProgressView(value: min(trip.totalSpent / budget, 1))
                    .tint(trip.totalSpent > budget ? .red : .waypointAmber)
            }
        }
        .padding(.vertical, 4)
    }
}
