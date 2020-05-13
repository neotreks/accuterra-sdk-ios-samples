//
//  Filter-to-MapViewController.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/20/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import UIKit
import AccuTerraSDK

class Filter_MapBoundsViewController: BaseViewController {

    @IBOutlet weak var maxDifficultySlider: UISlider!
    @IBOutlet weak var maxDifficultyValueLabel: UILabel!
    @IBOutlet weak var minUserRatingSlider: UISlider!
    @IBOutlet weak var maxDistanceSlider: UISlider!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var maxDistanceValueLabel: UILabel!
    @IBOutlet weak var minUserRatingValueLabel: UILabel!
    @IBOutlet weak var trailNameTextField: UITextField!
    @IBOutlet weak var mapBoundsSegController: UISegmentedControl!

    let cellReuseIdentifier: String = "TrailCell"
    var isTrailsLayerManagersLoaded = false
    var mapWasLoaded : Bool = false
    var trailsFilter = TrailsFilter()
    var trailsService: ITrailService?
    var trails: Array<TrailBasicInfo>?
    let boundsColorado = try! MapBounds( minLat: 37.99906, minLon: -109.04265, maxLat: 41.00097, maxLon: -102.04607)
    let boundsUSA = try! MapBounds(      minLat: 25.79467, minLon: -125.32188, maxLat: 48.90785, maxLon:  -66.23966)
    
    //MARK: Filter Crieria Properties & Methods
    
    private var tripDistances = [5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 100,
    120, 150, 200, 250, 300, 400, 500, 600, 700, 800, 900, 1000]
    
    private lazy var difficultyLevels = [TechnicalRating]()
    private let MAX_STARS = 5
    
    private var mapBounds:MapBounds {
        get {
            return mapBoundsSegController.selectedSegmentIndex == 0 ? boundsColorado: boundsUSA
        }
    }
    
    private var maxDifficultyLevel: TechnicalRating? {
        get {
            return getDifficultyLevelFromProgress(progress: self.maxDifficultySlider.value)
        }
        set {
            self.maxDifficultySlider.value = getProgressFromDifficulty(trailDifficulty: newValue)
            self.refreshDifficultyLabel(difficultyLevel: newValue)
        }
    }
    private var minUserRatings: Int? {
        get {
            return getStarsFromProgress(progress: minUserRatingSlider.value)
        }
        set {
            minUserRatingSlider.value = getProgressFromStars(starsCount: newValue)
            refreshUserRatingLabel(starsCount: newValue)
        }
    }
    private var maxDistance: Int? {
        get {
            return getTripDistanceFromProgress(progress: maxDistanceSlider.value)
        }
        set {
            maxDistanceSlider.value = getProgressFromTripDistance(tripDistance: newValue)
            refreshTripDistanceLabel(tripDistance: newValue)
        }
    }
    
    private func initDifficultySlider() {
        // min = 0
        maxDifficultySlider.maximumValue = Float(difficultyLevels.count)
        maxDifficultySlider.value = getProgressFromDifficulty(trailDifficulty: nil)

        refreshDifficultyLabel()
    }
    
    private func initUserRatingSlider() {
        // min = 0
        minUserRatingSlider.maximumValue = Float(MAX_STARS)
        minUserRatingSlider.value = getProgressFromStars(starsCount: nil)

        refreshUserRatingLabel()
    }
    
    private func initTripDistanceSlider() {
        // min = 0
        maxDistanceSlider.maximumValue = Float(tripDistances.count)
        maxDistanceSlider.value = getProgressFromTripDistance(tripDistance: nil)

        refreshTripDistanceLabel()
    }
    
    private func refreshDifficultyLabel() {
        refreshDifficultyLabel(difficultyLevel: maxDifficultyLevel)
    }
    
    private func refreshDifficultyLabel(difficultyLevel: TechnicalRating?) {
        if let difficultyLevel = maxDifficultyLevel {
            maxDifficultyValueLabel.text = difficultyLevel.name
        } else {
            maxDifficultyValueLabel.text = "Any"
        }
    }
    
    private func refreshUserRatingLabel() {
        refreshUserRatingLabel(starsCount: minUserRatings)
    }

    private func refreshUserRatingLabel(starsCount: Int?) {
        if let starsCount = starsCount {
            if starsCount == 1 {
                minUserRatingValueLabel.text =  "\(starsCount) star"
            } else {
                minUserRatingValueLabel.text = "\(starsCount) stars"
            }
        } else {
            minUserRatingValueLabel.text = "Any"
        }
    }
    
    private func refreshTripDistanceLabel() {
        refreshTripDistanceLabel(tripDistance: maxDistance)
    }

    private func refreshTripDistanceLabel(tripDistance: Int?) {
        if let tripDistance = tripDistance {
            maxDistanceValueLabel.text = "\(tripDistance) mi"
        } else {
            maxDistanceValueLabel.text = "Any"
        }
    }
    
    private func getDifficultyLevelFromProgress(progress: Float) -> TechnicalRating? {
        if (Int(progress) < difficultyLevels.count) {
            return difficultyLevels[Int(progress)]
        } else {
            return nil
        }
    }
    
    private func getProgressFromDifficulty(trailDifficulty: TechnicalRating?) -> Float {
        if let trailDifficulty = trailDifficulty {
            let index = difficultyLevels.firstIndex { (difficulty) -> Bool in
                return difficulty.level == trailDifficulty.level
            }
            return Float(index ?? 0)
        } else {
            return Float(difficultyLevels.count)
        }
    }
    
    private func getStarsFromProgress(progress: Float) -> Int? {
        if (Int(progress) == MAX_STARS) {
            return nil
        } else {
            return MAX_STARS - Int(progress)
        }
    }
    
