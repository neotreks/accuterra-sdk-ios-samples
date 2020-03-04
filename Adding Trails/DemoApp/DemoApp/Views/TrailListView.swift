//
//  TrailListView.swift
//  DemoApp
//
//  Created by Rudolf Kopřiva on 20/12/2019.
//  Copyright © 2019 NeoTreks. All rights reserved.
//

import UIKit
import AccuTerraSDK

protocol TrailListViewDelegate : class {
    func didTapTrailInfo(basicInfo: TrailBasicInfo)
    func didTapTrailMap(basicInfo: TrailBasicInfo)
    func didSelectTrail(basicInfo: TrailBasicInfo)
    func toggleTrailListPosition()
    
    // For filtering purpose
    func getVisibleMapCenter() -> MapLocation
    var trailsFilter: TrailsFilter { get }
}

class TrailListView: UIView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var listButton: UIButton!
    
    var cellIdentifier="TrailInfoCell"
    var cellXibName = "TrailListTableviewCell"
    
    var trailsService: ITrailService?
    
    weak var delegate: TrailListViewDelegate?
    
    var trails: Array<TrailBasicInfo>?
    
    private var selectedTrailId: Int64?
    
    func loadTrails() {
        tableView.register(UINib(nibName: cellXibName, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        guard let delegate = self.delegate else {
            debugPrint("TrailListView delegate not set")
            return
        }
        guard SdkManager.shared.isTrailDbInitialized else {
            return
        }
        let filter = delegate.trailsFilter
        // Note: when searching by name, we disable other filters
        let hasTrailNameFilter = filter.trailNameFilter != nil
        do {
            if self.trailsService == nil {
                trailsService = ServiceFactory.getTrailService()
            }
            
            var techRatingSearchCriteria: TechRatingSearchCriteria?
            if let maxDifficultyLevel = filter.maxDifficulty?.level, !hasTrailNameFilter {
                techRatingSearchCriteria = TechRatingSearchCriteria(
                    level: maxDifficultyLevel,
                    comparison: Comparison.lessEquals)
            }
            
            var userRatingSearchCriteria: UserRatingSearchCriteria?
            if let minUserRating = filter.minUserRating, !hasTrailNameFilter {
                userRatingSearchCriteria = UserRatingSearchCriteria(
                    userRating: Double(minUserRating),
                    comparison: .greaterEquals)
            }
            
            var lengthSearchCriteria: LengthSearchCriteria?
            if let maxTripDistance = filter.maxTripDistance, !hasTrailNameFilter{
                lengthSearchCriteria = LengthSearchCriteria(length: Double(maxTripDistance))
            }
            
            if let mapBounds = filter.boundingBoxFilter, !hasTrailNameFilter {
                let searchCriteria = TrailMapBoundsSearchCriteria(
                    mapBounds: mapBounds,
                    nameSearchString: nil,
                    techRating: techRatingSearchCriteria,
                    userRating: userRatingSearchCriteria,
                    length: lengthSearchCriteria,
                    orderBy: OrderBy(),
                    limit: Int(INT32_MAX))
                self.trails = try trailsService!.findTrails(byMapBoundsCriteria: searchCriteria)
                self.tableView.reloadData()
            } else {
                let searchCriteria = TrailMapSearchCriteria(
                    mapCenter: delegate.getVisibleMapCenter(),
                    nameSearchString: filter.trailNameFilter,
                    techRating: techRatingSearchCriteria,
                    userRating: userRatingSearchCriteria,
                    length: lengthSearchCriteria,
                    orderBy: OrderBy(),
                    limit: Int(INT32_MAX))
                self.trails = try trailsService!.findTrails(byMapCriteria: searchCriteria)
                self.tableView.reloadData()
            }
            self.selectTrail(trailId: self.selectedTrailId)
        }
        catch {
            debugPrint("\(error)")
        }
    }
    
    func selectTrail(trailId: Int64?) {
        self.selectedTrailId = trailId
        guard let trailId = trailId else {
            self.tableView.selectRow(at: nil, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            return
        }
        if let trails = self.trails, let index = trails.firstIndex(where: { (t) -> Bool in
            return t.id == trailId
        }) {
            self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: UITableView.ScrollPosition.none)
        }
    }

    @IBAction func didTapOnListShow(_ sender: Any) {
        delegate?.toggleTrailListPosition()
    }
}

extension TrailListView : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell :TrailListTableviewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TrailListTableviewCell
        if let trails = trails {
            var userRatingsContainer = UserRatingContainer(one: cell.ratingStarOne, two: cell.ratingStarTwo, three: cell.ratingStarThree, four: cell.ratingStarFour, five:cell.ratingStarFive)
            TrailInfoDisplay.setDisplayFieldValues(trailTitleLabel: &cell.trailTitle, descriptionLabel:&cell.trailDescription, distanceLabel: &cell.trailDistanceLabel, userRatings: &userRatingsContainer, difficultyColorBar:&cell.difficultyColorBarLabel, basicTrailInfo: trails[indexPath.row])
            cell.trail = trails[indexPath.row]
        }
        cell.delegate = self.delegate
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let trails = self.trails else {
            return indexPath
        }
        self.delegate?.didSelectTrail(basicInfo: trails[indexPath.row])
        self.selectedTrailId = trails[indexPath.row].id
        return indexPath
    }
}

