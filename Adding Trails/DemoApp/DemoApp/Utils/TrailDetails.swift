//
//  TrailDetails.swift
//  DemoApp
//
//  Created by Rudolf Kopřiva on 20/02/2020.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import Foundation
import AccuTerraSDK
import CoreLocation

///
/// Helper class for reading all available trail attributes
///
struct TrailDetails {
    
    var systemInfoValues: [(key: String, value: String)]
    var basicInfoValues: [(key: String, value: String)]
    var accessConcernsValues: [(key: String, value: String)]
    var surfaceTypeValues: [(key: String, value: String)]
    var tagValues: [(key: String, value: String)]
    var vehicleRequirementValues: [(key: String, value: String)]
    var accessInfoValues: [(key: String, value: String)]
    var closurePeriodsValues: [(key: String, value: String)]
    var locationInfoValues: [(key: String, value: String)]
    var navigationInfoValues: [(key: String, value: String)]
    var trailHeadValues: [(key: String, value: String)]
    var trailEndValues: [(key: String, value: String)]
    var statisticsValues: [(key: String, value: String)]
    var technicalRatingValues: [(key: String, value: String)]
    var userRatingValues: [(key: String, value: String)]
    var waypoints: [[(key: String, value: String)]]
    
    func getSection(sectionId: Int) -> (name: String, values: [(key: String, value: String)])? {
        switch sectionId {
        case 0:
            return ("System Info", systemInfoValues)
        case 1:
            return ("Basic Info", basicInfoValues)
        case 2:
            return ("Access Concerns", accessConcernsValues)
        case 3:
            return ("Surface Type", surfaceTypeValues)
        case 4:
            return ("Tags", tagValues)
        case 5:
            return ("Vehicle Requirements", vehicleRequirementValues)
        case 6:
            return ("Access Info", accessInfoValues)
        case 7:
            return ("Closure Periods", closurePeriodsValues)
        case 8:
            return ("Location Info", locationInfoValues)
        case 9:
            return ("Navigation Info", navigationInfoValues)
        case 10:
            return ("Trail Head", trailHeadValues)
        case 11:
            return ("Trail End", trailEndValues)
        case 12:
            return ("Statistics", statisticsValues)
        case 13:
            return ("Technical Rating", technicalRatingValues)
        case 14:
            return ("User Rating", userRatingValues)
        default:
            let waypointId = sectionId - 15
            if waypointId < waypoints.count - 1 {
                return ("Waypoint \(waypointId)", waypoints[waypointId])
            } else {
                return nil
            }
        }
    }
    
