//
//  LocationManager.swift
//  Journey
//
//  Created by Camposm on 11/12/25.
//

import Foundation
import CoreLocation

/**
 * LocationManager - Handles GPS location fetching and authorization
 *
 * This class wraps Apple's CLLocationManager to provide easy location access.
 * It handles the authorization flow, fetches GPS coordinates, and converts them
 * to human-readable location strings e.g. "San Francisco, CA".
 *
 */
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  /* the iOS location manager that does the actual GPS work */
  private let manager = CLLocationManager()

  /* published property that views can observe - updates when location is fetched */
  @Published var locationString: String?

  /* flag to track if we need to fetch location after user grants permission */
  private var shouldRequestLocationAfterAuth = false

  override init() {
    super.init()
    manager.delegate = self /* this class will receive location updates */
    manager.desiredAccuracy = kCLLocationAccuracyBest /* request highest GPS accuracy */
  }

  /**
   * Requests the user's current location
   *
   * This function handles the authorization flow:
   * 1. If permission not asked yet (.notDetermined): Ask for permission first
   * 2. If already authorized: Fetch location immediately
   * 3. If denied: Show error message
   * Note: You must add NSLocationWhenInUseUsageDescription in Info.plist
   * to explain to users why you need their location.
   */
  func requestLocation() {
    print("Requesting location authorization and location...")
    print("Current authorization status: \(manager.authorizationStatus.rawValue)")

    let status = manager.authorizationStatus

    switch status {
    case .notDetermined:
      /* user hasn't been asked for permission yet */
      print("Authorization not determined, requesting...")
      shouldRequestLocationAfterAuth = true /* remember to fetch location after auth */
      manager.requestWhenInUseAuthorization() /* show iOS permission dialog */
    case .authorizedWhenInUse, .authorizedAlways:
      /* user already granted permission */
      print("Already authorized, fetching location...")
      manager.requestLocation() /* fetch GPS coordinates now */
    case .denied, .restricted:
      /* user denied permission or device restricts location access */
      print("Location access denied or restricted")
      self.locationString = "Location access denied"
    @unknown default:
      /* handles any future authorization states Apple might add */
      print("Unknown authorization status")
    }
  }

  /**
   * Delegate method called when GPS coordinates are successfully fetched
   *
   * This receives the raw GPS coordinates (latitude/longitude) and converts them
   * to a human-readable location string using "reverse geocoding".
   *
   * We use CLGeocoder to convert coordinates to place information (city, state, country)
   * and format it as "City, State" for display in the UI.
   */
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("Location received: \(locations.count) locations")
    guard let location = locations.first else { return }
    print("Coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")

    /* reverse geocode to get city and country */
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { placemarks, error in
      if let error = error {
        print("Geocoding error: \(error.localizedDescription)")
        return
      }

      if let placemark = placemarks?.first {
        /* extract location components from the placemark */
        let city = placemark.locality ?? "" /* e.g., "San Francisco" */
        let state = placemark.administrativeArea ?? "" /* e.g., "CA" */
        let country = placemark.country ?? "" /* e.g., "United States" */

        print("Geocoded: city=\(city), state=\(state), country=\(country)")

        /* format location string with available information (prefer city + state) */
        if !city.isEmpty && !state.isEmpty {
          self.locationString = "\(city), \(state)"
        } else if !city.isEmpty && !country.isEmpty {
          self.locationString = "\(city), \(country)"
        } else if !state.isEmpty && !country.isEmpty {
          self.locationString = "\(state), \(country)"
        } else {
          self.locationString = country
        }

        print("Final location string: \(self.locationString ?? "nil")")
      }
    }
  }

  /**
   * Delegate method called when location fetching fails
   *
   */
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location error: \(error.localizedDescription)")
  }

  /**
   * Delegate method called when authorization status changes
   *
   * This is called after the user responds to the permission dialog.
   * If we were waiting for authorization (shouldRequestLocationAfterAuth == true),
   * and the user granted permission, we now fetch the location.
   *
   * This completes the authorization flow started in requestLocation().
   */
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    print("Authorization status changed to: \(manager.authorizationStatus.rawValue)")

    /* if we were waiting for authorization, now request location */
    if shouldRequestLocationAfterAuth {
      let status = manager.authorizationStatus
      if status == .authorizedWhenInUse || status == .authorizedAlways {
        /* user granted permission! now fetch the GPS location */
        print("Authorization granted, now fetching location...")
        shouldRequestLocationAfterAuth = false
        manager.requestLocation()
      } else if status == .denied || status == .restricted {
        /* user denied permission or device restricts location */
        print("Authorization denied")
        shouldRequestLocationAfterAuth = false
        self.locationString = "Location access denied"
      }
    }
  }
}
