//
//  HEREMapsURLProtocol.swift
//  AccuterraSampleAppUIKit
//
//  Created by Rudolf Kopřiva on 20.06.2021.
//  Copyright © 2021 NeoTreks. All rights reserved.
//

import Foundation
import Mapbox

/// A custom protocol for logging outgoing requests.
class HEREMapsURLProtocol: URLProtocol {

    enum PropertyKeys {
        static let handledByHEREMapsURLProtocol = "HandledByHEREMapsURLProtocol"
    }

    lazy var session: URLSession = {
        let configuration = MGLNetworkConfiguration.sharedManager.sessionConfiguration ?? URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

        return session
    }()

    lazy var hereAppCode: String = {
        guard let hereAppCode = Bundle.main.infoDictionary?["HERE_APPCODE"] as? String else {
            fatalError("HERE_APPCODE is missing in info.plist")
        }
        return hereAppCode
    }()

    lazy var hereAppId: String = {
        guard let hereAppId = Bundle.main.infoDictionary?["HERE_APPID"] as? String else {
            fatalError("HERE_APPID is missing in info.plist")
        }
        return hereAppId
    }()

    static var styleURL: URL {
        guard let hereSatelliteStyle = Bundle.main.url(forResource: "HERESatelliteStyle", withExtension: "json") else {
            fatalError("Could not find HERESatelliteStyle.json in bundle")
        }
        return hereSatelliteStyle
    }

    weak var activeTask: URLSessionTask?

    override class func canInit(with request: URLRequest) -> Bool {
        if let host = request.url?.host, host.contains("maps.api.here.com") {
            if URLProtocol.property(forKey: PropertyKeys.handledByHEREMapsURLProtocol, in: request) != nil {
                return false
            }
            return true
        } else {
            return false
        }
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        let mutableRequest: NSMutableURLRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: PropertyKeys.handledByHEREMapsURLProtocol, in: mutableRequest)
        if let url = mutableRequest.url?.absoluteString {
            let newUrl = url.appendingFormat("?app_id=%@&app_code=%@", hereAppId, hereAppCode)
            if newUrl.contains("https://1.") {
                let serverId = getLBServer(url: newUrl)
                if let finalUrl = URL(string: newUrl.replacingOccurrences(of: "https://1.", with: "https://\(serverId).")) {
                    mutableRequest.url = finalUrl
                }
            }
        }

        activeTask = session.dataTask(with: mutableRequest as URLRequest, completionHandler: { [weak self] (data, response, error) in
                    guard let strongSelf = self else { return }

                    if let error = error {
                        strongSelf.client?.urlProtocol(strongSelf, didFailWithError: error)
                        return
                    }

                    strongSelf.client?.urlProtocol(strongSelf, didReceive: response!, cacheStoragePolicy: .allowed)
                    strongSelf.client?.urlProtocol(strongSelf, didLoad: data!)
                    strongSelf.client?.urlProtocolDidFinishLoading(strongSelf)
                })

        activeTask?.resume()
    }

    override func stopLoading() {
        activeTask?.cancel()
    }


    /// Return Load Balancer Server. HERE maps API supports 1 to 4
    /// - Parameter url: url
    /// - Returns: load balancer server id
    private func getLBServer(url: String) -> Int {
        if let regex = HEREMapsURLProtocol.tileRegEx {
            if let match = regex.firstMatch(in: url, options: [], range:  NSRange(location: 0, length: url.count)) {
                if match.numberOfRanges == 3 {
                    if let xRange = Range(match.range(at: 1), in: url), let yRange = Range(match.range(at: 2), in: url) {
                        let xString: String = String(url[xRange])
                        let yString: String = String(url[yRange])
                        if let x = Int(xString), let y = Int(yString) {
                            return (x + y) % 4 + 1
                        }
                    }
                }
            }
        }
        return 1
    }

    static let tileRegEx = try? NSRegularExpression(pattern: "/\\d+/(\\d+)/(\\d+)/512/jpg")
}

extension HEREMapsURLProtocol: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            self.client?.urlProtocol(self, didFailWithError: error)
            return
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        self.client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
    }
}
