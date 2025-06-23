//
//  LocationsViewModel.swift
//  Mapkit
//
//  Created by 湯川昇平 on 2025/05/31.
//

import Foundation
import MapKit
import SwiftUI

@MainActor
class LocationsViewModel: ObservableObject {
    
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
    
    init() {
        let locations = LocationsDataService.locations
        self.locations = locations
        self.mapLocation = locations.first!
        self.updateMapRegion(location: locations.first!)
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
