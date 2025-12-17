//
//  MapView.swift
//  Journey
//
//  Created by Camposm on 11/12/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
  let locationName: String?

  @State private var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default: San Francisco
    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
  )
  @State private var coordinate: CLLocationCoordinate2D?
  @State private var isLoading = true

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if let locationName = locationName {
        // Location header
        HStack(spacing: 6) {
          Image(systemName: "mappin.and.ellipse")
            .font(.system(size: 16))
            .foregroundColor(.red)
          Text(locationName)
            .font(.system(size: AppFontSize.body))
            .fontWeight(.semibold)
        }
        .padding(.horizontal, AppSpacing.medium)
        .padding(.bottom, AppSpacing.small)

        // Map view
        ZStack {
          Map(coordinateRegion: $region, annotationItems: coordinate != nil ? [MapPin(coordinate: coordinate!)] : []) { pin in
            MapMarker(coordinate: pin.coordinate, tint: .red)
          }
          .frame(height: 200)
          .cornerRadius(12)

          if isLoading {
            ProgressView()
              .padding()
              .background(Color(.systemBackground).opacity(0.8))
              .cornerRadius(8)
          }
        }
        .padding(.horizontal, AppSpacing.medium)
      }
    }
    .onAppear {
      geocodeLocation()
    }
  }

  private func geocodeLocation() {
    guard let locationName = locationName else {
      isLoading = false
      return
    }

    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(locationName) { placemarks, error in
      DispatchQueue.main.async {
        isLoading = false

        if let error = error {
          print("Geocoding error: \(error.localizedDescription)")
          return
        }

        if let placemark = placemarks?.first,
           let location = placemark.location {
          let coord = location.coordinate
          self.coordinate = coord
          self.region = MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
          )
        }
      }
    }
  }
}

// Helper struct for map annotations
struct MapPin: Identifiable {
  let id = UUID()
  let coordinate: CLLocationCoordinate2D
}

#Preview {
  VStack(spacing: 20) {
    MapView(locationName: "San Francisco, CA")
    MapView(locationName: "Paris, France")
    MapView(locationName: nil)
  }
  .padding()
}
