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
        guard let serviceUrl = Bundle.main.infoDictionary?["WS_BASE_URL"] as? String else {
            fatalError("WS_BASE_URL is missing in info.plist")
        }
        guard let accuTerraMapStyleUrl = Bundle.main.infoDictionary?["ACCUTERRA_MAP_STYLE_URL"] as? String else {
            fatalError("ACCUTERRA_MAP_STYLE_URL is missing in info.plist")
        }
        
        SdkManager.shared.initSdkAsync(
            config: SdkConfig(wsUrl: serviceUrl, accuterraMapStyleUrl: accuTerraMapStyleUrl),
            accessProvider: DemoAccessManager.shared,
            identityProvider: DemoIdentityManager.shared,
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
