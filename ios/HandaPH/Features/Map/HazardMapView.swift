import SwiftUI
import MapKit
import CoreLocation

/// Live map, redesigned per the Figma spec (HandaPH — Map & Personalised
/// Risk) and Hamza's SafeSignal concept: a personalised risk banner over the
/// map, a hazard-zone overlay, tappable colour-coded markers with a bottom
/// detail card, and a legend. MapKit for the zero-dependency build; the
/// planned swap is MapLibre Native + offline PMTiles — this file is the seam.
struct HazardMapView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var profileStore: HouseholdProfileStore
    @EnvironmentObject private var location: LocationProvider
    @State private var camera: MapCameraPosition = .automatic
    @State private var hasSetInitialCamera = false
    @State private var selectedLandmark: Landmark?
    @State private var showProfile = false
    @State private var activeRoute: MKRoute?
    @State private var routeTarget: Landmark?
    @State private var routeIsFallback = false

    private var center: CLLocationCoordinate2D {
        location.lastCoordinate ?? FixtureStore.fallbackCenter
    }

    private var risk: PersonalRisk {
        RiskEngine.assess(alerts: FixtureStore.alerts, profile: profileStore.profile, at: center)
    }

    var body: some View {
        NavigationStack {
            Map(position: $camera) {
                UserAnnotation()

                // Hazard layer: storm-surge inundation band (fixture geometry
                // standing in for a PHIVOLCS / Project NOAH layer).
                MapPolygon(coordinates: FixtureStore.surgeZone)
                    .foregroundStyle(.red.opacity(0.15))
                    .stroke(.red.opacity(0.6), lineWidth: 2)

                // ~1 km awareness radius around the user (or fixture centre).
                MapCircle(center: center, radius: 1000)
                    .foregroundStyle(.blue.opacity(0.08))
                    .stroke(.blue.opacity(0.6), lineWidth: 2)

                // Active walking route (Google Maps-style in-app navigation).
                if let activeRoute {
                    MapPolyline(activeRoute.polyline)
                        .stroke(Theme.brand, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                } else if routeIsFallback, let target = routeTarget {
                    // Offline fallback: straight dashed line, honestly labelled.
                    MapPolyline(coordinates: [center, target.coordinate])
                        .stroke(Theme.brand, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 8]))
                }

                // Alert markers — tapping opens the full alert detail.
                ForEach(FixtureStore.alerts.filter { $0.coordinate != nil }) { alert in
                    Annotation(alert.hazard.name.resolved(for: appState.language).text,
                               coordinate: alert.coordinate!) {
                        Button {
                            appState.deepLinkedAlert = alert
                        } label: {
                            Image(systemName: alert.hazard.symbolName)
                                .font(.callout.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(Theme.color(for: alert.severity), in: Circle())
                                .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                                .frame(width: Theme.minTapTarget, height: Theme.minTapTarget)
                                .contentShape(Rectangle())
                        }
                        .accessibilityLabel(alert.headline.resolved(for: appState.language).text)
                        // Hazards beyond the relevance radius stay visible
                        // but recede — they are not YOUR hazard right now.
                        .opacity(RiskEngine.isRelevant(alert, at: center) ? 1 : 0.45)
                    }
                }

                // Response-phase layer: NGO/DSWD feeding sites appear only
                // while a serious hazard is active near the user.
                if risk.severity >= .warning {
                    ForEach(FixtureStore.foodShelters) { shelter in
                        Annotation(shelter.name, coordinate: shelter.coordinate) {
                            Button {
                                selectedLandmark = shelter
                            } label: {
                                Image(systemName: shelter.kind.symbolName)
                                    .font(.callout.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 34, height: 34)
                                    .background(.orange, in: Circle())
                                    .frame(width: Theme.minTapTarget, height: Theme.minTapTarget)
                                    .contentShape(Rectangle())
                            }
                            .accessibilityLabel(shelter.name)
                        }
                    }
                }

                // Landmarks (curated + OpenStreetMap extract) — tapping
                // shows the bottom detail card.
                ForEach(FixtureStore.allLandmarks) { landmark in
                    Annotation(landmark.name, coordinate: landmark.coordinate) {
                        Button {
                            selectedLandmark = landmark
                        } label: {
                            Image(systemName: landmark.kind.symbolName)
                                .font(.callout.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(color(for: landmark.kind), in: Circle())
                                .overlay(
                                    Circle().strokeBorder(
                                        selectedLandmark?.id == landmark.id ? color(for: landmark.kind) : .clear,
                                        lineWidth: 3
                                    )
                                    .padding(-5)
                                )
                                .frame(width: Theme.minTapTarget, height: Theme.minTapTarget)
                                .contentShape(Rectangle())
                        }
                        .accessibilityLabel(landmark.name)
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .overlay(alignment: .bottomLeading) {
                // ODbL attribution for the bundled POI extract.
                Text("POI data © OpenStreetMap contributors")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.regularMaterial, in: Capsule())
                    .padding(.leading, 8)
                    .padding(.bottom, 2)
            }
            .safeAreaInset(edge: .top) {
                PersonalRiskBanner(risk: risk) {
                    if let alert = risk.drivingAlert { appState.deepLinkedAlert = alert }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    if location.isDenied {
                        locationDeniedNotice
                    }
                    if let target = routeTarget {
                        RouteBar(
                            target: target,
                            route: activeRoute,
                            isFallback: routeIsFallback,
                            from: center
                        ) {
                            endRoute()
                        }
                    } else if let landmark = selectedLandmark {
                        LandmarkDetailCard(landmark: landmark, from: center, onRoute: {
                            Task { await startRoute(to: landmark) }
                        }, onClose: {
                            selectedLandmark = nil
                        })
                    } else {
                        legend
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
            }
            .navigationTitle(L10n.t(.mapTitle, appState.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        Label(L10n.t(.profileTitle, appState.language), systemImage: "person.2.fill")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showProfile) {
                HouseholdProfileView()
                    .presentationDetents([.medium, .large])
            }
            .onAppear {
                // Runs on every return to this tab; don't discard the
                // user's pan/zoom by resetting the camera again.
                guard !hasSetInitialCamera else { return }
                hasSetInitialCamera = true
                location.requestAccess()
                camera = .region(MKCoordinateRegion(
                    center: center,
                    latitudinalMeters: 3500,
                    longitudinalMeters: 3500
                ))
            }
        }
    }

    /// Google Maps-style in-app route: MKDirections walking route when the
    /// network allows; a straight dashed line with a distance estimate when
    /// it doesn't (offline is the normal case in the response phase).
    private func startRoute(to landmark: Landmark) async {
        selectedLandmark = nil
        routeTarget = landmark
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: center))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: landmark.coordinate))
        request.transportType = .walking
        if let route = try? await MKDirections(request: request).calculate().routes.first {
            activeRoute = route
            routeIsFallback = false
            camera = .rect(route.polyline.boundingMapRect.insetBy(dx: -600, dy: -600))
        } else {
            activeRoute = nil
            routeIsFallback = true
        }
    }

    private func endRoute() {
        activeRoute = nil
        routeTarget = nil
        routeIsFallback = false
    }

    private var legend: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                legendChip(symbol: "cross.fill", tint: .red, text: L10n.t(.legendHospital, appState.language))
                legendChip(symbol: "figure.walk.arrival", tint: .green, text: L10n.t(.legendEvacuation, appState.language))
                legendChip(symbol: "building.columns.fill", tint: .indigo, text: L10n.t(.legendBarangay, appState.language))
                if risk.severity >= .warning {
                    legendChip(symbol: "fork.knife", tint: .orange, text: L10n.t(.legendFood, appState.language))
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func legendChip(symbol: String, tint: Color, text: String) -> some View {
        Label {
            Text(text).font(.footnote.weight(.semibold))
        } icon: {
            Image(systemName: symbol).foregroundStyle(tint)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(.regularMaterial, in: Capsule())
    }

    private var locationDeniedNotice: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(L10n.t(.locationOff, appState.language), systemImage: "location.slash")
                .font(.subheadline.weight(.semibold))
            Text(L10n.t(.locationOffBody, appState.language))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }

    private func color(for kind: Landmark.Kind) -> Color {
        switch kind {
        case .hospital: .red
        case .evacuationCenter: .green
        case .barangayHall: .indigo
        case .foodShelter: .orange
        }
    }
}

// MARK: - Personalised risk banner

/// The Figma design's top banner: severity + phase for YOUR area, plus the
/// advice lines the household profile makes relevant. Tapping opens the
/// driving alert.
struct PersonalRiskBanner: View {
    @EnvironmentObject private var appState: AppState
    let risk: PersonalRisk
    let onTap: () -> Void

    var body: some View {
        let language = appState.language
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: risk.severity.symbolName)
                    Text("\(L10n.t(.yourArea, language)): \(severityLabel(language))")
                        .font(.subheadline.weight(.heavy))
                    Spacer()
                    if risk.drivingAlert != nil {
                        Text(phaseLabel(language))
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.thinMaterial, in: Capsule())
                    }
                }
                if risk.drivingAlert == nil {
                    Text(L10n.t(.noActiveRisk, language))
                        .font(.footnote)
                } else {
                    Text("\(L10n.t(.riskIndex, language)): \(risk.score)/100")
                        .font(.caption.weight(.semibold))
                        .opacity(0.9)
                    ForEach(risk.adviceKeys.prefix(2), id: \.self) { key in
                        Label(L10n.t(key, language), systemImage: "person.crop.circle.badge.exclamationmark")
                            .font(.footnote.weight(.medium))
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .foregroundStyle(Theme.textColor(on: risk.severity))
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.color(for: risk.severity), in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.top, 4)
        .accessibilityElement(children: .combine)
    }

    private func severityLabel(_ language: AppLanguage) -> String {
        switch risk.severity {
        case .danger: L10n.t(.severityDanger, language)
        case .warning: L10n.t(.severityWarning, language)
        case .advisory: L10n.t(.severityAdvisory, language)
        }
    }

    private func phaseLabel(_ language: AppLanguage) -> String {
        switch risk.phase {
        case .prepare: L10n.t(.prepare, language)
        case .expectedSoon: L10n.t(.expectedSoon, language)
        case .happeningNow: L10n.t(.happeningNow, language)
        case .allClear: L10n.t(.allClear, language)
        }
    }
}

