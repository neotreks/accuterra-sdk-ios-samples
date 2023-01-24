//
//  ApkHereMapClass.swift
//  DemoApp
//
//  Created by Priyadarshi Bhattacharya on 2021-10-14.
//  Copyright © 2021 NeoTreks. All rights reserved.
//

import Foundation
import AccuTerraSDK

class ApkHereMapClass: HEREMapsRequestInterceptor {

    override func getApiKey() -> String {
        guard let hereAppCode = Bundle.main.infoDictionary?["HERE_API_KEY"] as? String else {
                fatalError("HERE_API_KEY is missing in info.plist")
            }
        return hereAppCode
    }
}
