# Waypoint — Travel Companion App
## Full Product Specification

> **Grounded in a real trip:** Spain, 16 days, 6 cities, 20+ bookings — flights, trains, buses, hotels, Airbnbs, hostels, guided tours, museum tickets, a football match, a flamenco show, and a Brussels layover adventure. Every feature below is shaped by what that trip actually needed.

---

## 1. Product Vision

Waypoint is a travel companion that lives in your pocket during a trip. It is not a booking platform. It is the single place where everything about your trip — once booked, bought, or confirmed — is organized, accessible offline, and presented in a way that requires almost no reading or typing. You open it, you see what's next, you tap, you go.

**Core principles:**
- **Less typing, more choosing.** Maps, dropdowns, pickers, scan — not forms.
- **Offline-first.** Tickets, maps, and itineraries work without a signal.
- **iCloud-optional.** Local by default; iCloud sync enabled in Settings for backup and multi-device access.
- **iPhone 14 as the baseline.** Newer hardware and OS versions unlock richer features but the core experience works for everyone.

---

## 2. Platform Targets

### Minimum supported device
iPhone 14 — iOS 16.0

### Feature tiers by iOS version

| Feature | iOS 16 | iOS 17 | iOS 18 |
|---|---|---|---|
| Full core app | ✅ | ✅ | ✅ |
| Lock Screen widgets (next event) | ✅ | ✅ | ✅ |
| Interactive widgets (mark arrived) | ❌ | ✅ | ✅ |
| Live Activities (flight/train countdown) | ❌ | ✅ | ✅ |
| Offline vector maps (MapKit) | ❌ | ✅ | ✅ |
| Smart document parsing (VisionKit OCR) | ✅ basic | ✅ full | ✅ full |
| Apple Intelligence auto-import from email | ❌ | ❌ | ✅ |
| Journal app integration | ❌ | ✅ | ✅ |
| Dynamic Island trip pulse | ❌ | ✅ | ✅ |

### Feature tiers by iPhone model

| Feature | iPhone 14 | iPhone 15 | iPhone 15 Pro / 16 | iPhone 16 Pro |
|---|---|---|---|---|
| QR scan (camera) | ✅ | ✅ | ✅ | ✅ |
| Document scan (rear cam) | ✅ | ✅ | ✅ | ✅ |
| ProRAW receipt photos | ❌ | ❌ | ✅ | ✅ |
| Action Button → quick scan | ❌ | ❌ | ✅ | ✅ |
| Camera Control → scan | ❌ | ❌ | ❌ | ✅ |

---

## 3. Storage & Sync

### Default: Local
All data lives in the app's sandboxed local storage (Core Data). No account required. Works on a plane.

### iCloud sync (opt-in)
Enabled via **Settings → Storage → Enable iCloud Sync**. Uses CloudKit private database — only the user's own iCloud account. Syncs: trips, events, documents, tickets, receipts. No third-party server ever holds user data.

### Offline behavior
- All ticket PDFs and images are cached on device at import.
- Map tiles for each trip city are downloaded when the city is added (on Wi-Fi by default, configurable).
- Offline map tile storage estimated at ~60–120 MB per city for street + transit detail.
- If offline: QR display, ticket display, day timeline, map (cached tiles) all work. Live Activities update stops until signal returns.

---

## 4. App Structure — Screen Map

```
Waypoint
├── Trips (root)
│   ├── Trip Card (thumbnail, dates, cities, progress)
│   └── + New Trip
│
├── Trip Hub (per trip)
│   ├── [Tab] Timeline — scrollable day-by-day view
│   ├── [Tab] Map — city map with all pins
│   ├── [Tab] Wallet — all tickets & passes
│   ├── [Tab] Docs — hotels, insurance, contracts
│   └── [Tab] Budget — receipts + spend tracker
│
├── Day View (per day, opened from Timeline)
│   ├── Event list (chronological)
│   ├── Mini-map (pinned places that day)
│   └── + Add Event
│
├── Event Detail (per event)
│   ├── Type-specific layout (see §8)
│   ├── Attached ticket / QR code
│   ├── Notes
│   ├── Map pin (tap → full map)
│   └── Add to Calendar
│
├── Wallet (flat view of all tickets across trip)
│   ├── Grouped: Today · Upcoming · Past
│   └── Ticket Detail → QR full-screen
│
├── Add Flow (modal, bottom sheet)
│   ├── Scan QR / barcode
│   ├── Scan document (PDF / photo)
│   ├── Search & pick (map-first)
│   └── Manual (type-minimal)
│
├── City Map (full-screen)
│   ├── Pins by category filter
│   ├── Tap pin → event mini-card
│   └── Directions → Apple Maps handoff
│
└── Settings
    ├── Storage (iCloud on/off, offline maps)
    ├── Notifications
    ├── Default currency
    ├── Calendar (linked Apple Calendar)
    └── About
```