// MARK: - Landmark detail card

/// Bottom card shown when a marker is tapped: distance, walking time,
/// walking directions (hands off to Apple Maps), and text-to-speech.
struct LandmarkDetailCard: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openURL) private var openURL
    let landmark: Landmark
    let from: CLLocationCoordinate2D
    let onRoute: () -> Void
    let onClose: () -> Void

    /// Real walking ETA from MKDirections, fetched when the card appears —
    /// the Google Maps moment: you see time + arrival before committing.
    @State private var etaSeconds: TimeInterval?

    private var distanceMetres: Int {
        let a = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let b = CLLocation(latitude: landmark.coordinate.latitude, longitude: landmark.coordinate.longitude)
        return Int(a.distance(from: b))
    }

    /// Real ETA when available; ~80 m/min conservative estimate otherwise.
    private var walkMinutes: Int {
        if let etaSeconds { return max(1, Int(etaSeconds / 60)) }
        return max(1, distanceMetres / 80)
    }

    private var arrival: Date { Date().addingTimeInterval(etaSeconds ?? Double(walkMinutes * 60)) }

    private func fetchETA() async {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: landmark.coordinate))
        request.transportType = .walking
        if let response = try? await MKDirections(request: request).calculateETA() {
            etaSeconds = response.expectedTravelTime
        }
    }

    var body: some View {
        let language = appState.language
        let kindLabel = kindText(language)

        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: landmark.kind.symbolName)
                    .font(.callout.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(kindColor, in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(landmark.name)
                        .font(.headline)
                    Text("\(kindLabel) · \(distanceMetres) m · \(walkMinutes) \(L10n.t(.walkSuffix, language))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text("\(L10n.t(.arrive, language)) \(arrival, format: .dateTime.hour().minute())")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.brand)
                    if let source = landmark.source {
                        // Named provenance builds the trust the open map
                        // borrows from its partners.
                        Label(source, systemImage: "checkmark.seal")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: Theme.minTapTarget, height: Theme.minTapTarget)
                }
                .accessibilityLabel("Close")
            }

            HStack(spacing: 10) {
                // In-app route, drawn on this map.
                Button(action: onRoute) {
                    Label(L10n.t(.directions, language), systemImage: "figure.walk")
                        .font(.body.weight(.semibold))
                        .frame(minHeight: Theme.minTapTarget)
                }
                .buttonStyle(.borderedProminent)

                SpeakButton(
                    text: "\(landmark.name). \(kindLabel). \(distanceMetres) m, \(walkMinutes) \(L10n.t(.walkSuffix, language)).",
                    language: language
                )

                Spacer()

                // Hand off to Apple Maps for turn-by-turn voice guidance.
                Button {
                    let c = landmark.coordinate
                    if let url = URL(string: "http://maps.apple.com/?daddr=\(c.latitude),\(c.longitude)&dirflg=w") {
                        openURL(url)
                    }
                } label: {
                    Image(systemName: "arrow.triangle.turn.up.right.circle")
                        .font(.title2)
                        .frame(width: Theme.minTapTarget, height: Theme.minTapTarget)
                }
                .accessibilityLabel("Apple Maps")
            }
        }
        .padding(Theme.cardPadding)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .task(id: landmark.id) { await fetchETA() }
    }

    private var kindColor: Color {
        switch landmark.kind {
        case .hospital: .red
        case .evacuationCenter: .green
        case .barangayHall: .indigo
        case .foodShelter: .orange
        }
    }

    private func kindText(_ language: AppLanguage) -> String {
        switch landmark.kind {
        case .hospital: L10n.t(.legendHospital, language)
        case .evacuationCenter: L10n.t(.legendEvacuation, language)
        case .barangayHall: L10n.t(.legendBarangay, language)
        case .foodShelter: L10n.t(.legendFood, language)
        }
    }
}

