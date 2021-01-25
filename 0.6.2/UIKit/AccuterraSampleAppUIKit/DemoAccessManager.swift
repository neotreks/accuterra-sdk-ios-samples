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
class DemoAccessManager : IAccessProvider {
    private var clientId: String
    private var clientSecret: String
    private let userId = "demoApp"
    
    public static var shared: DemoAccessManager = {
        return DemoAccessManager()
    }()
    
    private init() {
        guard let WS_AUTH_CLIENT_ID = Bundle.main.infoDictionary?["WS_AUTH_CLIENT_ID"] as? String, WS_AUTH_CLIENT_ID.count > 0 else {
            fatalError("WS_AUTH_CLIENT_ID is missing or not configured in Info.plist")
        }
        clientId = WS_AUTH_CLIENT_ID
        
        guard let WS_AUTH_CLIENT_SECRET = Bundle.main.infoDictionary?["WS_AUTH_CLIENT_SECRET"] as? String, WS_AUTH_CLIENT_SECRET.count > 0 else {
            fatalError("WS_AUTH_CLIENT_SECRET is missing or not configured in Info.plist")
        }
        clientSecret = WS_AUTH_CLIENT_SECRET
    }
    
    /* * * * * * * * * * * * */
    /*        PUBLIC         */
    /* * * * * * * * * * * * */
    
    func getToken(
        callback: @escaping (String) -> Void,
        errorHandler: @escaping (Error) -> Void) {
        getAccessToken(callback: { (token) in
            callback(token.accessToken)
        }, errorHandler: errorHandler)
    }
    
    func getAccuterraMapApiKey() -> String? {
        guard let ACCUTERRA_MAP_API_KEY = Bundle.main.infoDictionary?["ACCUTERRA_MAP_API_KEY"] as? String, ACCUTERRA_MAP_API_KEY.count > 0 else {
            fatalError("ACCUTERRA_MAP_API_KEY is missing or not configured in Info.plist")
        }
        return ACCUTERRA_MAP_API_KEY
    }

    private func getAccessToken(
        callback:@escaping (_ result: AccuTerraAccessToken) -> Void,
        errorHandler:@escaping (_ result:Error) -> Void) {

        if let token = AccessTokenRepo.shared.loadAccessToken() {
            if token.isValid() {
                // The token is valid
                callback(token)
                return
            } else {
                // We need to refresh the existing token
                getRefreshedToken(
                    oldToken: token,
                    callback: { (refreshedToken) in
                        AccessTokenRepo.shared.save(access: refreshedToken)
                        callback(refreshedToken)
                }) { (error) in
                    // We try to get new token, because refresh failed
                    self.getNewAccessToken(callback: { (newToken) in
                        AccessTokenRepo.shared.save(access: newToken)
                        callback(newToken)
                    }) { (error) in
                        errorHandler(error)
                    }
                }
            }
        } else {
            // We need to get new token
            getNewAccessToken(callback: { (token) in
                AccessTokenRepo.shared.save(access: token)
                callback(token)
            }) { (error) in
                errorHandler(error)
            }
        }
    }

    func resetToken(
        callback:@escaping (_ result: AccuTerraAccessToken) -> Void,
        errorHandler:@escaping (_ result:Error) -> Void) {
        
        getNewAccessToken(callback: callback, errorHandler: errorHandler)
    }

    /* * * * * * * * * * * * */
    /*        PRIVATE        */
    /* * * * * * * * * * * * */

    private func getNewAccessToken(
        callback:@escaping (_ result: AccuTerraAccessToken) -> Void,
        errorHandler:@escaping (_ result:Error) -> Void) {
        
        AuthApi.shared.getNewAccessToken(
            clientId: self.clientId,
            clientSecret: self.clientSecret,
            grantType: "client_credentials",
            userId: self.userId,
            callback: { (response) in
                callback(response.toApi())
        }, errorHandler: errorHandler)
    }

    private func getRefreshedToken(
        oldToken: AccuTerraAccessToken,
        callback:@escaping (_ result: AccuTerraAccessToken) -> Void,
        errorHandler:@escaping (_ result:Error) -> Void) {

        AuthApi.shared.refreshAccessToken(
            clientId: self.clientId,
            clientSecret: self.clientSecret,
            grantType: "refresh_token",
            refreshToken: oldToken.refreshToken,
            callback: { (response) in
                callback(response.toApi())
        }, errorHandler: errorHandler)
    }
}

