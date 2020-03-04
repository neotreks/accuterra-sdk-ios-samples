//
//  ViewController.swift
//  Adding-Trails
//
//  Created by Brian Elliott on 2/28/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import UIKit
import Mapbox
import AccuTerraSDK

class ViewController: UIViewController {

    @IBOutlet weak var mapView: AccuTerraMapView!
    @IBOutlet weak var percentCompleteLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    var isBaseMapLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    var isTrailsLayerManagersLoaded = false
    var trailService: ITrailService?
    var trails: Array<TrailBasicInfo>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("version: \(SdkInfo.version) - \(SdkInfo.versionName)")
        
        // Trails DB is installed - init SDK only
        if SdkManager.shared.isTrailDbInitialized {
            self.setButtons(true)
            initSdk()
        }
        else {
            self.setButtons(false)
        }
        
        initMap()
    }
    
    @IBAction func downloadTapped(_ sender: Any) {
        // Init & download DB
        initSdk()
    }
    
    private func initSdk() {
        guard let clientToken = Bundle.main.infoDictionary?["AccuTerraClientToken"] as? String,
            let serviceUrl = Bundle.main.infoDictionary?["AccuTerraServiceUrl"] as? String else {
                fatalError("AccuTerraClientToken and AccuTerraServiceUrl is missing in info.plist")
        }
        SdkManager.shared.initSdkAsync(config: SdkConfig(clientToken: clientToken, wsUrl: serviceUrl), delegate: self)
    }
    
    private func zoomToMapExtents() {
        // Colorado’s bounds
        let northeast = CLLocationCoordinate2D(latitude: 40.989329, longitude: -102.062592)
        let southwest = CLLocationCoordinate2D(latitude: 36.986207, longitude: -109.049896)
        let colorado = MGLCoordinateBounds(sw: southwest, ne: northeast)

        mapView.zoomToExtent(bounds: colorado, animated: true)
    }
    
    private func setButtons(_ initial: Bool) {
        guard SdkManager.shared.isTrailDbInitialized else {
            return
        }
        self.percentCompleteLabel.text = initial ? "DB Installed" : "Download Successfully Completed!"
        self.downloadButton.isEnabled = false
    }

    func initMap() {
        if SdkManager.shared.isTrailDbInitialized {
            self.trailService = ServiceFactory.getTrailService()
        }

        // Initialize map
        self.mapView.initialize()

        self.mapView.setUserTrackingMode(.follow, animated: true, completionHandler: {
        })
        self.mapView.isRotateEnabled = false //makes map interaction easier
        self.mapView.isPitchEnabled = false //makes map interaction easier
    }
}

extension ViewController : TrailLayersManagerDelegate {
    func onLayersAdded(trailLayers: Array<TrailLayerType>) {
        isTrailsLayerManagersLoaded = true
    }
}

extension ViewController : BaseMapLayersManagerDelegate {
    func onLayerAdded(baseMapLayer: BaseLayerType) {
        isBaseMapLayerManagersLoaded = true
    }
}

extension ViewController : AccuTerraMapViewDelegate {
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {}
    
    func onMapLoaded() {
        self.mapWasLoaded = true
        self.zoomToMapExtents()
        self.addBaseMapLayer()
        self.addTrailLayers()
    }
    
    private func addBaseMapLayer() {
        let baseMapLayersManager = self.mapView?.baseMapLayersManager
        baseMapLayersManager?.delegate = self
        baseMapLayersManager?.addLayer(baseLayer: BaseLayerType.RASTER_BASE_MAP)
    }
    
    private func addTrailLayers() {
        guard SdkManager.shared.isTrailDbInitialized else {
            return
        }
        let trailLayersManager = mapView.trailLayersManager

        trailLayersManager.delegate = self
        trailLayersManager.addStandardLayers()
    }
}

extension ViewController : SdkInitDelegate {
    func onProgressChanged(progress: Int) {
        DispatchQueue.main.async {
            self.percentCompleteLabel.text = "\(progress)% Complete"
        }
    }
    
    func onStateChanged(state: SdkInitState, detail: SdkInitStateDetail?) {
        DispatchQueue.main.async {
            switch state {
            case .COMPLETED:
                self.setButtons(true)
                if self.isBaseMapLayerManagersLoaded {
                    self.trailService = ServiceFactory.getTrailService()
                    self.addTrailLayers()
                }
                else {
                    self.initMap()
                }
             case .FAILED(let error):
                let alert = UIAlertController(title: "Error", message: "Download Failed. Error: \(String(describing: error))", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    // 
                }))
                self.present(alert, animated: true, completion: nil)
            default:
                break
            }
        }
    }
}

