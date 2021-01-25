//
//  ViewRouter.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/21/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class ViewRouter: ObservableObject {
    @Published var currentPage = "download"
    @Published var searchFilers = SearchFilters()
}
