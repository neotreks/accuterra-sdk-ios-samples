//
//  SdkInitViewController.swift
//  AccuterraSampleAppUIKit
//
//  Created by Rudolf Kopřiva on 19.01.2021.
//

import UIKit
import AccuTerraSDK

class SdkInitViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize SDK
        
        guard let wsUrl = Bundle.main.infoDictionary?["WS_BASE_URL"] as? String else {
            fatalError("WS_BASE_URL is missing in info.plist")
        }
        
        guard let wsAuthUrl = Bundle.main.infoDictionary?["WS_AUTH_URL"] as? String else {
            fatalError("WS_AUTH_URL is missing in Info.plist")
        }
        
        SdkManager.shared.initSdkAsync(
            config: ApkSdkConfig(sdkEndpointConfig:
                                    SdkEndpointConfig(
                                        wsUrl: wsUrl,
                                        wsAuthUrl: wsAuthUrl)),
            accessProvider: DemoAccessManager.shared,
            identityProvider: DemoAccessManager.shared,
            delegate: self)
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