---

## 5. Screen Specifications

### 5.1 Trips Dashboard (Root)

**What it shows:**
- Large cards, one per trip
- Card: cover photo (auto-suggested from first city, user can swap), trip name, date range, city count, days until departure (or "In progress" or "X days ago")
- Bottom bar: upcoming event chip for any active trip ("In 2h: Sagrada Família tour")

**Interactions:**
- Tap card → Trip Hub
- Long press card → Rename / Duplicate / Archive / Delete
- Pull down on list → Search trips
- "+" FAB → New Trip wizard

**New Trip wizard (3 taps to create):**
1. **Name** — text field, pre-suggested "May 2026" or "Spain Trip"
2. **Destination(s)** — map search with autocomplete; tap city pins; multi-city support; reorder cities
3. **Dates** — date range picker (calendar scroll, no typing)
4. **Cover** — auto-suggested hero photos from city (Unsplash API); user can pick or take photo

---

### 5.2 Trip Hub

Five bottom tabs. The default landing tab depends on trip state:
- Before trip: **Timeline** (planning mode)
- During trip: **Timeline** scrolled to today
- After trip: **Budget**

**Trip status bar (top, always visible):**
- Progress pill: "Day 7 of 16 · Barcelona"
- Weather chip (current city, from WeatherKit)
- SOS chip → Insurance doc + emergency contact (one tap)

---

### 5.3 Timeline Tab

Scrollable vertical list of days, each day is a collapsible section.

**Day section header:**
- Date (Mon May 18)
- City name + flag emoji
- Weather: 21°C ☀️
- Expand/collapse chevron

**Events within a day:**
- Ordered by time
- Each event: left-side time column | right-side card
- Card: type icon (colored), title, duration or "→ destination", status badge (booked ✅ / tentative ⚠️ / confirm on arrival 🕐)
- Swipe left: Edit | Delete
- Swipe right: Mark done (greens it out)
- Tap: Event Detail

**Day section footer:**
- Total km/transit time for travel-heavy days
- "+ Add to this day" button

**Timeline behavior:**
- Today's day is auto-expanded and scrolled to
- Past days are collapsed with a "Show past days" toggle
- Days without events show a "Free day" placeholder with a "+" to plan it

---

### 5.4 Map Tab

Full-screen MapKit map centered on the current city (or first city if pre-trip).

**Top controls:**
- City switcher — horizontal pill scroll (Tarifa · Granada · Córdoba · Valencia · Barcelona)
- Day filter — "All days" default; picker to filter to a single day

**Pin categories (filter chips below city switcher):**
- ✈️ Flights · 🚄 Trains · 🚌 Buses · 🏨 Hotels · 🎟 Attractions · 🍽 Restaurants · 🎭 Nightlife · 🛒 Shopping

**Pin behavior:**
- Tap pin → bottom sheet slides up: event name, time, distance from current location, "Open in Maps" button, "View Event" button
- Pins color-coded by category
- Active day's pins are full-color; other days dimmed
- Route line drawn between consecutive events on active day (optional toggle)

**Offline maps:**
- iOS 17+: MapKit offline region downloaded per city on trip creation (Wi-Fi only unless user overrides)
- iOS 16: falls back to cached tiles from last online session

---

### 5.5 Wallet Tab

All tickets and boarding passes in one swipeable gallery.

**Sections:**
- **Today** — events happening today (highlighted, large card)
- **Upcoming** — sorted by date
- **Past** — collapsed, expandable

**Ticket card:**
- Full-width card with color derived from ticket type
- Flight: airline logo, route (YUL → ORY), departure time, seat, PNR
- Train: operator logo, route (Granada → Córdoba), carriage/seat, booking ref
- Attraction: venue name, entry time, confirmation number
- Hotel: property name, check-in / check-out, confirmation number
- Generic: document thumbnail + title

