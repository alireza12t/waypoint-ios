import SwiftUI

struct AddEventView: View {
    let tripID: UUID
    @EnvironmentObject var store: TripStore
    @Environment(\.dismiss) var dismiss

    @State private var step: Step = .pickType
    @State private var selectedType: EventType?
    @State private var showScanner = false

    // Form fields
    @State private var title              = ""
    @State private var startTime          = Date()
    @State private var endTime            = Date()
    @State private var hasEndTime         = false
    @State private var departureLocation: PickedLocation? = nil
    @State private var arrivalLocation:   PickedLocation? = nil
    @State private var confirmRef         = ""
    @State private var notes              = ""

    enum Step { case pickType, pickSource, fillForm }

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .pickType:   typePicker
                case .pickSource: sourcePicker
                case .fillForm:   form
                }
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                if step == .fillForm {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") { save() }
                            .fontWeight(.semibold)
                            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            QRScanView { scanned in
                confirmRef = scanned
                step = .fillForm
            }
        }
    }

    private var stepTitle: String {
        switch step {
        case .pickType:   return "What to add?"
        case .pickSource: return "How to add?"
        case .fillForm:   return selectedType?.displayName ?? "New Event"
        }
    }

    // MARK: - Type Picker Grid

    private var typePicker: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 95))], spacing: 12) {
                ForEach(EventType.allCases, id: \.self) { type in
                    Button {
                        selectedType = type
                        title = type.displayName
                        step = .pickSource
                    } label: {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle().fill(type.color.opacity(0.18)).frame(width: 50, height: 50)
                                Image(systemName: type.icon).font(.title2).foregroundStyle(type.color)
                            }
                            Text(type.displayName).font(.caption).fontWeight(.medium).lineLimit(1)
                        }
                        .padding(10).frame(maxWidth: .infinity)
                        .background(Color.waypointCard)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    // MARK: - Source Picker

    private var sourcePicker: some View {
        List {
            Button {
                showScanner = true
            } label: {
                Label("Scan QR Code / Barcode", systemImage: "qrcode.viewfinder")
                    .foregroundStyle(.primary)
            }
            Button {
                step = .fillForm
            } label: {
                Label("Enter Manually", systemImage: "keyboard")
                    .foregroundStyle(.primary)
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Manual Form

    private var form: some View {
        Form {
            Section("Event") {
                TextField("Title", text: $title)
                DatePicker("Start", selection: $startTime)
                Toggle("End time", isOn: $hasEndTime.animation())
                if hasEndTime {
                    DatePicker("End", selection: $endTime, in: startTime...)
                }
            }
            if selectedType?.isTransport == true {
                Section("Departure") {
                    LocationSearchField(placeholder: "Station / airport / stop",
                                        picked: $departureLocation)
                }
                Section("Arrival") {
                    LocationSearchField(placeholder: "Station / airport / stop",
                                        picked: $arrivalLocation)
                }
            } else {
                Section("Location") {
                    LocationSearchField(placeholder: "Place name (optional)",
                                        picked: $departureLocation)
                }
            }
            Section("Reference") {
                HStack {
                    TextField("Booking / confirmation number", text: $confirmRef)
                    if !confirmRef.isEmpty {
                        Button {
                            showScanner = true
                        } label: {
                            Image(systemName: "qrcode.viewfinder").foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Section("Notes") {
                TextField("Add notes...", text: $notes, axis: .vertical)
                    .lineLimit(3...)
            }
        }
    }

    // MARK: - Save

    private func save() {
        guard let type = selectedType else { return }
        var event = TripEvent(type: type, title: title.trimmingCharacters(in: .whitespaces), startTime: startTime)
        event.endTime             = hasEndTime ? endTime : nil
        event.locationName        = departureLocation?.name
        event.latitude            = departureLocation?.latitude
        event.longitude           = departureLocation?.longitude
        event.arrivalLocationName = arrivalLocation?.name
        event.arrivalLatitude     = arrivalLocation?.latitude
        event.arrivalLongitude    = arrivalLocation?.longitude
        event.confirmationNumber  = confirmRef.isEmpty ? nil : confirmRef
        event.notes               = notes
        store.addEvent(event, to: tripID)
        dismiss()
    }
}
