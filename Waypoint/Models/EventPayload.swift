import Foundation

struct FlightPayload: Codable {
    var airline: String = ""
    var flightNumber: String = ""
    var origin: String = ""
    var destination: String = ""
    var seatNumber: String = ""
    var cabinClass: String = ""
    var pnr: String = ""
    var terminal: String = ""
    var gate: String = ""
}

struct TrainPayload: Codable {
    var operatorName: String = ""
    var trainNumber: String = ""
    var origin: String = ""
    var destination: String = ""
    var carriage: String = ""
    var seat: String = ""
}

struct BusPayload: Codable {
    var company: String = ""
    var origin: String = ""
    var destination: String = ""
    var seat: String = ""
    var inPersonPurchase: Bool = false
}

struct AccommodationPayload: Codable {
    var checkInTime: String = "15:00"
    var checkOutTime: String = "11:00"
    var address: String = ""
    var phone: String = ""
    var wifiName: String = ""
    var wifiPassword: String = ""
    var lockCode: String = ""
    var breakfastIncluded: Bool = false
}

struct AttractionPayload: Codable {
    var venue: String = ""
    var meetingPoint: String = ""
    var provider: String = ""
    var providerPhone: String = ""
    var pin: String = ""
    var durationMinutes: Int = 60
    var price: Double = 0
    var priceCurrency: String = "EUR"
}

enum EventPayload: Codable {
    case flight(FlightPayload)
    case train(TrainPayload)
    case bus(BusPayload)
    case accommodation(AccommodationPayload)
    case attraction(AttractionPayload)
    case none

    private enum CodingKeys: String, CodingKey { case type, data }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .flight(let p):      try c.encode("flight", forKey: .type);        try c.encode(p, forKey: .data)
        case .train(let p):       try c.encode("train", forKey: .type);         try c.encode(p, forKey: .data)
        case .bus(let p):         try c.encode("bus", forKey: .type);           try c.encode(p, forKey: .data)
        case .accommodation(let p): try c.encode("accommodation", forKey: .type); try c.encode(p, forKey: .data)
        case .attraction(let p):  try c.encode("attraction", forKey: .type);    try c.encode(p, forKey: .data)
        case .none:               try c.encode("none", forKey: .type)
        }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(String.self, forKey: .type) {
        case "flight":        self = .flight(try c.decode(FlightPayload.self, forKey: .data))
        case "train":         self = .train(try c.decode(TrainPayload.self, forKey: .data))
        case "bus":           self = .bus(try c.decode(BusPayload.self, forKey: .data))
        case "accommodation": self = .accommodation(try c.decode(AccommodationPayload.self, forKey: .data))
        case "attraction":    self = .attraction(try c.decode(AttractionPayload.self, forKey: .data))
        default:              self = .none
        }
    }
}
