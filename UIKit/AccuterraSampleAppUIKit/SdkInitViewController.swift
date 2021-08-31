//
//  SdkInitViewController.swift
//  AccuterraSampleAppUIKit
//
//  Created by Rudolf Kopřiva on 19.01.2021.
//

import UIKit
import AccuTerraSDK

class SdkInitViewController: UIViewController {

    var appSdkConfig: ApkSdkConfig = {
        guard let WS_BASE_URL = Bundle.main.infoDictionary?["WS_BASE_URL"] as? String else {
            fatalError("WS_BASE_URL is missing in info.plist")
        }
        guard let WS_AUTH_URL = Bundle.main.infoDictionary?["WS_AUTH_URL"] as? String else {
            fatalError("WS_AUTH_URL is missing in info.plist")
        }
        let sdkEndpointConfig = SdkEndpointConfig(wsUrl: WS_BASE_URL, wsAuthUrl: WS_AUTH_URL)
        URLProtocol.registerClass(HEREMapsURLProtocol.self)
        return ApkSdkConfig(
            sdkEndpointConfig: sdkEndpointConfig,
            mapConfig: MapConfig(
                // providing nil value will load map token and style url from backend
                accuTerraMapConfig: nil,
                // custom imagery style
                imageryMapConfig: ImageryMapConfig(styleURL: HEREMapsURLProtocol.styleURL)),
            tripConfiguration: TripConfiguration(
                // Just to demonstrate the upload network type constraint
                uploadNetworkType: .CONNECTED,
                // Let's keep the trip recording on the device for development reasons,
                // otherwise it should be deleted
                deleteRecordingAfterUpload: false),
            trailConfiguration: TrailConfiguration(
                // Update trail DB during SDK initialization
                updateTrailDbDuringSdkInit: true,
                // Update trail User Data during SDK initialization
                updateTrailUserDataDuringSdkInit: true
            ),
            mapRequestInterceptor: HEREMapsURLProtocol.self
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize SDK
        
        SdkManager.shared.initSdkAsync(
                    config: appSdkConfig,
                    accessProvider: DemoAccessManager.shared,
                    identityProvider: DemoAccessManager.shared,
                    delegate: self,
                    dbEncryptConfigProvider: nil)
    }
}

extension SdkInitViewController : SdkInitDelegate {
    func onStateChanged(state: SdkInitState, detail: SdkInitStateDetail?) {
        switch state {
        case .COMPLETED:
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "map", sender: nil)
            }
        default:
            break
        }
    }
    
    func onProgressChanged(progress: Int) {
    }
}