**Tap ticket:**
- Full-screen ticket view
- QR code / barcode centered, full-brightness screen, auto-lock disabled
- Swipe up: raw ticket details (parsed fields)
- Bottom: "Share" (AirDrop / Messages) | "Open PDF" | "Add to Apple Wallet" (if PKPass compatible)

**Add to Wallet:**
- Scan QR — camera opens, auto-detect, parse, categorize
- Import file — Files app picker (PDF, PNG, JPG)
- From email — iOS 18: Siri Suggestions surface booking emails; iOS 16/17: share extension from Mail

---

### 5.6 Docs Tab

Document vault for everything that is not a ticket.

**Categories (horizontal tabs):**
- 🏨 Accommodations — hotel confirmations, Airbnb contracts, check-in instructions
- ✈️ Flights — full itinerary PDFs
- 🛡 Insurance — policy documents
- 🚌 Transport — bus/train passes, car rental agreements
- 📋 Other — visa letters, retreat info, apartment registration

**Document card:**
- Thumbnail preview
- Title (auto-extracted or user-set)
- Date added
- Quick-view: tap → full-screen PDF/image viewer with pinch-zoom

**Add document:**
- Scan with camera → VisionKit → auto-classify
- Import from Files, iCloud Drive, or share extension from other apps

---

### 5.7 Budget Tab

**Summary header:**
- Total spent vs. estimated budget (if set)
- Pie chart by category: Food · Transport · Accommodation · Activities · Other
- Currency selector — shows foreign + home currency; live exchange rate (online) or cached rate (offline)

**Receipt list:**
- Grouped by day
- Each receipt: thumbnail, merchant name (OCR-extracted), amount, category (auto-tagged, editable), city

**Add receipt:**
- Camera → auto-capture → OCR extracts merchant + amount + date
- User confirms or corrects — all pickers, no typing where possible
- Category: pick from icons
- Currency: pick from list filtered to trip countries

**Export:**
- CSV or PDF summary
- Shared via share sheet

---

### 5.8 Event Detail — Type Layouts

Each event type has a tailored layout. All share a common shell: title, time, date, location pin, notes, attachments.

#### Flight
```
┌─────────────────────────────────────┐
│  ✈️  BF761  French Bee              │
│  YUL ──────────────────── ORY       │
│  23:00  Wed May 6      12:00  Thu   │
│  Economy · Ref: GFMIOP              │
│  ─────────────────────────────────  │
│  🪑 Seat not assigned               │
│  🧳 Carry-on only                   │
│  ⚠️ Self-transfer at ORY — airside  │
│  ─────────────────────────────────  │
│  [Boarding Pass QR]  [Add Calendar] │
└─────────────────────────────────────┘
```

#### Train
```
┌─────────────────────────────────────┐
│  🚄  Renfe AVANT 08835              │
│  Málaga ──────────────── Granada    │
│  16:34  →  17:57  ·  1h 23m        │
│  Carriage 2 · Seat 03D              │
│  Booking: 1gqume3                   │
│  ─────────────────────────────────  │
│  📍 Departs: Málaga María Zambrano  │
│  📍 Same building as bus station    │
│  ─────────────────────────────────  │
│  [Ticket QR]  [Map]  [Add Calendar] │
└─────────────────────────────────────┘
```

#### Hotel / Accommodation
```
┌─────────────────────────────────────┐
│  🏨  Eurostars Gran Vía             │
│  Gran Via De Colón 20, Granada      │
│  ─────────────────────────────────  │
│  Check-in   May 11  from 15:00      │
│  Check-out  May 12  by 11:00        │
│  Conf: 121232  ·  1 night           │
│  ─────────────────────────────────  │
│  [Map]  [Call]  [Add Calendar]      │
│  [Confirmation PDF]                 │
└─────────────────────────────────────┘
```

#### Attraction / Activity
```
┌─────────────────────────────────────┐
│  🏰  Alhambra + Nasrid Palaces      │
│  Guided Tour                        │
│  Tue May 12 · 09:30 → 12:30        │
│  ─────────────────────────────────  │
│  ⚠️  Arrive 09:15 — meet guide      │
│  ⚠️  Bring original passport        │
│  ⚠️  No selfie sticks inside        │
│  ⚠️  Backpack on front in palaces   │
│  Booking: GYGRFQQYM9MY              │
│  PIN: EjXLM3IR  ·  C$301.65        │
│  ─────────────────────────────────  │
│  [Entry QR]  [Map]  [Add Calendar]  │
└─────────────────────────────────────┘
```