    private func getProgressFromStars(starsCount: Int?) -> Float {
        if let starsCount = starsCount, starsCount >= 1, starsCount <= MAX_STARS {
            return Float(MAX_STARS - starsCount)
        } else {
            return Float(MAX_STARS)
        }
    }
    
    private func getProgressFromTripDistance(tripDistance: Int?) -> Float {
        if let tripDistance = tripDistance {
            let index = tripDistances.firstIndex(of: tripDistance)
            return Float(index ?? 0)
        } else {
            return Float(tripDistances.count)
        }
    }
    
    private func getTripDistanceFromProgress(progress: Float) -> Int? {
        if (Int(progress) < tripDistances.count) {
            return tripDistances[Int(progress)]
        } else {
            return nil
        }
    }
    
    //MARK: Control Interactions
    
    @IBAction func didTapApplyButton() {
        trailNameTextField.resignFirstResponder()
        searchTrails()
    }
    @IBAction func didTapClearButton(_ sender: Any) {
        trailNameTextField.resignFirstResponder()
        clearFiters()
    }
    
    @IBAction func maxDifficultyValueChanged() {
        let newDifficulty = getDifficultyLevelFromProgress(progress: maxDifficultySlider.value)
        refreshDifficultyLabel(difficultyLevel: newDifficulty)
        self.trailsFilter.maxDifficulty = newDifficulty
    }
    
    @IBAction func minUseRatingValueChanged() {
        let newRating = getStarsFromProgress(progress: minUserRatingSlider.value)
        refreshUserRatingLabel(starsCount: newRating)
        self.trailsFilter.minUserRating = newRating
    }
    
    @IBAction func maxDistanceValueChanged() {
        let newTripDistance = getTripDistanceFromProgress(progress: maxDistanceSlider.value)
        refreshTripDistanceLabel(tripDistance: newTripDistance)
        self.trailsFilter.maxTripDistance = newTripDistance
    }
    
    @IBAction func mapBoundsValueChanged() {
        self.trailsFilter.boundingBoxFilter = mapBounds
    }
    
    //MARK: View Controller Lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EnumUtil.cacheEnums()
        
        self.difficultyLevels = EnumUtil.getTechRatings()
        clearFiters()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    
    //MARK: Filter Query Methods
    
    func searchTrails() {
        
        guard SdkManager.shared.isTrailDbInitialized else {
            return
        }
        
        do {
        
            if self.trailsService == nil {
                trailsService = ServiceFactory.getTrailService()
            }
            
            trailsFilter.trailNameFilter = trailNameTextField.text
            
            var techRatingSearchCriteria: TechRatingSearchCriteria?
            if let maxDifficultyLevel = trailsFilter.maxDifficulty?.level {
                techRatingSearchCriteria = TechRatingSearchCriteria(
                    level: maxDifficultyLevel,
                    comparison: Comparison.lessEquals)
            }
            
            var userRatingSearchCriteria: UserRatingSearchCriteria?
            if let minUserRating = trailsFilter.minUserRating {
                userRatingSearchCriteria = UserRatingSearchCriteria(
                    userRating: Double(minUserRating),
                    comparison: .greaterEquals)
            }
            
            var lengthSearchCriteria: LengthSearchCriteria?
            if let maxTripDistance = trailsFilter.maxTripDistance {
                lengthSearchCriteria = LengthSearchCriteria(length: Double(maxTripDistance))
            }
            
            let searchCriteria = TrailMapBoundsSearchCriteria(
                mapBounds: trailsFilter.boundingBoxFilter ?? boundsColorado,
                nameSearchString: trailsFilter.trailNameFilter,
                techRating: techRatingSearchCriteria,
                userRating: userRatingSearchCriteria,
                length: lengthSearchCriteria,
                orderBy: OrderBy(),
                limit: Int(INT32_MAX))
            trails = try trailsService!.findTrails(byMapBoundsCriteria: searchCriteria)
            if let results = trails {
                if results.count > 0 {
                    self.tableView.reloadData()
                }
                else {
                    self.showAlert(title: "Search Results", message: "No Trails Found")
                }
            }

        } catch {
            debugPrint("\(error)")
        }
    }
    
    func clearFiters() {
        initDifficultySlider()
        initUserRatingSlider()
        initTripDistanceSlider()
        searchTrails()
        trailNameTextField.text = nil
        searchTrails()
    }
    
    public func distanceKilometersToMiles(kilometers: Double) -> String {
        return String(format: "%.1f mi", kilometers * 0.621371)
    }

}

extension Filter_MapBoundsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FilterResultsTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! FilterResultsTableViewCell
        cell.trailNameLabel.text = self.trails?[indexPath.row].name

        if let difficulty = self.trails?[indexPath.row].techRatingHigh {
            cell.techDifficultyValue.text = difficulty.name
        }
        else {
           cell.techDifficultyValue.text  = "UNKNOWN"
        }
        
        if let userRating = self.trails?[indexPath.row].userRating?.rating {
            cell.userRatingValue.text = String(format: "%.1f", Double(round(userRating * 10) / 10))
        }
        else {
            cell.userRatingValue.text = "*"
        }
        
        if let trailDistance = self.trails?[indexPath.row].length {
            cell.trailLengthValue.text = self.distanceKilometersToMiles(kilometers: trailDistance)
        }
        else {
            cell.trailLengthValue.text = "-- mi"
        }
        
        if let distanceAway = self.trails?[indexPath.row].distance {
            cell.distanceAwayValue.text = self.distanceKilometersToMiles(kilometers: distanceAway)
        }
        else {
            cell.distanceAwayValue.text = "-- mi"
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
