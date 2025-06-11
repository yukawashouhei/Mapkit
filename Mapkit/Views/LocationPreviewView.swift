//
//  LocationPreviewView.swift
//  Mapkit
//
//  Created by 湯川昇平 on 2025/06/09.
//

import SwiftUI

struct LocationPreviewView: View {
    
    let location: Location
    
    var body: some View {
        HStack {
            VStack(spacing: 16) {
                imageSection
                titleSection
            }
            
            VStack(spacing: 8) {
                learnMoreButton
                NextButton
                
                
            }
        }
    }
}

#Preview {
    ZStack {
        Color.green.ignoresSafeArea()
        
        LocationPreviewView(location:  LocationsDataService.locations.first!)
    }
}

extension LocationPreviewView {
    
    private var imageSection: some View {
        ZStack {
            if let imageName = location.imageNames.first {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
            }
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(location.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(location.cityName)
                .font(.subheadline)
            
        }
    }
}

private var learnMoreButton: some View {
    Button {
        
    } label: {
        Text("Learn more")
            .font(.headline)
            .frame(width: 120, height: 35)
    }
    .buttonStyle(.borderedProminent)
}

private var NextButton: some View {
    Button {
        
    } label: {
        Text("Next")
            .font(.headline)
            .frame(width: 120, height: 35)
    }
    .buttonStyle(.bordered)
}
