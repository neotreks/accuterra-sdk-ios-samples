//
//  DownloadViewController.swift
//  DemoApp
//
//  Created by Rudolf Kopřiva on 21/02/2020.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import Foundation
import UIKit
import AccuTerraSDK

protocol DownloadViewControllerDelegate: SdkInitDelegate {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool)
}

class DownloadViewController : BaseViewController {
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        self.view.alpha = 0
        super.viewDidLoad()
    }
    
    weak var delegate: DownloadViewControllerDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let dialog = UIAlertController(title: "Download", message: "The trail DB is going to be downloaded now.", preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.view.alpha = 1
            self.initSdk()
        }))
        delegate?.present(dialog, animated: true)
    }
    
    private func initSdk() {
        guard let clientToken = Bundle.main.infoDictionary?["AccuTerraClientToken"] as? String,
            let serviceUrl = Bundle.main.infoDictionary?["AccuTerraServiceUrl"] as? String else {
                fatalError("AccuTerraClientToken and AccuTerraServiceUrl is missing in info.plist")
        }
        SdkManager.shared.initSdkAsync(config: SdkConfig(clientToken: clientToken, wsUrl: serviceUrl), delegate: self)
    }
}

extension DownloadViewController : SdkInitDelegate {
    func onProgressChanged(progress: Int) {
        DispatchQueue.main.async {
            self.progressView.progress = Float(progress) / 100.0
            self.progressLabel.text = "\(progress)%"
        }
    }
    
    func onStateChanged(state: SdkInitState, detail: SdkInitStateDetail?) {
        self.delegate?.onStateChanged(state: state, detail: detail)
    }
}