// MARK: - Route bar

/// Compact bar while a route is active: destination, distance, walking
/// time, end button. Replaces the card/legend — one thing on screen at a
/// time.
struct RouteBar: View {
    @EnvironmentObject private var appState: AppState
    let target: Landmark
    let route: MKRoute?
    let isFallback: Bool
    let from: CLLocationCoordinate2D
    let onEnd: () -> Void

    private var distanceMetres: Int {
        if let route { return Int(route.distance) }
        let a = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let b = CLLocation(latitude: target.coordinate.latitude, longitude: target.coordinate.longitude)
        return Int(a.distance(from: b))
    }

    private var walkMinutes: Int {
        if let route { return max(1, Int(route.expectedTravelTime / 60)) }
        return max(1, distanceMetres / 80)
    }

    var body: some View {
        let language = appState.language
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "figure.walk")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.brand)
                VStack(alignment: .leading, spacing: 1) {
                    Text(target.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text("\(distanceMetres) m · \(walkMinutes) \(L10n.t(.walkSuffix, language)) · \(L10n.t(.arrive, language)) \(Date().addingTimeInterval(route?.expectedTravelTime ?? Double(walkMinutes * 60)), format: .dateTime.hour().minute())")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onEnd) {
                    Text(L10n.t(.endRoute, language))
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12)
                        .frame(minHeight: 36)
                }
                .buttonStyle(.bordered)
            }
            if isFallback {
                Label(L10n.t(.routeUnavailable, language), systemImage: "wifi.slash")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Location

/// Thin Core Location wrapper. Location never leaves the device
/// (docs/architecture.md §8) — nothing here talks to the network.
@MainActor
final class LocationProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var lastCoordinate: CLLocationCoordinate2D?
    @Published private(set) var isDenied = false

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestAccess() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            isDenied = true
        @unknown default:
            break
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.isDenied = false
                self.manager.startUpdatingLocation()
            case .denied, .restricted:
                self.isDenied = true
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        Task { @MainActor in
            self.lastCoordinate = coordinate
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Keep the fixture fallback; the map must render regardless.
    }
}
