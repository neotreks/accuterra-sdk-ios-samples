//
//  MapEventRouter.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/27/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import AccuTerraSDK
import Mapbox

protocol MapEventRouterDelegate {
    func searchTrails(mapView:AccuTerraMapView, coordinate:CLLocationCoordinate2D) -> Bool
}

class MapEventRouter {
        
    var delegate:MapEventRouterDelegate?
    
    func searchTrails(mapView:AccuTerraMapView, coordinate:CLLocationCoordinate2D) -> Bool {
        if let delegate = self.delegate {
            return delegate.searchTrails(mapView: mapView, coordinate: coordinate)
        }
        return false
    }
    
}
