import Foundation

enum SampleData {
    static func sampleTrips() -> [Trip] { [spainTrip()] }

    // MARK: - Spain May 2026

    static func spainTrip() -> Trip {
        var trip = Trip(
            name: "Spain · May 2026",
            startDate: date(2026, 5, 6),
            endDate: date(2026, 5, 22),
            currency: "CAD",
            budget: 5000,
            coverEmoji: "🇪🇸"
        )
        trip.cities = [
            City(name: "Tarifa",    country: "Spain",   latitude: 36.0143, longitude: -5.6044,
                 arrivalDate: date(2026, 5, 7),  departureDate: date(2026, 5, 11)),
            City(name: "Granada",   country: "Spain",   latitude: 37.1773, longitude: -3.5986,
                 arrivalDate: date(2026, 5, 11), departureDate: date(2026, 5, 12)),
            City(name: "Córdoba",   country: "Spain",   latitude: 37.8882, longitude: -4.7794,
                 arrivalDate: date(2026, 5, 12), departureDate: date(2026, 5, 14)),
            City(name: "Valencia",  country: "Spain",   latitude: 39.4699, longitude: -0.3763,
                 arrivalDate: date(2026, 5, 14), departureDate: date(2026, 5, 15)),
            City(name: "Barcelona", country: "Spain",   latitude: 41.3851, longitude: 2.1734,
                 arrivalDate: date(2026, 5, 15), departureDate: date(2026, 5, 21)),
            City(name: "Brussels",  country: "Belgium", latitude: 50.8503, longitude: 4.3517,
                 arrivalDate: date(2026, 5, 21), departureDate: date(2026, 5, 22)),
        ]
        trip.events = sampleEvents()
        return trip
    }

    // MARK: - Events