    init(trailId: Int64) {
        var systemInfoValues = [(key: String, value: String)]()
        var basicInfoValues = [(key: String, value: String)]()
        var accessConcernsValues = [(key: String, value: String)]()
        var surfaceTypeValues = [(key: String, value: String)]()
        var tagValues = [(key: String, value: String)]()
        var vehicleRequirementValues = [(key: String, value: String)]()
        var accessInfoValues = [(key: String, value: String)]()
        var closurePeriodsValues = [(key: String, value: String)]()
        var locationInfoValues = [(key: String, value: String)]()
        var navigationInfoValues = [(key: String, value: String)]()
        var trailHeadValues = [(key: String, value: String)]()
        var trailEndValues = [(key: String, value: String)]()
        var waypoints = [[(key: String, value: String)]]()
        var statisticsValues = [(key: String, value: String)]()
        var technicalRatingValues = [(key: String, value: String)]()
        var userRatingValues = [(key: String, value: String)]()
        
        let trailService = ServiceFactory.getTrailService()
        do {
            let trail = try trailService.getTrailById(trailId)
            
            // System Info
            if let sys = trail?.systemAttributes {
                systemInfoValues.append((key: "ID" , value: "\(sys.id)"))
                systemInfoValues.append((key: "DownloadState" , value: "\(sys.downloadState.rawValue)"))
            }
            
            // Basic Info
            if let basic = trail?.info {
                basicInfoValues.append((key: "Name", value: "\(basic.name)"))
                
                if let campingOptions = basic.campingOptions {
                    basicInfoValues.append((key: "Camping Options", value: campingOptions))
                }
                basicInfoValues.append((key: "Highlights", value: basic.highlights))
                if let history = basic.history {
                    basicInfoValues.append((key: "History", value: history))
                }
                if let shapeType = basic.shapeType {
                    basicInfoValues.append((key: "Shape Type Name", value: shapeType.name))
                    basicInfoValues.append((key: "Shape Type Code", value: shapeType.code))
                    if let desc = shapeType.description {
                        basicInfoValues.append((key: "Shape Type Description", value: desc))
                    }
                }
                if let status = basic.status {
                    basicInfoValues.append((key: "Status Name", value: status.name))
                    basicInfoValues.append((key: "Status Code", value: status.code))
                    if let desc = status.description {
                        basicInfoValues.append((key: "Status Description", value: desc))
                    }
                }
                
                // Access Concerns
                if let accessConcerns = basic.accessConcerns {
                    for i in 0..<accessConcerns.count {
                        accessConcernsValues.append((key: "Access Concern Name \(i)", value: "\(accessConcerns[i].name)"))
                        accessConcernsValues.append((key: "Access Concern Description \(i)", value: "\(accessConcerns[i].description ?? "")"))
                    }
                }
                
                // Surface Types
                if let surfaceTypes = basic.surfaceTypes {
                    for i in 0..<surfaceTypes.count {
                        surfaceTypeValues.append((key: "Surface Type Name \(i)", value: "\(surfaceTypes[i].name)"))
                        surfaceTypeValues.append((key: "Surface Type Code \(i)", value: "\(surfaceTypes[i].code)"))
                        if let desc = surfaceTypes[i].description {
                            surfaceTypeValues.append((key: "Surface Type Description \(i)", value: desc))
                        }
                    }
                }
                
                // Tags
                if let tags = basic.tags {
                    for i in 0..<tags.count {
                        tagValues.append((key: "Tag Name \(i)", value: "\(tags[i].name)"))
                        tagValues.append((key: "Tag Type \(i)", value: "\(tags[i].type.rawValue)"))
                        if let desc = tags[i].description {
                            tagValues.append((key: "Tag Description \(i)", value: desc))
                        }
                    }
                }
                
                // Vehicle Requirements
                if let requirements = basic.vehicleRequirements {
                    for i in 0..<requirements.count {
                        vehicleRequirementValues.append((key: "Vehicle Requirement Name \(i)", value: "\(requirements[i].name)"))
                        vehicleRequirementValues.append((key: "Vehicle Requirement Code \(i)", value: "\(requirements[i].code)"))
                        if let desc = requirements[i].description {
                            vehicleRequirementValues.append((key: "Vehicle Requirement Description \(i)", value: desc))
                        }
                    }
                }
            }
            
            // Access Info
            if let accessInfo = trail?.accessInfo {
                if let accessIssue = accessInfo.accessIssue {
                    accessInfoValues.append((key: "Access Issue", value: accessIssue))
                }
                if let accessIssueLink = accessInfo.accessIssueLink {
                    accessInfoValues.append((key: "Access Issue Link", value: accessIssueLink))
                }
                
                accessInfoValues.append((key: "Is Permit Required", value: accessInfo.isPermitRequired ? "YES" : "NO"))
                if let permiInfo = accessInfo.permitInformation {
                    accessInfoValues.append((key: "Permit Information", value: permiInfo))
                }
                if let permiInfoLink = accessInfo.permitInformationLink {
                    accessInfoValues.append((key: "Permit Information Link", value: permiInfoLink))
                }
                if let seasonalityRecommendation = accessInfo.seasonalityRecommendation {
                    accessInfoValues.append((key: "Seasonality Recommendation", value: seasonalityRecommendation))
                }
                if let seasonalityRecommendationReason = accessInfo.seasonalityRecommendationReason {
                    accessInfoValues.append((key: "Seasonality Recommendation Reason", value: seasonalityRecommendationReason))
                }
                
                // Closure Periods
                for i in 0..<accessInfo.closurePeriods.count {
                    if let name = accessInfo.closurePeriods[i].name {
                        closurePeriodsValues.append((key: "Closure Period \(i) Name", value: name))
                    }
                    closurePeriodsValues.append((key: "Closure Period \(i) From", value: "\(accessInfo.closurePeriods[i].fromDate)"))
                    closurePeriodsValues.append((key: "Closure Period \(i) To", value: "\(accessInfo.closurePeriods[i].toDate)"))
                }
            }
            
            
            // Location Info
            if let locationInfo = trail?.locationInfo {
                if let countryIso3Code = locationInfo.countryIso3Code {
                    locationInfoValues.append((key: "Country ISO3 Code", value: countryIso3Code))
                }
                if let countyName = locationInfo.countyName {
                    locationInfoValues.append((key: "Country Name", value: countyName))
                }
                if let districtName = locationInfo.districtName {
                    locationInfoValues.append((key: "Disctrict Name", value: districtName))
                }
                if let nearestTownName = locationInfo.nearestTownName {
                    locationInfoValues.append((key: "Nearest Town Name", value: nearestTownName))
                }
                if let stateCode = locationInfo.stateCode {
                    locationInfoValues.append((key: "State Code", value: stateCode))
                }
                if let usdaFsParkDistrict = locationInfo.usdaFsParkDistrict {
                    locationInfoValues.append((key: "USDA Fs Park District", value: usdaFsParkDistrict))
                }
                if let usdaFsRoadNumber = locationInfo.usdaFsRoadNumber {
                    locationInfoValues.append((key: "USDA Fs Road Number", value: usdaFsRoadNumber))
                }
            }
            
            
            // Navigation Info
            if let navigationInfo = trail?.navigationInfo {
                navigationInfoValues.append((key: "One Way", value: navigationInfo.isOneWay ? "YES" : "NO"))
                if let nearestTownWithServices = navigationInfo.nearestTownWithServicesName {
                    navigationInfoValues.append((key: "Nearest Town with Services", value: nearestTownWithServices))
                }
                if let officialRoadName = navigationInfo.officialRoadName {
                    navigationInfoValues.append((key: "Official Road Name", value: officialRoadName))
                }
                
                // Trail Head
                if let trailHead = navigationInfo.trailHead {
                    trailHeadValues.append(contentsOf: TrailDetails.mapPointValues(trailHead))
                }
                
                // Trail End
                if let trailEnd = navigationInfo.trailEnd {
                    trailEndValues.append(contentsOf: TrailDetails.mapPointValues(trailEnd))
                }
                
                // Waypoints
                navigationInfo.waypoints.forEach({ (waypoint) in
                    waypoints.append(TrailDetails.mapPointValues(waypoint))
                })
            }
            
            // Statistics
            if let statistics = trail?.statistics {
                statisticsValues.append((key: "Length", value: "\(statistics.length) meters"))
                statisticsValues.append((key: "Highest Elevation", value: "\(statistics.highestElevation) meters"))
                statisticsValues.append((key: "Avg Estimated Duration", value: "\(statistics.estimatedDurationAvg) seconds"))
                if let estDriveTime = statistics.estimatedDriveTimeMin {
                    statisticsValues.append((key: "Estimated Drive Time", value: "\(estDriveTime) seconds"))
                }
            }
            
            // Technical Rating
            if let technicalRating = trail?.technicalRating {
                technicalRatingValues.append((key: "High Rating Name" , value: technicalRating.high.name))
                technicalRatingValues.append((key: "High Rating Code" , value: technicalRating.high.code))
                technicalRatingValues.append((key: "High Rating Level" , value: "\(technicalRating.high.level)"))
                if let highRatingDesc = technicalRating.high.description {
                    technicalRatingValues.append((key: "High Rating Description" , value: highRatingDesc))
                }
                
                technicalRatingValues.append((key: "Low Rating Name" , value: technicalRating.low.name))
                technicalRatingValues.append((key: "Low Rating Code" , value: technicalRating.low.code))
                technicalRatingValues.append((key: "Low Rating Level" , value: "\(technicalRating.low.level)"))
                if let lowRatingDesc = technicalRating.low.description {
                    technicalRatingValues.append((key: "Low Rating Description" , value: lowRatingDesc))
                }
                
                if let summary = technicalRating.summary {
                    technicalRatingValues.append((key: "Summary" , value: summary))
                }
            }
            
            // User Rating
            if let userRating = trail?.userRating {
                userRatingValues.append((key: "Rating", value: "\(userRating.rating)"))
                userRatingValues.append((key: "Count", value: "\(userRating.ratingCount)"))
            }
            
        } catch {
            debugPrint("\(error)")
        }
        
        self.systemInfoValues = systemInfoValues
        self.accessConcernsValues = accessConcernsValues
        self.surfaceTypeValues = surfaceTypeValues
        self.tagValues = tagValues
        self.vehicleRequirementValues = vehicleRequirementValues
        self.basicInfoValues = basicInfoValues
        self.accessInfoValues = accessInfoValues
        self.closurePeriodsValues = closurePeriodsValues
        self.locationInfoValues = locationInfoValues
        self.navigationInfoValues = navigationInfoValues
        self.trailHeadValues = trailHeadValues
        self.trailEndValues = trailEndValues
        self.waypoints = waypoints
        self.statisticsValues = statisticsValues
        self.technicalRatingValues = technicalRatingValues
        self.userRatingValues = userRatingValues
    }
    
