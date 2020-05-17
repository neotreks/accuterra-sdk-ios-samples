//
//  FilteringMap.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/17/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI
import AccuTerraSDK
import Mapbox
import Combine

struct FilteringMap: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var env: AppEnvironment
    @ObservedObject var vm = FilterViewModel()
    @State var toggleValue = false
    @State var trailName = ""
    @State private var mapCenterSelection = 0
    var centerOptions = ["Telluride", "Aspen"]
    @State private var difficulty:Float = 5
    @State private var difficultyLabel:String = "Any"
    @State private var userRating:Float = 5
    @State private var userRatingLabel:String = "Any"
    @State private var tripDistance:Float = 100
    @State private var tripDistanceLabel:String = "Any"
    var minimumValue:Float = 0.0
    var maximumvalue:Float = 100.0
    let reversedUserRatings = [5,4,3,2,1,0]
    
    private lazy var difficultyLevels = [TechnicalRating]()
    private let MAX_STARS = 6
    private let MAX_DISTANCE = 100
    private var difficultyCount = 0
    
    private mutating func getDifficultyLabel(progress:Float) -> String {
        if (Int(progress) < difficultyLevels.count) {
            return difficultyLevels[Int(progress)].name
        } else {
            return "Any"
        }
    }
    private mutating func getStarsFromProgress(progress: Float) -> Int? {
        if (Int(progress) == MAX_STARS) {
            return nil
        } else {
            return MAX_STARS - Int(progress)
        }
    }
    
    private func clear() {
        self.vm.resetTrails()
        self.difficulty = 5
        self.userRating = 5
        self.tripDistance = 100
        self.mapCenterSelection = 0
        self.difficultyLabel = "Any"
        self.userRatingLabel = "Any"
        self.tripDistanceLabel = "Any"
        self.trailName = ""
        UIApplication.shared.endEditing() // Call to dismiss keyboard
    }
        
    init() {
        EnumUtil.cacheEnums()
        difficultyLevels = EnumUtil.getTechRatings()
        difficultyCount = difficultyLevels.count
        clearFiters()
    }
    
    private func clearFiters() {
        let diffValues = self.getDifficultyArray
        difficulty = Float(diffValues().count)
        userRating = Float(MAX_STARS)
        tripDistance = Float(MAX_DISTANCE)
    }
    
    private func getDifficultyArray() -> [TechnicalRating] {
        var mutatableSelf = self
        return mutatableSelf.difficultyLevels
    }
    
    private func getMapCenter() -> MapLocation {
        if self.centerOptions[mapCenterSelection] == "Telluride" {
            return vm.getTellurideLocation()
        }
        else {
            return vm.getAspenLocation()
        }
    }

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Filters")
                    Spacer()
                }
                .padding(7)
                .background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255))
                VStack {
                    HStack {
                        Text("Trail Name").bold()
                        Divider()
                        TextField("Search", text: self.$trailName)
                    }
                    .padding(.top, 5)
                    VStack {
                        Text("Map Center")
                            .padding(.top, 10)
                        Picker(selection: self.$mapCenterSelection, label: Text("Map Center?")) {
                            ForEach(0..<self.centerOptions.count) { index in
                                Text(self.centerOptions[index]).tag(index)
                            }
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.bottom, 10)
                    VStack {
                        VStack {
                            HStack {
                                Text("Maximum Difficulty")
                                    .bold()
                                Spacer()
                                Text("\(difficultyLabel)")
                            }
                            Slider(value: $difficulty, in: 0...Float(difficultyCount), onEditingChanged: { _ in
                                    let diffValues = self.getDifficultyArray
                                    let count = diffValues().count
                                    if (Int(self.difficulty) < count) {
                                        self.difficultyLabel = diffValues()[Int(self.difficulty)].name
                                    } else {
                                        self.difficultyLabel = "Any"
                                    }
                                })
                        }
                        VStack {
                            HStack {
                                Text("Minumum User Rating")
                                    .bold()
                                Spacer()
                                Text("\(userRatingLabel)")
                            }
                            Slider(value: $userRating, in: 0...Float(MAX_STARS)-1, onEditingChanged: { _ in
                                let count = Int(self.userRating)
                                if count >= 0 && count <= self.MAX_STARS {
                                    let starsCount = self.reversedUserRatings[count]
                                    if starsCount == 1 {
                                        self.userRatingLabel =  "\(starsCount) star"
                                    }
                                    else if starsCount >= 2 {
                                        self.userRatingLabel = "\(starsCount) stars"
                                    }
                                    else {
                                        self.userRatingLabel = "Any"
                                    }
                                }
                            })
                        }
                        VStack {
                            HStack {
                                Text("Maximum Trip Distance")
                                    .bold()
                                Spacer()
                                Text("\(tripDistanceLabel)")
                            }
                            Slider(value:$tripDistance, in: 5...Float(MAX_DISTANCE), step: 5, onEditingChanged: { _ in
                                if (Int(self.tripDistance) < self.MAX_DISTANCE) {
                                    self.tripDistanceLabel = String("\(self.tripDistance) mi")
                                } else {
                                    self.tripDistanceLabel = "Any"
                                }
                            })
                        }
                        HStack {
                            Spacer()
                            Button(action: {
                                print("Apply")
                                self.vm.searchTrails(trailName: self.trailName, difficultyLevel: Int(self.difficulty), minUserRating: self.reversedUserRatings[Int(self.userRating)], maxTripDistance: Int(self.tripDistance), mapCenter: self.getMapCenter())
                             }) {
                                 Text("Apply Filters")
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(Color.white)
                                .cornerRadius(5)
                                .frame(height: 44)
                            }
                            Spacer()
                            Button(action: {
                                self.clear()
                             }) {
                                Text("Clear")
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                .padding(.bottom, 10)
                Spacer()
            }
            .frame(height: 450)
            .padding(.top, 10)

            HStack {
                Text("Trails")
                Spacer()
            }
            .padding(7)
            .background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255))
            Spacer()
        }
        .navigationBarTitle(Text("Filter Map"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.env.mapIntEnv.resetEnv()
                self.mode.wrappedValue.dismiss()
            }){
                Image(systemName: "arrow.left")
            })
    }
}

struct FilteringMap_Previews: PreviewProvider {
    static var previews: some View {
        return FilteringMap()
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
