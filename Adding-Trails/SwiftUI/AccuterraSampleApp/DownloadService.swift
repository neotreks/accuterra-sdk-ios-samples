//
//  DownloadService.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/19/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import Foundation
import AccuTerraSDK

class DownloadService {
    
    func downloadTrails(delegate: SdkInitDelegate) {
        guard let clientToken = Bundle.main.infoDictionary?["AccuTerraClientToken"] as? String,
            let serviceUrl = Bundle.main.infoDictionary?["AccuTerraServiceUrl"] as? String else {
                fatalError("AccuTerraClientToken and AccuTerraServiceUrl is missing in info.plist")
        }
        SdkManager.shared.initSdkAsync(config: SdkConfig(clientToken: clientToken, wsUrl: serviceUrl), delegate: delegate)
    }
}
