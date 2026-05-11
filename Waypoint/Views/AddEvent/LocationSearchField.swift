import SwiftUI
import MapKit

// Binding-friendly result
struct PickedLocation: Equatable {
    var name: String
    var latitude: Double
    var longitude: Double
}

struct LocationSearchField: View {
    let placeholder: String
    @Binding var picked: PickedLocation?

    @State private var query = ""
    @State private var results: [MKMapItem] = []
    @State private var showResults = false
    @State private var searching = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField(placeholder, text: $query)
                    .autocorrectionDisabled()
                    .onChange(of: query) { _ in search() }
                if let p = picked, query == p.name {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                } else if !query.isEmpty {
                    Button { query = ""; picked = nil; results = [] } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                }
            }

            if showResults && !results.isEmpty {
                Divider().padding(.top, 4)
                ForEach(results, id: \.self) { item in
                    Button {
                        pick(item)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "mappin").foregroundStyle(.red).frame(width: 20)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.name ?? "Unknown").font(.subheadline).foregroundStyle(.primary)
                                if let addr = item.placemark.thoroughfare {
                                    Text(addr).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    Divider()
                }
            }
        }
        .onAppear {
            if let p = picked { query = p.name }
        }
    }

    private func pick(_ item: MKMapItem) {
        let coord = item.placemark.coordinate
        let name  = item.name ?? item.placemark.name ?? query
        picked = PickedLocation(name: name, latitude: coord.latitude, longitude: coord.longitude)
        query  = name
        results = []
        showResults = false
    }

    private func search() {
        guard query.count >= 2 else { results = []; showResults = false; return }
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = query
        showResults = true
        Task {
            let items = (try? await MKLocalSearch(request: req).start().mapItems) ?? []
            await MainActor.run {
                results = Array(items.prefix(5))
            }
        }
    }
}
