//
//  Create_a_Map.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/17/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox
import Combine

struct CreateMap: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var env: AppEnvironment
    var mapVm = MapViewModel()
    var featureToggles = FeatureToggles(displayTrails: false, allowTrailTaps: false, allowPOITaps: false)
    @State var alertMessages = MapAlertMessages()
    @ObservedObject var headingProvider = HeadingProvider()
    @State private var angle: CGFloat = 0
    let initialMapDefaults:MapInteractions = MapInteractions()
    
    init() {
        initialMapDefaults.defaults.mapBounds = mapVm.getColoradoBounds()
    }
    
    var body: some View {
        ZStack {
            MapView(initialState: initialMapDefaults, features: featureToggles, mapAlerts:$alertMessages)
            .navigationBarTitle(Text("Create a Map"), displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: Button(action : {
                    self.env.mapIntEnv.resetEnv()
                    self.mode.wrappedValue.dismiss()
                }){
                    Image(systemName: "arrow.left")
                })
            .edgesIgnoringSafeArea([.bottom])
            .alert(isPresented:$alertMessages.displayAlert) {
                Alert(title: Text(alertMessages.title), message: Text(alertMessages.message), dismissButton: .default(Text("OK")))
            }
//            .onAppear {
//                print("create map on appear called")
//                self.env.mapIntEnv.mapBounds = self.mapVm.getColoradoBounds()
//            }
            Image(systemName: "location.north")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 300, height: 300)
              .modifier(RotationEffect(angle: angle))
              .onReceive(self.headingProvider.objectWillChange) { newHeading in
                  withAnimation(.easeInOut(duration: 1.0)) {
                      self.angle = newHeading
                  }
              }

            Text(String("\(angle)"))
              .font(.system(size: 20))
              .fontWeight(.light)
              .padding(.top, 15)
            Button(action: {
                var value = self.headingProvider.heading
                value = value + 1.0
                self.headingProvider.heading = CGFloat(value)
            }, label: {
                Text("CO")
            })
        }
//        .onReceive(self.env.objectWillChange) { newEnv in
//            self.angle = newEnv
//        }
    }
    
}

struct CreateMap_Previews: PreviewProvider {
    static var previews: some View {
        return CreateMap()
    }
}

struct RotationEffect: GeometryEffect {
  var angle: CGFloat

  var animatableData: CGFloat {
    get { angle }
    set { angle = newValue }
  }

  func effectValue(size: CGSize) -> ProjectionTransform {
    return ProjectionTransform(
      CGAffineTransform(translationX: -150, y: -150)
        .concatenating(CGAffineTransform(rotationAngle: angle))
        .concatenating(CGAffineTransform(translationX: 150, y: 150))
    )
  }
}

public class HeadingProvider: NSObject, ObservableObject {

    public let objectWillChange = PassthroughSubject<CGFloat,Never>()

    public var heading: CGFloat = 0 {
        willSet {
            objectWillChange.send(newValue)
        }
    }

    private let locationManager: CLLocationManager

    public override init(){
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }

    public func updateHeading() {
        locationManager.startUpdatingHeading()
    }
}

extension HeadingProvider: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.heading = CGFloat(newHeading.trueHeading)
        }
    }
}