#### Bus
```
┌─────────────────────────────────────┐
│  🚌  COMES — Tarifa → Algeciras     │
│  12:40  →  13:10  ·  30 min        │
│  ─────────────────────────────────  │
│  ⚠️  Buy in person at Tarifa station│
│  No online booking available        │
│  ─────────────────────────────────  │
│  [Map to station]  [Add Calendar]   │
└─────────────────────────────────────┘
```

---

## 6. Add Event Flow — Minimal-Type Design

The guiding rule: **never show a blank text box if a picker or scan can fill the field.**

### Entry points
- "+" FAB on Timeline
- "+" on any Day section footer
- Scan button in Wallet
- Share extension from Mail / Safari / Files

### Step 1 — Choose type
Bottom sheet with large icons in a 3×3 grid:
```
✈️ Flight    🚄 Train    🚌 Bus
🏨 Hotel     🏠 Airbnb   🏕 Hostel
🎟 Attraction 🍽 Restaurant 🎭 Show
```
Swipe up for more: Ferry, Car Rental, Insurance, Receipt, Custom

### Step 2 — Source

```
[📷 Scan QR / Barcode]   ← primary CTA
[📄 Import PDF / Image]
[✉️ From Email]           (iOS 18: AI auto-detect)
[🔍 Search]               (map-first)
[➕ Add manually]         (last resort)
```

### Step 3a — QR Scan path
- Camera opens immediately
- AVFoundation QR + barcode detection
- On detect: haptic feedback, frame locks
- Parser attempts to identify document type:
  - Aztec / PDF417 → boarding pass (BCBP standard)
  - QR with URL → web scrape for reservation data
  - QR with text → OCR + NLP entity extraction
- Bottom sheet rises with parsed data for user review
- Tappable fields: user confirms or picks from dropdown
- One "Add to trip" button saves

### Step 3b — PDF Import path
- Files picker or document scanner
- VisionKit + VNRecognizeTextRequest runs OCR
- NLP extracts: dates, times, names, reference numbers, amounts, locations
- Recognized fields shown in a structured "card" preview
- Each field has a confidence level; low-confidence fields highlighted for user to tap and correct
- Correction = pick from suggestions or scroll picker — no freeform typing unless necessary

### Step 3c — Map Search path (for places)
- Full-screen MapKit search
- Autocomplete dropdown as user types venue name
- Tap result → pin appears on map
- Bottom sheet confirms: name, address, category, opening hours (from MapKit POI data)
- User adds time via time picker
- Confirms

### Step 3d — Manual path
- Strictly: pickers, segmented controls, date/time wheels, dropdowns
- Text fields only for: booking reference number, notes
- Time input: wheel picker (no keyboard)
- Location: map pin picker (tap map), NOT address text field
- Category: icon grid, not text

---

## 7. QR Wallet Pass Engine

### Scan & parse
**Supported formats:**
- PDF417 (most airline boarding passes — IATA BCBP standard)
- Aztec (UK/EU rail)
- QR Code (hotels, attractions, events)
- Code 128 / 39 (older venue tickets)
- DataMatrix (some EU rail)

**BCBP parser (boarding pass):**
Field extraction: PNR, origin, destination, carrier, flight number, departure date/time, seat, class, frequent flyer number.

**Generic QR → structured data:**
1. Decode QR to string
2. If URL: fetch page, extract `<meta>` tags + structured JSON-LD (schema.org ReservationPackage / FlightReservation / LodgingReservation / EventReservation)
3. If plain text: NLP pipeline for entity extraction (dates, times, amounts, names, reference patterns)
4. Result → pre-filled card, user confirms

### Display
- Full-brightness during QR display
- Auto-disable auto-lock while ticket is open
- Pinch to zoom QR (for stubborn scanners)
- Toggle between QR / barcode view if ticket has both
- White background forced regardless of dark mode

### Apple Wallet export
Where a PKPass can be generated from parsed data (flights, some hotels):
- Waypoint generates a `.pkpass` and offers "Add to Apple Wallet"
- The native Wallet app holds a backup copy accessible without Waypoint open
- Supported for: flight boarding passes (with airline logo), generic event passes