    private static func sampleEvents() -> [TripEvent] {
        [
            // ── Outbound flight ───────────────────────────────────
            makeEvent(
                type: .flight, title: "Montreal → Paris (French Bee BF761)",
                start: dt(2026, 5, 6, 23, 0), end: dt(2026, 5, 7, 12, 0),
                loc: "Montréal-Trudeau Airport (YUL)", lat: 45.4706, lng: -73.7408,
                conf: "GFMIOP",
                warnings: ["Stay airside at ORY — do not go to the city (not enough time)"],
                payload: .flight(FlightPayload(airline: "French Bee", flightNumber: "BF761",
                                               origin: "YUL", destination: "ORY",
                                               cabinClass: "Economy", pnr: "GFMIOP"))
            ),
            makeEvent(
                type: .flight, title: "Paris → Seville (Transavia TO4608)",
                start: dt(2026, 5, 7, 17, 10), end: dt(2026, 5, 7, 19, 35),
                loc: "Paris Orly Airport (ORY)", lat: 48.7233, lng: 2.3795,
                conf: "BGJKRN",
                payload: .flight(FlightPayload(airline: "Transavia", flightNumber: "TO4608",
                                               origin: "ORY", destination: "SVQ",
                                               cabinClass: "Economy", pnr: "BGJKRN"))
            ),
            // ── Hostel ────────────────────────────────────────────
            makeEvent(
                type: .hostel, title: "Hostal Africa — Tarifa Retreat",
                start: dt(2026, 5, 7, 23, 0), end: dt(2026, 5, 11, 12, 0),
                loc: "C. María Antonia Toledo 12, Tarifa", lat: 36.0143, lng: -5.6044,
                payload: .accommodation(AccommodationPayload(checkInTime: "23:00", checkOutTime: "12:00",
                                                              address: "C. María Antonia Toledo 12, 11380 Tarifa"))
            ),
            // ── Tarifa → Granada travel day ───────────────────────
            makeEvent(
                type: .bus, title: "Tarifa → Algeciras (COMES)",
                start: dt(2026, 5, 11, 12, 40), end: dt(2026, 5, 11, 13, 10),
                loc: "Tarifa Bus Station", lat: 36.0143, lng: -5.6044,
                warnings: ["Buy ticket IN PERSON at Tarifa station — no online booking"],
                payload: .bus(BusPayload(company: "Transportes Comes", origin: "Tarifa",
                                         destination: "Algeciras", inPersonPurchase: true))
            ),
            makeEvent(
                type: .bus, title: "Algeciras → Málaga (Avanza)",
                start: dt(2026, 5, 11, 13, 45), end: dt(2026, 5, 11, 15, 45),
                loc: "Algeciras Bus Station", lat: 36.1300, lng: -5.4540,
                payload: .bus(BusPayload(company: "Avanza", origin: "Algeciras", destination: "Málaga"))
            ),
            makeEvent(
                type: .train, title: "Málaga → Granada (Renfe Avant)",
                start: dt(2026, 5, 11, 16, 34), end: dt(2026, 5, 11, 17, 57),
                loc: "Málaga María Zambrano", lat: 36.7142, lng: -4.4289,
                conf: "1gqume3",
                warnings: ["Málaga bus station and train station are the SAME building (Vialia) — walk through"],
                payload: .train(TrainPayload(operatorName: "Renfe", trainNumber: "AVANT 08835",
                                              origin: "Málaga", destination: "Granada",
                                              carriage: "2", seat: "03D"))
            ),
            // ── Granada ───────────────────────────────────────────
            makeEvent(
                type: .hotel, title: "Eurostars Gran Vía",
                start: dt(2026, 5, 11, 15, 0), end: dt(2026, 5, 12, 11, 0),
                loc: "Gran Via De Colón 20, Granada", lat: 37.1762, lng: -3.5980,
                conf: "121232",
                payload: .accommodation(AccommodationPayload(checkInTime: "15:00", checkOutTime: "11:00",
                                                              address: "Gran Via De Colón 20, 18010 Granada"))
            ),
            makeEvent(
                type: .show, title: "Flamenco — Cueva de la Rocío",
                start: dt(2026, 5, 11, 22, 0), end: dt(2026, 5, 11, 23, 0),
                loc: "Sacromonte, Granada", lat: 37.1796, lng: -3.5852,
                conf: "TAKZ-110526",
                warnings: ["No vehicles on Sacromonte path — taxi to foot of hill and walk up"],
                payload: .attraction(AttractionPayload(venue: "Cueva de la Rocío", price: 28))
            ),
            makeEvent(
                type: .guidedTour, title: "Alhambra + Nasrid Palaces",
                start: dt(2026, 5, 12, 9, 30), end: dt(2026, 5, 12, 12, 30),
                loc: "P.º del Generalife 1F, Granada", lat: 37.1760, lng: -3.5881,
                conf: "GYGRFQQYM9MY",
                warnings: [
                    "Arrive 09:15 — meet guide at 'Guides' sign near ticket offices",
                    "Bring original passport or ID",
                    "No selfie sticks in Nasrid Palaces",
                    "Backpack worn on front inside Nasrid Palaces"
                ],
                attachments: [
                    Attachment(kind: .ticket,
                               displayName: "GetYourGuide Voucher",
                               filename: "alhambra-voucher.pdf",
                               mimeType: "application/pdf",
                               qrCodeContent: "GYGRFQQYM9MY",
                               bundledResourceName: "alhambra-voucher",
                               parsedFields: ["Booking Ref": "GYGRFQQYM9MY", "PIN": "EjXLM3IR",
                                              "Provider": "Alhambra Guide / Granada Premium Tours",
                                              "Phone": "+34 644 927 756"])
                ],
                payload: .attraction(AttractionPayload(venue: "Alhambra",
                                                        meetingPoint: "P.º del Generalife — 'Guides' sign",
                                                        provider: "Alhambra Guide / Granada Premium Tours",
                                                        providerPhone: "+34 644 927 756",
                                                        pin: "EjXLM3IR",
                                                        durationMinutes: 180, price: 301.65, priceCurrency: "CAD"))
            ),
            // ── Córdoba ───────────────────────────────────────────
            makeEvent(
                type: .train, title: "Granada → Córdoba (AVE)",
                start: dt(2026, 5, 12, 18, 0), end: dt(2026, 5, 12, 19, 56),
                loc: "Granada Railway Station", lat: 37.1839, lng: -3.6107,
                payload: .train(TrainPayload(operatorName: "Renfe AVE", trainNumber: "02197",
                                              origin: "Granada", destination: "Córdoba"))
            ),
            makeEvent(
                type: .hotel, title: "Hotel Mezquita Center",
                start: dt(2026, 5, 12, 20, 30), end: dt(2026, 5, 14, 11, 0),
                loc: "Calle Bulevar Hernán Ruiz 4, Córdoba", lat: 37.8795, lng: -4.7774,
                conf: "EXP-2445196801",
                payload: .accommodation(AccommodationPayload(checkInTime: "20:30", checkOutTime: "11:00",
                                                              address: "Calle Bulevar Hernán Ruiz 4, 14005 Córdoba"))
            ),
            makeEvent(
                type: .guidedTour, title: "Mosque of Córdoba + Medina Azahara",
                start: dt(2026, 5, 13, 10, 45), end: dt(2026, 5, 13, 18, 0),
                loc: "Paseo de la Victoria, Córdoba", lat: 37.8834, lng: -4.7811,
                conf: "401780371644",
                warnings: [
                    "Arrive at Paseo de la Victoria bus stop by 10:30",
                    "€1.50 Medina Azahara entry payable in cash on arrival (non-EU)",
                    "Bring passport"
                ],
                payload: .attraction(AttractionPayload(venue: "Mezquita + Medina Azahara",
                                                        provider: "Al-Ándalus Tours",
                                                        providerPhone: "+34 663 04 58 37",
                                                        durationMinutes: 435, price: 64))
            ),
            // ── Barcelona ─────────────────────────────────────────
            makeEvent(
                type: .train, title: "Valencia → Barcelona (Renfe)",
                start: dt(2026, 5, 15, 15, 36), end: dt(2026, 5, 15, 19, 0),
                loc: "Valencia Estació del Nord", lat: 39.4654, lng: -0.3774,
                payload: .train(TrainPayload(operatorName: "Renfe", trainNumber: "01162",
                                              origin: "Valencia", destination: "Barcelona Sants"))
            ),
            makeEvent(
                type: .airbnb, title: "Central Apartments",
                start: dt(2026, 5, 15, 20, 0), end: dt(2026, 5, 18, 11, 0),
                loc: "Carrer de Bailèn 125, Eixample Dret, Barcelona", lat: 41.3986, lng: 2.1780,
                conf: "HMJTSDBDKB",
                payload: .accommodation(AccommodationPayload(checkInTime: "20:00", checkOutTime: "11:00",
                                                              address: "Carrer de Bailèn, 125, Eixample Dret"))
            ),
            makeEvent(
                type: .attraction, title: "Park Güell + Gaudí House Museum",
                start: dt(2026, 5, 17, 11, 30), end: dt(2026, 5, 17, 13, 30),
                loc: "Carrer del Carmel 23, Barcelona", lat: 41.4145, lng: 2.1527,
                conf: "700433231665",
                warnings: [
                    "Go to Gaudí House Museum FIRST — reservation held only 30 min",
                    "Arrive before 12:00 or entry not guaranteed",
                    "No re-entry once ticket validated"
                ],
                payload: .attraction(AttractionPayload(venue: "Park Güell", durationMinutes: 120, price: 24))
            ),
            makeEvent(
                type: .show, title: "FC Barcelona vs Real Betis",
                start: dt(2026, 5, 17, 17, 0), end: dt(2026, 5, 17, 19, 0),
                loc: "Spotify Camp Nou, Barcelona", lat: 41.3809, lng: 2.1228,
                conf: "DNI f97845467",
                warnings: [
                    "Metro L5 toward Collblanc → walk to Camp Nou",
                    "Rain jacket — no roof, cools fast after sunset",
                    "Spectator: ALIREZA TOGHIANI KHORASGANI · DNI f97845467"
                ]
            ),
            makeEvent(
                type: .attraction, title: "Casa Batlló — Morning Visit",
                start: dt(2026, 5, 18, 8, 30), end: dt(2026, 5, 18, 10, 0),
                loc: "Passeig de Gràcia 43, Barcelona", lat: 41.3917, lng: 2.1649,
                conf: "loc.293126002",
                warnings: ["Bring student ID for discount"],
                payload: .attraction(AttractionPayload(venue: "Casa Batlló", durationMinutes: 75, price: 39))
            ),
            makeEvent(
                type: .attraction, title: "Sagrada Família",
                start: dt(2026, 5, 18, 13, 15), end: dt(2026, 5, 18, 15, 30),
                loc: "Carrer de Mallorca 401, Barcelona", lat: 41.4036, lng: 2.1744,
                conf: "98217880",
                warnings: [
                    "Dress code: shoulders and knees covered",
                    "Nativity Tower timed slot at 13:45",
                    "Audioguide included"
                ],
                payload: .attraction(AttractionPayload(venue: "Sagrada Família", durationMinutes: 135, price: 34))
            ),
            makeEvent(
                type: .hotel, title: "Radisson Blu 1882",
                start: dt(2026, 5, 18, 15, 0), end: dt(2026, 5, 21, 11, 0),
                loc: "Carrer de Còrsega 482, Barcelona", lat: 41.4027, lng: 2.1705,
                conf: "0164264186",
                payload: .accommodation(AccommodationPayload(checkInTime: "15:00", checkOutTime: "11:00",
                                                              address: "Carrer de Còrsega 482, 08025 Barcelona"))
            ),
            makeEvent(
                type: .guidedTour, title: "Picasso Museum — Guided Tour",
                start: dt(2026, 5, 19, 16, 0), end: dt(2026, 5, 19, 17, 30),
                loc: "C/ Montcada 17, El Born, Barcelona", lat: 41.3851, lng: 2.1805,
                conf: "5/1550054",
                warnings: [
                    "Delay of more than 15 minutes = ticket cancelled",
                    "Meeting point: 17 Montcada st. (main entrance)"
                ],
                payload: .attraction(AttractionPayload(venue: "Museu Picasso",
                                                        meetingPoint: "C/ Montcada 15-23",
                                                        durationMinutes: 90, price: 18))
            ),
            // ── Return flight ─────────────────────────────────────
            makeEvent(
                type: .flight, title: "Barcelona → Brussels → Montreal",
                start: dt(2026, 5, 21, 21, 20), end: dt(2026, 5, 22, 11, 15),
                loc: "Barcelona–El Prat Airport (BCN)", lat: 41.2974, lng: 2.0833,
                conf: "757995271",
                warnings: ["Brussels overnight — lambic at Delirium, Grand Place at 4am"],
                payload: .flight(FlightPayload(airline: "Brussels Airlines / Air Transat",
                                               flightNumber: "SN 3706 / TS 155",
                                               origin: "BCN", destination: "YUL", cabinClass: "Economy"))
            ),
        ]
    }

    // MARK: - Helpers

    private static func makeEvent(
        type: EventType, title: String,
        start: Date, end: Date? = nil,
        loc: String? = nil, lat: Double? = nil, lng: Double? = nil,
        conf: String? = nil,
        warnings: [String] = [],
        attachments: [Attachment] = [],
        payload: EventPayload = .none
    ) -> TripEvent {
        var e = TripEvent(type: type, title: title, startTime: start)
        e.endTime = end
        e.locationName = loc
        e.latitude = lat
        e.longitude = lng
        e.confirmationNumber = conf
        e.warningNotes = warnings
        e.attachments = attachments
        e.payload = payload
        return e
    }

    private static func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: y, month: m, day: d))!
    }

    private static func dt(_ y: Int, _ m: Int, _ d: Int, _ h: Int, _ min: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: y, month: m, day: d, hour: h, minute: min))!
    }
}
