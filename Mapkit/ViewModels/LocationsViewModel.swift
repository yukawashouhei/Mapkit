//
//  LocationsViewModel.swift
//  Mapkit
//
//  Created by 湯川昇平 on 2025/05/31.
//

import Foundation
import MapKit
import SwiftUI
import CoreLocation

@MainActor
class LocationsViewModel: NSObject, ObservableObject {
    
    //All loaded locations
    @Published var locations: [Location]
    
    @Published var mapLocation: Location {
        didSet {
            updateMapRegion(location: self.mapLocation)
        }
    }
    
    // Current region on map
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    
    // Show List of location
    @Published var showLocationsList: Bool = false
    
    // show location detail via sheet
    @Published var sheetLocation: Location? = nil
    
    // Location manager for user location
    private let locationManager = CLLocationManager()
    
    // User location
    @Published var userLocation: CLLocation?
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        let locations = LocationsDataService.locations
        self.locations = locations
        self.mapLocation = locations.first!
        super.init()
        self.updateMapRegion(location: locations.first!)
        
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        
        // Check if location permission is already granted
        locationAuthorizationStatus = locationManager.authorizationStatus
        
        if locationAuthorizationStatus == .authorizedWhenInUse || locationAuthorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func centerOnUserLocation() {
        guard let userLocation = userLocation else { return }
        
        withAnimation(.easeInOut) {
            self.mapRegion = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: self.mapSpan
            )
        }
    }
    
    func showRouteToLocation(_ destination: Location) {
        guard let userLocation = userLocation else { return }
        
        // Create MKMapItems for source and destination
        let sourceMapItem = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        let destinationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinates))
        
        // Open in Apple Maps
        let request = MKDirections.Request()
        request.source = sourceMapItem
        request.destination = destinationMapItem
        request.transportType = .walking
        
        // Open Apple Maps with the route
        MKMapItem.openMaps(with: [sourceMapItem, destinationMapItem], 
                          launchOptions: [
                            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
                          ])
    }
    
    private func updateMapRegion(location: Location) {
        withAnimation(.easeInOut) {
            self.mapRegion = MKCoordinateRegion(
                center: location.coordinates,
                span: self.mapSpan)
        }
    }
    
    func toggleLocationsList() {
        withAnimation(.easeInOut) {
            self.showLocationsList.toggle()
        }
    }
    
    func showNextLocation(location: Location) {
        withAnimation(.easeInOut) {
            self.mapLocation = location
            self.showLocationsList = false
        }
    }
    
    func nextButtonPressed() {
        //Get the current index
        guard let currentIndex = locations.firstIndex(where: { $0 == mapLocation}) else {
            print("Could not find current index in locations array! Should never happen.")
            return
        }
        
        // Check if the currentIndex is valid
        let nextIndex = currentIndex + 1
        let nextLocation: Location
        
        if locations.indices.contains(nextIndex) {
            // Next index is Valid
            nextLocation = locations[nextIndex]
        } else {
            // Next Index is not valid, restart from 0
            guard let firstLocation = locations.first else {
                print("Locations array is empty! Should never happen.")
                return
            }
            nextLocation = firstLocation
        }
        
        Task { @MainActor in
            withAnimation(.easeInOut) {
                self.mapLocation = nextLocation
                self.showLocationsList = false
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationsViewModel: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.userLocation = location
            
            // Center on user location if this is the first location update
            if self.locationAuthorizationStatus == .authorizedWhenInUse || self.locationAuthorizationStatus == .authorizedAlways {
                self.centerOnUserLocation()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            self.locationAuthorizationStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.startUpdatingLocation()
            case .denied, .restricted:
                // Handle denied access - user can still use the app without location
                break
            case .notDetermined:
                // Wait for user decision
                break
            @unknown default:
                break
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
