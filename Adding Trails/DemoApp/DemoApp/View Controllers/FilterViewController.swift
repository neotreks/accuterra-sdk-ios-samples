//
//  FilterViewController.swift
//  DemoApp
//
//  Created by Rudolf Kopřiva on 27/02/2020.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import Foundation
import UIKit
import AccuTerraSDK

protocol FilterViewControllerDelegate: class {
    func applyFilter(trailsFilter: TrailsFilter)
}

class FilterViewController : UIViewController {
    @IBOutlet private weak var maxDifficultySlider: UISlider!
    @IBOutlet private weak var maxDifficultyValueLabel: UILabel!
    @IBOutlet private weak var minUserRatingSlider: UISlider!
    @IBOutlet private weak var minUserRatingValueLabel: UILabel!
    @IBOutlet private weak var maxDistanceSlider: UISlider!
    @IBOutlet private weak var maxDistanceValueLabel: UILabel!
    
    private var tripDistances = [5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 100,
    120, 150, 200, 250, 300, 400, 500, 600, 700, 800, 900, 1000]
    
    private lazy var difficultyLevels = [TechnicalRating]()
    
    private let MAX_STARS = 5
    
    weak var delegate: FilterViewControllerDelegate?
    
    private var trailsFilter: TrailsFilter?
    
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
    
    func initialize(trailsFilter: TrailsFilter) {
        self.trailsFilter = trailsFilter
        
        self.maxDifficultyLevel = trailsFilter.maxDifficulty
        self.minUserRatings = trailsFilter.minUserRating
        self.maxDistance = trailsFilter.maxTripDistance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.difficultyLevels = EnumUtil.getTechRatings()
        initDifficultySlider()
        initUserRatingSlider()
        initTripDistanceSlider()
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
    
    @IBAction func didTapOkButton() {
        self.dismiss(animated: true) {
            if let trailsFilter = self.trailsFilter {
                self.delegate?.applyFilter(trailsFilter: trailsFilter)
            }
        }
    }
    
    @IBAction func maxDifficultyValueChanged() {
        let newDifficulty = getDifficultyLevelFromProgress(progress: maxDifficultySlider.value)
        refreshDifficultyLabel(difficultyLevel: newDifficulty)
        self.trailsFilter?.maxDifficulty = newDifficulty
    }
    
    @IBAction func minUseRatingValueChanged() {
        let newRating = getStarsFromProgress(progress: minUserRatingSlider.value)
        refreshUserRatingLabel(starsCount: newRating)
        self.trailsFilter?.minUserRating = newRating
    }
    
    @IBAction func maxDistanceValueChanged() {
        let newTripDistance = getTripDistanceFromProgress(progress: maxDistanceSlider.value)
        refreshTripDistanceLabel(tripDistance: newTripDistance)
        self.trailsFilter?.maxTripDistance = newTripDistance
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