    static func locationValues(_ location: MapLocation) -> [(key: String, value: String)] {
        var values = [(key: String, value: String)]()
        values.append((key: "Latitude", value: "\(location.latitude)"))
        values.append((key: "Longitude", value: "\(location.longitude)"))
        if let altitude = location.altitude {
            values.append((key: "Altitude", value: "\(altitude)"))
        }
        return values
    }
    
    static func mapPointValues(_ mapPoint: MapPoint) -> [(key: String, value: String)] {
        var values = [(key: String, value: String)]()
        
        if let name = mapPoint.name {
            values.append((key: "Name", value: name))
        }
        if let desc = mapPoint.description {
            values.append((key: "Description", value: desc))
        }
        if let distanceMarker = mapPoint.distanceMarker {
            values.append((key: "Distance Marker", value: "\(distanceMarker) meters"))
        }
        values.append((key: "Is Waypoint", value: mapPoint.isWaypoint ? "YES" : "NO"))
        values.append((key: "Type Name", value: mapPoint.type.name))
        values.append((key: "Type Code", value: mapPoint.type.code))
        if let typeDescription = mapPoint.type.description {
            values.append((key: "Type Description", value: typeDescription))
        }
        values.append((key: "Sub Type Name", value: mapPoint.subType.name))
        values.append((key: "Sub Type Code", value: mapPoint.subType.code))
        values.append((key: "Sub Type Parent Code", value: mapPoint.subType.parentTypeCode))
        if let subTypeDescription = mapPoint.subType.description {
            values.append((key: "Sub Type Description", value: subTypeDescription))
        }
        
        if let navigationOrder = mapPoint.navigationOrder {
            values.append((key: "Navigation Order", value: "\(navigationOrder)"))
        }
        values.append(contentsOf: TrailDetails.locationValues(mapPoint.location))
        
        return values
    }
}
