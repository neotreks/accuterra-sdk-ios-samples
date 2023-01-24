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
 * Class for managing access to AccuTerra services using credentials
 */
class DemoCredentialsAccessManager : ICredentialsAccessProvider {
    private(set) var clientCredentials: ClientCredentials

    public static let shared = DemoCredentialsAccessManager()

    private init() {
        guard let WS_AUTH_CLIENT_ID = Bundle.main.infoDictionary?["WS_AUTH_CLIENT_ID"] as? String, WS_AUTH_CLIENT_ID.count > 0 else {
            fatalError("WS_AUTH_CLIENT_ID is missing or not configured in Info.plist")
        }

        guard let WS_AUTH_CLIENT_SECRET = Bundle.main.infoDictionary?["WS_AUTH_CLIENT_SECRET"] as? String, WS_AUTH_CLIENT_SECRET.count > 0 else {
            fatalError("WS_AUTH_CLIENT_SECRET is missing or not configured in Info.plist")
        }

        clientCredentials = ClientCredentials(clientId: WS_AUTH_CLIENT_ID, clientSecret: WS_AUTH_CLIENT_SECRET)
    }

    func resetToken(completion: @escaping (Result<Void, Error>) -> Void) {
        SdkManager.shared.resetAccessToken(completion: completion)
    }
}
