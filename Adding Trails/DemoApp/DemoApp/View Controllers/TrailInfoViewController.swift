//
//  TrailInfoView.swift
//  DemoApp
//
//  Created by Rudolf Kopřiva on 20/12/2019.
//  Copyright © 2019 NeoTreks. All rights reserved.
//

import UIKit
import AccuTerraSDK

protocol TrailInfoViewDelegate: class {
    func didTapTrailInfoBackButton()
}

class TrailInfoViewController: UIViewController {
    
    @IBOutlet weak var trailTitleLabel: UILabel!
    @IBOutlet weak var trailDescriptionTextView: UITextView!
    @IBOutlet weak var trailDistanceLabel: UILabel!
    @IBOutlet weak var trailRatingValueLabel: UILabel!
    @IBOutlet weak var trailUserRatingCountLabel: UILabel!
    @IBOutlet weak var trailUserRatingStarOne: UIImageView!
    @IBOutlet weak var trailUserRatingStarTwo: UIImageView!
    @IBOutlet weak var trailUserRatingStarThree: UIImageView!
    @IBOutlet weak var trailUserRatingStarFour: UIImageView!
    @IBOutlet weak var trailUserRatingStarFive: UIImageView!
    @IBOutlet weak var difficultyLabel: UILabel!
    
    @IBOutlet weak var getThereButton: UIButton!
    @IBOutlet weak var savedButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var startNavigationButton: UIButton!
    
    @IBOutlet weak var trailDetailsTableView: UITableView!
    
    @IBOutlet weak var trailDescriptionButton: UIButton!
    @IBOutlet weak var trailDetailsButton: UIButton!
    @IBOutlet weak var trailForecastButton: UIButton!
    @IBOutlet weak var trailReviewButton: UIButton!
    
    weak var delegate: TrailInfoViewDelegate?
    
    var basicTrailInfo: TrailBasicInfo?
    
    var trailDetails: TrailDetails?
    
    enum ViewState {
        case description
        case details
        case forecast
        case reviews
    }
    
    var viewState: ViewState = .description
    
    override func viewDidLoad() {
                
        getThereButton.imageView?.image = UIImage.getThereImage
        TrailInfoDisplay.centerButtonImageAndTitle(button: getThereButton, tileOffset: 0, imageOffset: -18)
        
        savedButton.imageView?.image = UIImage.bookmarkImage
        TrailInfoDisplay.centerButtonImageAndTitle(button: savedButton, tileOffset: 0, imageOffset:-13)
        
        downloadButton.imageView?.image = UIImage.downloadImage
        TrailInfoDisplay.centerButtonImageAndTitle(button: downloadButton, tileOffset: 0, imageOffset: -10)
        
        startNavigationButton.imageView?.image = UIImage.startNavigationImage
        TrailInfoDisplay.centerButtonImageAndTitle(button: startNavigationButton, tileOffset: -3, imageOffset: -5)
        
        var userRatingsContainer = UserRatingContainer(one: trailUserRatingStarOne, two: trailUserRatingStarTwo, three: trailUserRatingStarThree, four: trailUserRatingStarFour, five:trailUserRatingStarFive)
        TrailInfoDisplay.setDisplayFieldValues(trailTitleLabel: &trailTitleLabel, descriptionTextView: &trailDescriptionTextView, distanceLabel: &trailDistanceLabel, userRatings: &userRatingsContainer, userRatingCountLabel: &trailUserRatingCountLabel, userRatingValueLabel: &trailRatingValueLabel, difficultyLabel: &difficultyLabel, basicTrailInfo: basicTrailInfo)
    }
    
    @IBAction func didTapDownload(_ sender: Any) {
    }
    
    @IBAction func didTapSaved(_ sender: Any) {
    }
    
    @IBAction func didTapGetThere(_ sender: Any) {
    }
    
    @IBAction func didTapStartNavigation(_ sender: Any) {
        print("Start navigation tapped")
    }
    
    @IBAction func didTapTrailDescription() {
        setViewState(.description)
    }
    
    @IBAction func didTapTrailDetails() {
        setViewState(.details)
    }
    
    @IBAction func didTapTrailForecast() {
        setViewState(.forecast)
    }
    
    @IBAction func didTapTrailReviews() {
        setViewState(.reviews)
    }
    
    @IBAction func didTapBackButton() {
        self.delegate?.didTapTrailInfoBackButton()
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        if parent == self.navigationController?.parent {
            self.delegate?.didTapTrailInfoBackButton()
            print("Back tapped")
        }
    }
    
    private func setViewState(_ newViewState: ViewState) {
        self.trailDescriptionButton.isSelected = false
        self.trailDescriptionTextView.isHidden = true
        self.trailDetailsButton.isSelected = false
        self.trailDetailsTableView.isHidden = true
        self.trailForecastButton.isSelected = false
        self.trailReviewButton.isSelected = false
        
        switch newViewState {
        case .description:
            self.trailDescriptionButton.isSelected = true
            self.trailDescriptionTextView.isHidden = false
        case .details:
            self.trailDetailsButton.isSelected = true
            self.trailDetailsTableView.isHidden = false
            self.trailDetailsTableView.delegate = self
            self.trailDetailsTableView.dataSource = self
            
            if let trailId = self.basicTrailInfo?.id {
                if self.trailDetails == nil {
                    self.trailDetails = TrailDetails(trailId: trailId)
                }
            }
            
            self.trailDetailsTableView.reloadData()
        case .forecast:
            self.trailForecastButton.isSelected = true
        case .reviews:
            self.trailReviewButton.isSelected = true
        }
        self.viewState = newViewState
    }
}

extension TrailInfoViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let trailDetails = self.trailDetails else {
            return 0
        }
        return 15 + trailDetails.waypoints.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let trailDetails = self.trailDetails else {
            return 0
        }
        if let section = trailDetails.getSection(sectionId: section) {
            if section.values.count == 0 {
                return 1 // Show Empty Section note
            } else {
                return section.values.count
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let trailDetails = self.trailDetails, let section = trailDetails.getSection(sectionId: section) {
            return section.name
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        if let trailDetails = self.trailDetails, let section = trailDetails.getSection(sectionId: indexPath.section) {
            if section.values.count == 0 {
                cell.textLabel?.text = "No information is available"
            } else {
                cell.textLabel?.text = section.values[indexPath.row].key
                var value = section.values[indexPath.row].value
                if value.count == 0 {
                    value = "N/A"
                }
                cell.detailTextLabel?.text = value
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let trailDetails = self.trailDetails, let section = trailDetails.getSection(sectionId: indexPath.section) {
            if section.values.count > 0 {
                let key = section.values[indexPath.row].key
                let value = section.values[indexPath.row].value
                if value.count > 0 {
                    let alert = UIAlertController(title: key, message: value, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
        return nil
    }
    
    
}