---

## 8. Maps — City Pin System

### Pin types and icons

| Category | Icon | Color |
|---|---|---|
| Accommodation | 🏨 | Indigo |
| Flight origin/dest | ✈️ | Sky blue |
| Train station | 🚄 | Teal |
| Bus station | 🚌 | Lime |
| Attraction / museum | 🏛 | Orange |
| Tour meeting point | 📍 | Red |
| Restaurant | 🍽 | Yellow |
| Nightlife | 🎭 | Purple |
| Viewpoint | 🔭 | Cyan |
| Beach | 🏖 | Sand |

### Map interactions
- Single tap pin: mini event card (name, time, tap to open full event)
- Long press map: "Add place here" → creates custom pin
- Two-finger drag: tilt to 3D view (iOS 17+)
- Route between day's pins: "Show route" button draws walking/transit path

### City overview
- On entering Map tab: map auto-fits all pins in selected city
- Day filter: map animates to show only that day's pins and draws route
- Cluster pins when zoomed out; tap cluster to zoom in

### Offline maps — iOS 17+
- On Wi-Fi: when city is added to trip, MapKit automatically downloads offline region (street, POI, transit layer)
- Size indicator shown in Settings → Storage
- Manual download: Settings → Offline Maps → select city → Download
- Tiles expire after 30 days, re-downloaded when trip is opened and online

---

## 9. Notifications & Live Activities

### Philosophy
Notifications are opt-in per event. The goal is a single timely nudge before something important — not a stream of pings. A user who hates notifications can disable them globally or per-event and still get everything from the app itself.

### How to enable
- **Global toggle:** Settings → Notifications → On/Off
- **Per event:** Event Detail → bell icon → choose when (at time / 30 min before / 1h before / 2h before / custom)
- **Suggested defaults:** applied automatically when you add an event but only sent if global toggle is on

### Suggested default timings (user can change or dismiss per event)

| Event type | Default alert | What it says |
|---|---|---|
| Flight | 2h before departure | Carrier + route + reminder to have boarding pass ready |
| Train / bus | 1h before departure | Route + seat + departure station |
| Hotel check-in | Day of, 09:00 local | Property name + check-in time + confirmation number |
| Attraction (timed entry) | 30 min before | Name + any ⚠️ notes (dress code, meeting point, what to bring) |
| Guided tour | 2h before + 30 min before | 2h: general reminder; 30m: meeting point details + warning notes |
| Restaurant (reserved) | 30 min before | Name + address |
| Custom event | At event time | Title only |

**Warning notes** — those "⚠️ must-know" details (meeting point, bring passport, no selfie sticks, in-person purchase only) are stored on the event and surface in the 30-min pre-event notification. Not before, not again after. Just once, when it actually matters.

**No notification spam rule:** max 2 notifications per event ever. If a 2h and a 30m reminder are both set, those are the only two. Nothing on the morning of, nothing the night before, nothing at departure unless the user adds it manually.

### Live Activities (iOS 17+)

**During a flight:**
- Lock Screen: route arc animation, countdown to arrival, current status
- Dynamic Island compact: "BF761 · 4h 12m remaining"
- Dynamic Island expanded: departure gate, seat, layover info

**During a train/bus leg:**
- Lock Screen: "Renfe Avant · 23 min to Granada"
- Dismisses automatically on arrival

**Active tour:**
- Lock Screen: "Alhambra Tour · Ends in 1h 45m · ⚠️ Backpack on front"

---

## 10. Calendar Integration

**EventKit integration for Apple Calendar:**

On any event detail screen: **"Add to Calendar"** button.

Adds to user's chosen Apple Calendar (picker on first use, remembered). Event includes:
- Title: event name
- Date/time: from event
- Location: address string (opens in Maps from Calendar)
- Notes: all warning notes + booking reference
- Alert: matches the notification timing from §9
- URL: deep link back to the Waypoint event

**Bulk export:**
Trip Hub → ··· menu → "Export trip to Calendar" → creates a temporary calendar named "Waypoint: Spain 2026" in Apple Calendar with all events. User can delete calendar to un-export.

**iCal (.ics) export:**
For sharing with a companion or importing into Google Calendar. Generated from all trip events, downloaded to Files.

---

## 11. Receipt & Expense Tracking