fileprivate extension AuthResponse {
    func toApi() -> AccuTerraAccessToken {
        return AccuTerraAccessToken(
            accessToken: self.accessToken,
            tokenType: self.tokenType,
            refreshToken: self.refreshToken,
            expireDate: getExpirationDate(token: self.accessToken),
            scope: self.scope)
    }
    
    func getExpirationDate(token: String) -> Date {
        let parts = token.split(separator: ".")
        
        if
            parts.count > 2,
            let data = decodeUrlSafeBase64(String(parts[1])),
            let decoded: String = String(data: data, encoding: .utf8),
            let dict: [String: Any] = Mapper<AuthResponse>.parseJSONStringIntoDictionary(JSONString: decoded),
            let exp = dict["exp"] as? Int {
            return Date(timeIntervalSince1970: Double(exp))
        } else {
            fatalError("Cannot parse token expiration, invalid JWT token")
        }
    }
    
    private func decodeUrlSafeBase64(_ value: String) -> Data? {
        var stringtoDecode: String = value.replacingOccurrences(of: "-", with: "+")
        stringtoDecode = stringtoDecode.replacingOccurrences(of: "_", with: "/")
        switch (stringtoDecode.utf8.count % 4) {
            case 2:
                stringtoDecode += "=="
            case 3:
                stringtoDecode += "="
            default:
                break
        }
        return Data(base64Encoded: stringtoDecode, options: [.ignoreUnknownCharacters])
    }
}

/**
 * Access token for AccuTerra Services
 */
struct AccuTerraAccessToken {

    var accessToken: String

    var tokenType: String

    var refreshToken: String

    var expireDate: Date

    var scope: String
    
    /**
     * Return true if the token does not expire in next 60 seconds.
     */
    func isValid() -> Bool {
        return expireDate.timeIntervalSince(Date()) > 60
    }
}


/**
* Repository for the AccessToken
*
* Please this is not a secure implementation since this is just a demo APP.
*/
class AccessTokenRepo {
    
    /* * * * * * * * * * * * */
    /*       STATIC          */
    /* * * * * * * * * * * * */

    static let PREF_NAME = "AccuTerraAccess"
    static let KEY_ACCESS_TOKEN = "AccessToken"
    static let KEY_REFRESH_TOKEN = "RefreshToken"
    static let KEY_TOKEN_EXPIRE = "TokenExpire"
    static let KEY_TOKEN_TYPE = "TokenType"
    static let KEY_TOKEN_SCOPE = "TokenScope"
    
    public static var shared: AccessTokenRepo = {
        return AccessTokenRepo()
    }()
    
    /* * * * * * * * * * * * */
    /*        PUBLIC         */
    /* * * * * * * * * * * * */

    func save(access: AccuTerraAccessToken) {
        UserDefaults.standard.set(access.accessToken, forKey: AccessTokenRepo.KEY_ACCESS_TOKEN)
        UserDefaults.standard.set(access.refreshToken, forKey: AccessTokenRepo.KEY_REFRESH_TOKEN)
        UserDefaults.standard.set(access.expireDate, forKey: AccessTokenRepo.KEY_TOKEN_EXPIRE)
        UserDefaults.standard.set(access.tokenType, forKey: AccessTokenRepo.KEY_TOKEN_TYPE)
        UserDefaults.standard.set(access.scope, forKey: AccessTokenRepo.KEY_TOKEN_SCOPE)
    }

    func loadAccessToken() -> AccuTerraAccessToken? {
        
        if
            let accessToken = UserDefaults.standard.value(forKey: AccessTokenRepo.KEY_ACCESS_TOKEN) as? String,
            let tokenType = UserDefaults.standard.value(forKey: AccessTokenRepo.KEY_TOKEN_TYPE) as? String,
            let refreshToken = UserDefaults.standard.value(forKey: AccessTokenRepo.KEY_REFRESH_TOKEN) as? String,
            let expireIn = UserDefaults.standard.value(forKey: AccessTokenRepo.KEY_TOKEN_EXPIRE) as? Date,
            let scope = UserDefaults.standard.value(forKey: AccessTokenRepo.KEY_TOKEN_SCOPE) as? String {
            
            return AccuTerraAccessToken(accessToken: accessToken, tokenType: tokenType, refreshToken: refreshToken, expireDate: expireIn, scope: scope)
        } else {
            return nil
        }
    }
    
