import SwiftUI
import MapKit
import CoreLocation

/// Live map: user location, ~1 km radius ring, hospitals and evacuation
/// centres highlighted (README Features). MapKit for the zero-dependency
/// first build; the planned swap is MapLibre Native + offline PMTiles
/// (docs/architecture.md §3) — this file is the only one that changes.
struct HazardMapView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var location = LocationProvider()
    @State private var camera: MapCameraPosition = .automatic
    @State private var hasSetInitialCamera = false

    private var center: CLLocationCoordinate2D {
        location.lastCoordinate ?? FixtureStore.fallbackCenter
    }

    var body: some View {
        NavigationStack {
            Map(position: $camera) {
                UserAnnotation()

                // ~1 km awareness radius around the user (or fixture centre).
                MapCircle(center: center, radius: 1000)
                    .foregroundStyle(.blue.opacity(0.08))
                    .stroke(.blue.opacity(0.6), lineWidth: 2)

                ForEach(FixtureStore.landmarks) { landmark in
                    Annotation(landmark.name, coordinate: landmark.coordinate) {
                        Image(systemName: landmark.kind.symbolName)
                            .font(.callout.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(color(for: landmark.kind), in: Circle())
                            // Visual stays 34pt; tappable area meets 44pt HIG minimum.
                            .frame(width: Theme.minTapTarget, height: Theme.minTapTarget)
                            .contentShape(Rectangle())
                            .accessibilityLabel(landmark.name)
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .safeAreaInset(edge: .bottom) {
                if location.isDenied {
                    locationDeniedNotice
                }
            }
            .navigationTitle(L10n.t(.mapTitle, appState.language))
            .onAppear {
                // Runs on every return to this tab; don't discard the
                // user's pan/zoom by resetting the camera again.
                guard !hasSetInitialCamera else { return }
                hasSetInitialCamera = true
                location.requestAccess()
                camera = .region(MKCoordinateRegion(
                    center: center,
                    latitudinalMeters: 3000,
                    longitudinalMeters: 3000
                ))
            }
        }
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
        .padding()
    }

    private func color(for kind: Landmark.Kind) -> Color {
        switch kind {
        case .hospital: .red
        case .evacuationCenter: .green
        case .barangayHall: .indigo
        }
    }
}

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