### Trip currency
Set once at trip creation — a single currency for the whole trip (e.g. CAD for a Canadian traveler, EUR for a European). All prices and expenses are entered and displayed in that currency. No conversion complexity; you just log what you paid (convert in your head if you paid in a different local currency, or use the optional local-amount field — see below).

### Capture flow
1. Tap + in Budget tab → "Scan Receipt"
2. Camera opens with document-detection overlay (VisionKit live detection)
3. Auto-shutter when document corners detected (or manual)
4. OCR runs: extracts merchant name, total, date, and currency symbol if visible
5. Pre-filled card — all pickers, no typing unless necessary:
   - Merchant: suggested from OCR; tap to edit or search
   - Amount: number wheel in **trip currency** (e.g. CA$); optional second field "local amount" if you paid in a different currency (EUR etc.)
   - Date: date picker (default: today)
   - Category: icon grid — Food · Transport · Accommodation · Activities · Shopping · Other
   - City: auto-detected from GPS or tap to pick from trip cities list
6. Save → receipt thumbnail + structured data stored

### Budget view
- Header: "CA$1,240 spent of CA$5,000 budget" — budget set at trip creation, editable anytime
- Progress bar: fills as you spend; turns amber at 80%, red at 100%
- Breakdown ring chart: tap a slice to filter the list below to that category
- Daily spend bar chart: tap any bar to see that day's receipts
- All amounts in trip currency

### Per-city spend
Sub-tab: "By City" — shows spend per city. Useful to see that Barcelona cost twice as much as Granada, for example.

---

## 12. Accommodation Detail — Special Fields

Hotels, Airbnbs, and hostels each have specific fields:

**Hotel:**
- Check-in time (from, usually 15:00)
- Check-out time (by, usually 11:00)
- Confirmation number
- Room number (fill in on arrival)
- Breakfast included (toggle)
- Free cancellation date + time (with reminder)
- WiFi name + password (fill in on arrival)
- Reception phone number

**Airbnb / Apartment:**
- Check-in method: key lockbox / host / smart lock / key exchange
- Lock code (fill in on arrival)
- Key collection address (if different)
- House rules (imported from PDF or typed)
- Host contact
- Tourist tax (amount, paid/unpaid status)
- Registration confirmation (upload PDF)

**Hostel / Retreat:**
- Dorm or private room
- Locker number / combo
- Shared facilities notes
- Curfew time (notification)
- Activities schedule (separate events linked to the accommodation)

---

## 13. iCloud Sync Detail

### What syncs
- All trip data (trips, events, attachments, tickets, receipts, documents)
- User preferences (default currency, notification settings, calendar link)
- Offline map download preferences (NOT the downloaded tiles — too large)

### What stays local only
- Downloaded offline map tiles
- App settings (dark mode preference, theme)

### Conflict resolution
- Last-write-wins for simple fields
- For deletions: soft-delete with 30-day recovery ("Recently deleted" in Settings)
- Sync status icon in Settings: ✅ Synced / ⏳ Syncing / ⚠️ Conflict / ✗ Error

### Privacy
- CloudKit private database: only the user's iCloud account can read their data
- Anthropic / Waypoint servers never receive trip content
- On-device OCR — receipt and ticket parsing happens locally

---

## 14. Widgets

### Home Screen widgets

**Small (2×2):**
"Next event" — event type icon, title, time countdown
```
  🏛  Alhambra Tour
  Starts in  2h 14m
  Tue May 12
```

**Medium (4×2):**
"Today's schedule" — up to 4 events for today, time + icon
```
  Today · Granada
  09:30  🏰 Alhambra Tour
  13:00  🍽 Lunch Plaza Nueva
  18:00  🚄 AVE to Córdoba
  21:00  🏨 Check in Mezquita
```

**Large (4×4):**
"Trip overview" — today schedule + mini map with today's pins

### Lock Screen widgets (iOS 16+)

**Inline:** "2h 14m · Alhambra"
**Rectangular:** next event card (same as small Home widget)
**Circular:** countdown ring (hours remaining, event icon center)

### Interactive widgets (iOS 17+)
- "Mark arrived" button on event widgets
- Tapping marks the event done in the app without opening it

---

## 15. Technical Architecture

### Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| State management | @Observable + SwiftData |
| Local persistence | SwiftData (replaces Core Data in iOS 17+; Core Data fallback for iOS 16) |
| iCloud sync | CloudKit (NSPersistentCloudKitContainer for iOS 16; SwiftData + CloudKit for iOS 17+) |
| Maps | MapKit + MapKit for SwiftUI |
| Offline maps | MapKit offline tile cache (iOS 17+) |
| QR / barcode scan | AVFoundation (AVCaptureMetadataOutput) |
| Document scan | VisionKit (VNDocumentCameraViewController) |
| OCR | Vision framework (VNRecognizeTextRequest) |
| NLP | Natural Language framework (NLTagger, NLTokenizer) |
| Calendar | EventKit |
| Wallet passes | PassKit (PKAddPassesViewController, PKPass generation) |
| Notifications | UserNotifications |
| Live Activities | ActivityKit (iOS 17+) |
| Widgets | WidgetKit |
| Weather | WeatherKit |
| Location | Core Location |
| PDF rendering | PDFKit |
| Exchange rates | Open Exchange Rates API (free tier, cached daily) |
| Apple Intelligence | SiriKit + App Intents (iOS 18) |

### Data model (key entities)

```swift
Trip
├── id: UUID
├── name: String
├── cities: [City]
├── startDate: Date
├── endDate: Date
├── coverImageData: Data?
├── currency: String          // ISO 4217
├── budget: Decimal?
└── events: [Event]

City
├── id: UUID
├── name: String
├── country: String
├── coordinate: CLLocationCoordinate2D
├── arrivalDate: Date
└── departureDate: Date

Event
├── id: UUID
├── type: EventType           // enum
├── title: String
├── startTime: Date
├── endTime: Date?
├── location: Location?
├── confirmationNumber: String?
├── warningNotes: [String]    // ⚠️ displayed pre-event
├── attachments: [Attachment] // tickets, PDFs
├── calendarEventID: String?  // if exported
└── typePayload: EventPayload // type-specific fields

EventType (enum)
  flight | trainRide | busRide | ferry | hotelCheckIn | hotelCheckOut
  airbnb | hostel | attraction | guidedTour | restaurant | nightlife
  show | viewpoint | beach | custom

Attachment
├── id: UUID
├── kind: AttachmentKind      // ticket | document | receipt | photo
├── fileData: Data
├── mimeType: String
├── parsedFields: [String: String]  // OCR / parser output
└── qrCodeContent: String?

Receipt
├── id: UUID
├── merchant: String
├── amount: Decimal
├── currency: String
├── date: Date
├── category: SpendCategory
├── city: City?
└── imageData: Data?
```

### Parsing pipeline

```
Input (QR string / PDF / image)
    │
    ▼
Format detection
    ├── PDF417 → BCBP parser → BoardingPassFields
    ├── QR URL → URLSession fetch → JSON-LD / meta extractor
    ├── QR text → regex patterns → reference numbers, dates
    └── Image / PDF → VNRecognizeTextRequest → raw text
            │
            ▼
        NLP pipeline
            ├── NLTagger: date, time, currency, place, person
            ├── Regex: booking refs, seat numbers, PNRs
            └── Heuristic classifiers → EventType suggestion
            │
            ▼
        Confidence-scored field map
            │
            ▼
        User review card (tappable corrections)
            │
            ▼
        Event + Attachment saved
```

---

## 16. Real Trip Walkthrough — Spain May 2026

How Waypoint would be used in your actual trip:

### Before leaving (setup)
1. Create trip: "Spain · May 2026"
2. Add cities in order: Tarifa → Granada → Córdoba → Valencia → Barcelona (+Brussels overnight)
3. Import each PDF from iCloud: flights, hotel confirmations, bus tickets → parser auto-creates events
4. Scan QR codes from tickets: Alhambra, Sagrada Família, Casa Batlló, Park Güell, Picasso, Flamenco show, FC Barcelona match
5. Set budget: CA$5,000
6. Download offline maps for all cities (on Wi-Fi)
7. Enable iCloud sync → all data backed up

### Day-of use examples

**Wed May 6 — Departure night**
- Lock Screen widget: "BF761 departs in 4h · YUL T3"
- Live Activity (iOS 17+): flight countdown, gate info as it appears
- Wallet: boarding pass QR ready, full-brightness

