import SwiftUI
import MapKit

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
    @FocusState private var focused: Bool

    var isConfirmed: Bool { picked != nil && query == picked?.name }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField(placeholder, text: $query)
                    .autocorrectionDisabled()
                    .focused($focused)
                    .onChange(of: query) { newValue in
                        // Only search when the user is actively typing (not after a pick)
                        if !isConfirmed { search(newValue) }
                    }
                if isConfirmed {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                } else if !query.isEmpty {
                    Button {
                        query = ""; picked = nil; results = []; showResults = false
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                }
            }

            if showResults && !results.isEmpty {
                Divider().padding(.top, 4)
                ForEach(results, id: \.self) { item in
                    Button { pick(item) } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "mappin").foregroundStyle(.red).frame(width: 20)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.name ?? "Unknown")
                                    .font(.subheadline).foregroundStyle(.primary)
                                Text([item.placemark.locality, item.placemark.country]
                                        .compactMap { $0 }.joined(separator: ", "))
                                    .font(.caption).foregroundStyle(.secondary)
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
        let name  = item.name ?? item.placemark.title ?? query
        picked = PickedLocation(name: name, latitude: coord.latitude, longitude: coord.longitude)
        query       = name
        results     = []
        showResults = false
        focused     = false   // dismiss keyboard
    }

    private func search(_ text: String) {
        guard text.count >= 2 else { results = []; showResults = false; return }
        showResults = true
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = text
        Task {
            let items = (try? await MKLocalSearch(request: req).start().mapItems) ?? []
            await MainActor.run { results = Array(items.prefix(5)) }
        }
    }
}