    func reset() {
        UserDefaults.standard.removeObject(forKey: AccessTokenRepo.KEY_ACCESS_TOKEN)
        UserDefaults.standard.removeObject(forKey: AccessTokenRepo.KEY_REFRESH_TOKEN)
        UserDefaults.standard.removeObject(forKey: AccessTokenRepo.KEY_TOKEN_EXPIRE)
        UserDefaults.standard.removeObject(forKey: AccessTokenRepo.KEY_TOKEN_TYPE)
        UserDefaults.standard.removeObject(forKey: AccessTokenRepo.KEY_TOKEN_SCOPE)
    }
    
}

/// Authorization response
class AuthResponse : Mappable {
    var accessToken: String!
    var tokenType: String!
    var refreshToken: String!
    var expiresIn: Int!
    var scope: String!
    
    required init?(map: Map){
    }
    
    func mapping(map: Map) {
        accessToken <- map["access_token"]
        tokenType <- map["token_type"]
        refreshToken <- map["refresh_token"]
        expiresIn <- map["expires_in"]
        scope <- map["scope"]
    }
}

// API for accessing WS Authorization endpoint
class AuthApi {

    private var apiUrl: String
    private static let timeout: TimeInterval = 30 // seconds

    private(set) var sessionManager: Session = {
        var sessionManager = Alamofire.Session()
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = AuthApi.timeout
        sessionManager = Alamofire.Session(configuration: configuration)
        return sessionManager
    }()

    public static var shared: AuthApi = {
        return AuthApi()
    }()
    
    private init() {
        guard let WS_AUTH_URL = Bundle.main.infoDictionary?["WS_AUTH_URL"] as? String else {
            fatalError("WS_AUTH_URL is missing in Info.plist")
        }
        apiUrl = WS_AUTH_URL + "auth/"
    }
    
    func getNewAccessToken(
        clientId: String,
        clientSecret: String,
        grantType: String,
        userId: String,
        callback:@escaping (_ result:AuthResponse) -> Void,
        errorHandler:@escaping (_ result:Error) -> Void) -> Void {
        
        let params = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "grant_type": grantType,
            "user_id": userId
        ]
        
        self.sessionManager.request("\(self.apiUrl)token", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON(queue: DispatchQueue.global(), options: .allowFragments) { response in
            switch response.result {
            case .success:
                if let result = Mapper<AuthResponse>().map(JSONObject:response.value) {
                    callback(result)
                }
                else {
                    errorHandler((response.value != nil ? "\(response.value!)" : "Could not map response to AuthResponse").toError(code: response.response!.statusCode))
                }
            case .failure(let error):
                errorHandler(error)
            }
        }
    }
    
    func refreshAccessToken(
        clientId: String,
        clientSecret: String,
        grantType: String,
        refreshToken: String,
        callback:@escaping (_ result:AuthResponse) -> Void,
        errorHandler:@escaping (_ result:Error) -> Void) -> Void {
        
        let params = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "grant_type": grantType,
            "refresh_token": refreshToken
        ]
        
        self.sessionManager.request("\(self.apiUrl)token", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON(queue: DispatchQueue.global(), options: .allowFragments) { response in
            switch response.result {
            case .success:
                if let result = Mapper<AuthResponse>().map(JSONObject:response.value) {
                    callback(result)
                }
                else {
                    errorHandler((response.value != nil ? "\(response.value!)" : "Could not map response to AuthResponse").toError(code: response.response!.statusCode))
                }
            case .failure(let error):
                errorHandler(error)
            }
        }
    }

}

class DemoIdentityManager : IIdentityProvider {
    
    private static let KEY_USER_SETTINGS = "KEY_USER_SETTINGS"
    private static let defaultUserId = "test driver uuid"
    
    public static var shared: DemoIdentityManager = {
        DemoIdentityManager()
    }()
    
    private init() {
    }
    
    func getUserId() -> String {
        // Read from UserDefaults

        // We need to use default value also here since
        let userId = UserDefaults.standard.string(forKey: DemoIdentityManager.KEY_USER_SETTINGS)
        return userId ?? DemoIdentityManager.defaultUserId // We need to set default value here since settings cannot be reset to null and returns "" instead
    }
    
    func setUserId(userId: String?) {
        if let userId = userId, !userId.isEmpty {
            UserDefaults.standard.setValue(userId, forKey: DemoIdentityManager.KEY_USER_SETTINGS)
        } else {
            UserDefaults.standard.removeObject(forKey: DemoIdentityManager.KEY_USER_SETTINGS)
        }
    }
}
