//
//  MapViewModel.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/23/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import AccuTerraSDK
import Mapbox
//import CoreLocation

// class TrailsViewModelBrian: NSObject, ObservableObject, Identifiable, MapEventRouterDelegate {
class TrailsViewModelBrian: NSObject, ObservableObject {
    
    var value = 0
//    @EnvironmentObject var settings: UserSettings
    
    // var objectWillChange = PassthroughSubject<Void, Never>()
    
    var trailService: ITrailService?
    @Published var trails: Array<TrailBasicInfo>?
    @Published var trailCount: Int = 0
    // let mapEventRouter: MapEventRouter
    // @Published var selectedTrailID:Int64 = 0
    
    var selectedTrailID:Int64 = 0
    
//    var selectedTrailID:Int64 = 0 {
//        didSet {
//            objectWillChange.send()
//        }
//    }
    
    override init() {
        // self.mapEventRouter = MapEventRouter()
        super.init()
        // self.mapEventRouter.delegate = self
//        for i in 1...10 {
//            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
//                self.selectedTrailID += 1
//            }
//        }
    }
    
    @Published var selectedTrail:TrailBasicInfo?
//    @Published var isSearching = false
//    @Published var degrees:Double = 0.0
//    @Published var brianText = "Brian"
    // private let locationManager: CLLocationManager
    
    @Published var counter: Int = 0
    
    var timer = Timer()
    
    func brian2(value: Int) {
        print("brian2 ... value: \(value)")
        self.value = value
        print("brian2 selectedTrailID id: \(selectedTrailID)")

        objectWillChange.send()
    }
    
    func brian(value: Int, trailId:Int64) {
        print("brian ... value: \(value)")
        print("brian trail id: \(trailId)")
        self.value = value
        self.selectedTrailID = trailId
        // settings.score = trailId
        print("brian selectedTrailID id: \(selectedTrailID)")

        objectWillChange.send()
    }

    func start() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.counter += 1
        }
    }
    
    // var timer = Timer()
//    var objectWillChange = PassthroughSubject<Void, Never>()
//
//    func updateDirection() {
//        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//             self.degrees += 1
//            print("updateDirection")
//            // self.brianText = Int(self.degrees) % 2 == 0 ? "Elliott": "Brian"
//            // print("brianText: \(self.brianText)")
//         }
//    }
//
    /*
    override init() {
        // super.init()
        print("Initializing view model")
//        self.isSearching = false
        // self.selectedTrailID = 22
        // self.updateDirection()
        
        // self.locationManager = CLLocationManager()
        super.init()
        
        // self.locationManager.delegate = self
        // self.setup()
    }
 */
    
//    func doTrailsSearch() {
//        do {
//            if self.trailService == nil {
//                trailService = ServiceFactory.getTrailService()
//            }
//
//            let searchCriteria = try? TrailBasicSearchCriteria(
//                searchString: nil,
//                limit: Int(INT32_MAX))
//            if let service = trailService, let criteria = searchCriteria {
//                self.trails = try service.findTrails(byBasicCriteria: criteria)
//                if let count = self.trails?.count {
//                    self.trailCount = count
//                    print("Trails Found: \(count)")
//                }
//            }
//        }
//        catch {
//            debugPrint("\(error)")
//        }
//    }

    func searchTrails(mapView:AccuTerraMapView, coordinate:CLLocationCoordinate2D) -> Bool {
        print("searchTrails ...")

        let query = TrailsQuery(
            trailLayersManager: mapView.trailLayersManager,
            layers: Set(TrailLayerType.allValues),
            coordinate: coordinate,
            distanceTolerance: 2.0)

        let trailId = query.execute().trailIds.first
        if let id = trailId {
            print("trail ID: \(id)")
            self.brian(value: 1111, trailId: id)
            self.selectedTrailID = id
            self.brian(value: 222, trailId: id)
            // self.brianText = "David"
        }

        mapView.trailLayersManager.highLightTrail(trailId: trailId)
        self.showTrailPOIs(mapView: mapView, trailId: trailId)
        
        return trailId != nil
    }

    private func showTrailPOIs(mapView: AccuTerraMapView, trailId: Int64?) {
        if let trailId = trailId {
            do {
                if let trailManager = self.trailService,
                    let trail = try trailManager.getTrailById(trailId) {
                        mapView.trailLayersManager.showTrailPOIs(trail: trail)
                }
            }
            catch {
                debugPrint("\(error)")
            }
        } else {
            mapView.trailLayersManager.hideAllTrailPOIs()
        }
    }

    
//    private func setup() {
//        self.locationManager.requestWhenInUseAuthorization()
//
//        if CLLocationManager.headingAvailable() {
//            self.locationManager.startUpdatingLocation()
//            self.locationManager.startUpdatingHeading()
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        print("location did update")
//        self.degrees = -1 * newHeading.magneticHeading
//    }
}


