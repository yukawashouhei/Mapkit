//
//  LocationDetailView.swift
//  Mapkit
//
//  Created by 湯川昇平 on 2025/06/14.
//

import SwiftUI

struct LocationDetailView: View {
    
    let location: Location
    
    var body: some View {
        ScrollView  {
            VStack {
                imageSection
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(location.name)
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        Text(location.cityName)
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text(location.description)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.5))
                .padding()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LocationDetailView(location: LocationsDataService.locations.first!)
}


extension LocationDetailView {
    
    private var imageSection: some View {
        TabView {
            ForEach(location.imageNames, id: \.self)  {
                Image($0)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width)
                    .clipped()
            }
        }
        .frame(height: 500)
        .tabViewStyle(PageTabViewStyle())
    }
}
