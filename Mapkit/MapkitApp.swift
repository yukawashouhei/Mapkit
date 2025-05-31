//
//  MapkitApp.swift
//  Mapkit
//
//  Created by 湯川昇平 on 2025/05/30.
//

import SwiftUI

@main
struct MapkitApp: App {
    
    @StateObject private var vm = LocationsViewModel()
    
    var body: some Scene {
        WindowGroup {
            LocationsView()
                .environmentObject(vm)
        }
    }
}
