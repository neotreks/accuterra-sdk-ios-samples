//
//  ContentView.swift
//  AccuterraSampleAppSwiftUI
//
//  Created by Rudolf Kopřiva on 14.01.2021.
//

import SwiftUI
import Mapbox

struct ContentView: View {
    
    @ObservedObject private var sdkInitObserver = SdkInitObserver()
    
    var body: some View {
        if !sdkInitObserver.isInitialized {
            SdkInitView(sdkInitObserver: sdkInitObserver)
        } else {
            let mapView = MapView()
            mapView
            
            // Controls
            VStack(spacing: 20) {
                Text("Go to Location:")
                HStack {
                    Button(action: {
                        print("CO tapped!")
                        mapView.map.zoomToExtent(bounds: ContentView.getColoradoBounds(), animated: false)
                    }, label: {
                        Text("CO")
                            .padding()
                            .background(Color.white)
                    })
                    Button(action: {
                        print("Denver tapped!")
                        mapView.map.zoomLevel = 10
                        mapView.map.setCenter(ContentView.getDenverLocation(), animated: true)
                    }, label: {
                        Text("Denver")
                            .padding()
                            .background(Color.white)
                    })
                    Button(action: {
                        print("Castle Rock tapped!")
                        let camera = MGLMapCamera(lookingAtCenter: ContentView.getCastleRockLocation(), altitude: 4500, pitch: 0, heading: 0)
                        // Animate the camera movement over 5 seconds.
                        mapView.map.setCamera(camera, withDuration: 5, animationTimingFunction: CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
                    }, label: {
                        Text("Castle Rock")
                            .padding()
                            .background(Color.white)
                    })
                }.shadow(radius: 3)
            }
            .frame(height: 100.0)
        }
    }
    
    static func getColoradoBounds() -> MGLCoordinateBounds {
        // Colorado’s bounds
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)
        return colorado
    }
    
    static func getCastleRockLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 39.3722, longitude: -104.8561)
    }
    
    static func getDenverLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 39.7392, longitude: -104.9903)
    }
}
