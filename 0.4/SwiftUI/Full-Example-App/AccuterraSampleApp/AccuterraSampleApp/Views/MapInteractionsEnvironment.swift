//
//  MapInteractionsEnvironment.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/2/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import Combine
import AccuTerraSDK
import Mapbox

struct MapInteractionsEnvironment {
    
    var mapCenter: CLLocationCoordinate2D?
    var mapBounds: MapBounds?
    var edgeInsets: UIEdgeInsets?
    var zoomAnimation: Bool = false
    var selectedTrailId:Int64 = 0
    
    let defaultEdgeInserts = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    mutating func setInteractions(center:CLLocationCoordinate2D? = nil, bounds:MapBounds? = nil, insets:UIEdgeInsets? = nil, zoom:Bool = false, trailId:Int64 = 0) {
        mapCenter = center
        mapBounds = bounds
        edgeInsets = insets
        zoomAnimation = zoom
        selectedTrailId = trailId
    }
    /*
    
    var mapCenter: CLLocationCoordinate2D? = nil {
        didSet {
            mapBounds = nil
            edgeInsets = defaultEdgeInserts
            zoomAnimation = false
            selectedTrailId = 0
        }
    }
    var mapBounds: MapBounds? = nil {
        didSet {
            mapCenter = nil
            edgeInsets = defaultEdgeInserts
            zoomAnimation = false
            selectedTrailId = 0
        }
    }
    
    var edgeInsets: UIEdgeInsets? = nil {
        didSet {
            mapCenter = nil
            mapBounds = nil
            zoomAnimation = false
            selectedTrailId = 0
        }
    }
    
    var zoomAnimation: Bool = false {
        didSet {
            mapCenter = nil
            mapBounds = nil
            edgeInsets = defaultEdgeInserts
            selectedTrailId = 0
        }
    }
    
    var selectedTrailId:Int64 = 0 {
        didSet {
            mapCenter = nil
            mapBounds = nil
            edgeInsets = defaultEdgeInserts
            zoomAnimation = false
        }
    }
 */
    
//    private var _mapCenter: CLLocationCoordinate2D?
//    private var _mapBounds: MapBounds?
//    private var _edgeInsets: UIEdgeInsets?
//    private var _zoomAnimation: Bool = false
//    private var _selectedTrailId:Int64 = 0
    
//    @objc var type: DecisionType {
//        didSet {
//            let isDecisionDouble = newValue == DecisionType.DecisionDouble
//
//            okButton.isHidden = isDecisionDouble;
//            yesButton.isHidden = !isDecisionDouble;
//            noButton.isHidden = !isDecisionDouble;
//        }
//    }
    
    
    /*
    var mapCenter: CLLocationCoordinate2D? {
        get {
            return _mapCenter
        }
        set {
            _mapCenter = newValue
            mapBounds = nil
            edgeInsets = defaultEdgeInserts
            zoomAnimation = false
            selectedTrailId = 0
        }
    }
    var mapBounds: MapBounds? {
        get {
            return _mapBounds
        }
        set {
            _mapCenter = nil
            _mapBounds = newValue
            _edgeInsets = defaultEdgeInserts
            _zoomAnimation = false
            _selectedTrailId = 0
        }
    }
    var edgeInsets: UIEdgeInsets? {
        get {
            return _edgeInsets
        }
        set {
            _mapCenter = nil
            _mapBounds = nil
            _edgeInsets = newValue
            _zoomAnimation = false
            _selectedTrailId = 0
        }
    }
    var zoomAnimation: Bool {
        get {
            return _zoomAnimation
        }
        set {
            _mapCenter = nil
            _mapBounds = nil
            _edgeInsets = defaultEdgeInserts
            _zoomAnimation = newValue
            _selectedTrailId = 0
        }
    }
    var selectedTrailId: Int64 {
        get {
            return _selectedTrailId
        }
        set {
            _mapCenter = nil
            _mapBounds = nil
            _edgeInsets = defaultEdgeInserts
            _zoomAnimation = false
            _selectedTrailId = newValue
        }
    }
 */
    
    mutating func resetEnv() {
        self.mapCenter = nil
        self.mapBounds = try! MapBounds( minLat: 37.99906, minLon: -109.04265, maxLat: 41.00097, maxLon: -102.04607)
        self.edgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.zoomAnimation = false
        self.selectedTrailId = 0
    }
}



