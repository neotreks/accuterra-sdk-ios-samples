//
//  DemoAccessManager.swift
//  AccuterraSampleAppUIKit
//
//  Created by Rudolf Kopřiva on 14.01.2021.
//

import Foundation
import ObjectMapper
import AccuTerraSDK
import Alamofire

/**
* Class for managing access to AccuTerra services
*/
class DemoAccessManager : IAccessProvider, IIdentityProvider {
    
    let clientCredentials: ClientCredentials
    
    public static var shared: DemoAccessManager = {
        return DemoAccessManager()
    }()
    
    private init() {
        guard let clientId = Bundle.main.infoDictionary?["WS_AUTH_CLIENT_ID"] as? String, clientId.count > 0 else {
            fatalError("WS_AUTH_CLIENT_ID is missing or not configured in Info.plist")
        }
        
        guard let clientSecret = Bundle.main.infoDictionary?["WS_AUTH_CLIENT_SECRET"] as? String, clientSecret.count > 0 else {
            fatalError("WS_AUTH_CLIENT_SECRET is missing or not configured in Info.plist")
        }
    
        self.clientCredentials = ClientCredentials(clientId: clientId, clientSecret: clientSecret)
    }
    
    func getUserId() -> String {
        return "demoapp"
    }
    
    func getClientLogin() -> ClientCredentials {
        clientCredentials
    }
}
