//
//  DownloadViewController.swift
//  Adding-Trails
//
//  Created by Brian Elliott on 3/5/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import UIKit
import AccuTerraSDK

class DownloadViewController: UIViewController {
    
    let shapeLayer = CAShapeLayer()
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 28)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Download Trails DB"
        drawDownloadCircle()
    }
    
    private func initSdk() {
        guard let clientToken = Bundle.main.infoDictionary?["AccuTerraClientToken"] as? String,
            let serviceUrl = Bundle.main.infoDictionary?["AccuTerraServiceUrl"] as? String else {
                fatalError("AccuTerraClientToken and AccuTerraServiceUrl is missing in info.plist")
        }
        SdkManager.shared.initSdkAsync(config: SdkConfig(clientToken: clientToken, wsUrl: serviceUrl), delegate: self)
    }
        
    @objc private func downloadTapped() {
        if !SdkManager.shared.isTrailDbInitialized {
            // Init the SDK. Since DB was not downloaded yet, it will be downloaded
            // during SDK initialization.
            initSdk()
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Download already complete", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                //
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func goToHome() {
        let dialog = UIAlertController(title: "Download Status", message: "The trail DB has successfully downloaded. Proceeding to map.", preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "GoToHome", sender: nil)
        }))
        self.present(dialog, animated: true)

    }
    
    private func drawDownloadCircle() {
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
        
        let trackLayer = CAShapeLayer()
        
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.position = view.center
        
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.position = view.center
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(downloadTapped)))
    }
    
    fileprivate func resetCircle() {
        shapeLayer.strokeEnd = 0
        self.percentageLabel.text = "Start"
    }
    
    fileprivate func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }

}

extension DownloadViewController : SdkInitDelegate {
    func onProgressChanged(progress: Int) {
        DispatchQueue.main.async {
            self.percentageLabel.text = "\(progress)%"
            self.shapeLayer.strokeEnd = CGFloat(progress)
        }
    }
    
    func onStateChanged(state: SdkInitState, detail: SdkInitStateDetail?) {
        DispatchQueue.main.async {
            switch state {
            case .COMPLETED:
                self.goToHome()
             case .FAILED(let error):
                self.resetCircle()
                let alert = UIAlertController(title: "Error", message: "Download Failed. Error: \(String(describing: error))", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                }))
                self.present(alert, animated: true, completion: nil)
            default:
                break
            }
        }
    }
}


