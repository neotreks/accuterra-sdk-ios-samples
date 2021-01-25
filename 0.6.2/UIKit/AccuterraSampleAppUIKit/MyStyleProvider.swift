//
//  MyStyleProvider.swift
//  AccuterraSampleAppUIKit
//
//  Created by Rudolf Kopřiva on 17.01.2021.
//

import Foundation
import AccuTerraSDK
import Mapbox

class MyStyleProvider: AccuTerraStyleProvider {
    override func getTrailProperties(type: TrailLayerStyleType, layer: MGLLineStyleLayer) -> MGLLineStyleLayer {
        let customizedStyleLayer = super.getTrailProperties(type: type, layer: layer)
        switch(type) {
        case .TRAIL_PATH:
            customizedStyleLayer.lineColor = NSExpression(forConstantValue: UIColor(hex:"274466"))
        case .SELECTED_TRAIL_PATH:
            customizedStyleLayer.lineColor = NSExpression(forConstantValue: UIColor(hex:"00AA00"))
            customizedStyleLayer.lineWidth = NSExpression(forConstantValue: 3.0)
        default:
            break
        }
        return customizedStyleLayer
    }
    
    override func getPoiImage(type: TrailPoiStyleType) -> UIImage {
        return UIImage(named: "ic_location_pin_template")?.withRenderingMode(.alwaysTemplate) ?? super.getPoiImage(type: type)
    }
    
    override func getPoiProperties(type: TrailPoiStyleType, layer: MGLSymbolStyleLayer) -> MGLSymbolStyleLayer {
        let customizedStyleLayer = super.getPoiProperties(type: type, layer: layer)
        switch(type) {
        case .TRAIL_HEAD:
            customizedStyleLayer.iconColor = NSExpression(forConstantValue: UIColor(hex: "009688"))
        case .TRAIL_POI:
            customizedStyleLayer.iconColor = NSExpression(forConstantValue: UIColor(hex: "9C27B0"))
        case .SELECTED_TRAIL_POI:
            customizedStyleLayer.iconColor = NSExpression(forConstantValue: UIColor(hex: "4C7BFF"))
        }
        return customizedStyleLayer
    }
    
    override func getTrailMarkerProperties(type: TrailMarkerStyleType, layer: MGLVectorStyleLayer) -> MGLVectorStyleLayer {
        let customizedStyleLayer = super.getTrailMarkerProperties(type: type, layer: layer)
        
        switch(type) {
        case .CLUSTER:
            if customizedStyleLayer is MGLCircleStyleLayer {
                let circleLayer = customizedStyleLayer as! MGLCircleStyleLayer
                circleLayer.circleRadius = NSExpression(forConstantValue: NSNumber(value: 15))
                circleLayer.circleOpacity = NSExpression(forConstantValue: 0.5)
                circleLayer.circleColor = NSExpression(forConstantValue: UIColor(hex: "D59004"))
                return circleLayer
            }
            else {
                return customizedStyleLayer
            }
        case .CLUSTER_LABEL:
            if customizedStyleLayer is MGLSymbolStyleLayer{
                let symbolLayer = layer as! MGLSymbolStyleLayer
                symbolLayer.text = NSExpression(format: "CAST(point_count, 'NSString')")
                symbolLayer.textFontSize = NSExpression(forConstantValue: NSNumber(value: 11))
                symbolLayer.textColor = NSExpression(forConstantValue: UIColor.darkGray)
                symbolLayer.textIgnoresPlacement = NSExpression(forConstantValue: true)
                symbolLayer.textAllowsOverlap = NSExpression(forConstantValue: true)
                symbolLayer.textFontNames = NSExpression(forConstantValue: ["Roboto Regular"])
                return symbolLayer
            }
            else {
                return customizedStyleLayer
            }
        }
    }
}