**Thu May 7 — Paris layover**
- 12:00 arrival notification: "At ORY · 5h self-transfer · ⚠️ Stay airside, do not go to city"
- Wallet shows both boarding passes: arriving BF761 + departing TO4608
- Map: ORY airport pin, gate area (no city map needed — user stays airside)

**Mon May 11 — Tarifa → Granada (complex travel day)**
- Timeline view for May 11 shows 5 transport legs in order
- 12:00 notification: "Leave retreat with bags · walk to Tarifa bus station (5 min)"
- 12:30 notification: "⚠️ COMES bus — buy ticket IN PERSON at Tarifa station"
- Bus event: no QR (in-person purchase) → event has instruction note
- Avanza bus: ticket QR in Wallet
- Renfe Avant: ticket QR in Wallet · "⚠️ Málaga bus station = train station (Vialia) — walk through"
- Live Activity: "AVANT 08835 · Arrives Granada 17:57 · 43 min remaining"
- Flamenco show notification at 21:30: "Cueva de la Rocío at 22:00 · ⚠️ No vehicles on Sacromonte path — taxi to foot of hill"

**Tue May 12 — Alhambra**
- 09:00 notification: "Alhambra Tour in 30 min · Arrive 09:15 · Meet guide at 'Guides' sign near ticket offices"
- Notification includes: "⚠️ Bring passport · No selfie sticks · Backpack worn on front in Nasrid Palaces"
- Event detail: booking ref GYGRFQQYM9MY, PIN EjXLM3IR, guide phone +34 644 927 756

**Sun May 17 — Match day**
- Park Güell notification: "11:00 entry slot · Go to Gaudí House Museum FIRST · Reservation held only 30 min"
- Match notification at 15:45: "FC Barcelona vs Real Betis · Metro L5 toward Collblanc · 17:00 kickoff"
- Match ticket QR in Wallet with FC Barcelona branding
- Post-match map: pins for El Born restaurants nearby

---

## 17. Phased Rollout

### Phase 1 — MVP (iOS 16+)
- Trips, Timeline, Map, Wallet, Docs
- QR scan + PDF import with OCR
- Manual event entry (picker-first)
- iCloud sync (opt-in)
- Basic notifications
- Lock Screen widgets

### Phase 2 (iOS 17+)
- Live Activities (flights, trains)
- Interactive widgets
- Offline vector maps download
- Dynamic Island trip pulse
- Budget tab with OCR receipts
- Apple Wallet pass export (PKPass generation)
- Full NLP parser pipeline

### Phase 3 (iOS 18+)
- Apple Intelligence: auto-import from email (App Intents + Siri)
- Journal app integration (log travel moments)
- Smart itinerary suggestions ("You have 2h free in El Born — here are nearby pins")
- On-device translation for foreign-language documents

---

## 18. Accessibility

- VoiceOver labels on all custom views (maps, ticket cards, QR display)
- Dynamic Type support throughout — no fixed font sizes
- Reduce Motion: animations disabled, transitions become fades
- High Contrast: stronger borders on cards, higher contrast badges
- Haptic feedback: QR scan success, event marked done, document parsed
- All interactive elements minimum 44×44pt touch target

---

## 19. App Store & Distribution

- Platform: iPhone only (iOS 16.0+)
- Distribution: App Store
- iCloud: required for sync feature; app fully functional without iCloud account
- Pricing model: one-time purchase (no subscription) — considered: free with one free trip, unlock unlimited trips with IAP
- App Store category: Travel
- Privacy nutrition label: no data sold; no data collected by developer; iCloud data stays in user's own CloudKit private database

---

## 20. Design Language

- **Palette:** Deep navy primary, warm amber accent (ticket gold), semantic colors per event type
- **Typography:** SF Pro (system) throughout — no custom fonts needed; system handles Dynamic Type
- **Cards:** Rounded rect (16pt radius), subtle drop shadow, color-coded left border by event type
- **Icons:** SF Symbols throughout — consistent with Apple ecosystem
- **Maps:** Standard MapKit style; dark mode switches to MapKit dark automatically
- **Dark mode:** Full support — OLED-friendly dark background (#000 or #0A0A0A)
- **Haptics:** UIImpactFeedbackGenerator (light) on most interactions; medium on scan success; success on "added to trip"

---

*Last updated: May 2026. Based on real usage patterns from a 16-day, 6-city, 20+ booking trip across southern Spain and Brussels.*
