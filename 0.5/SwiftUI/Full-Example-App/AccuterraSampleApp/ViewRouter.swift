//
//  ViewRouter.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/14/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

 import Foundation
 import Combine
 import SwiftUI

 class ViewRouter: ObservableObject {
    
     let objectWillChange = PassthroughSubject<ViewRouter,Never>()
     
     var currentPage: String = "download" {
         didSet {
             objectWillChange.send(self)
         }
     }
 }
