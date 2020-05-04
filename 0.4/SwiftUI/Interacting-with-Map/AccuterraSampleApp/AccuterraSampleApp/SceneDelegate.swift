//
//  SceneDelegate.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 5/3/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import UIKit
import SwiftUI
import AccuTerraSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var scene: UIWindowScene?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        if let windowScene = scene as? UIWindowScene {
            self.scene = windowScene
            self.window = UIWindow(windowScene: windowScene)

            let window = UIWindow(windowScene: windowScene)
            if SdkManager.shared.isTrailDbInitialized {
                // Init the SDK when the DB has already been downloaded
                self.initSdk()
            }
            else {
                // Download the trails DB
                window.rootViewController = UIHostingController(rootView: ControllerView(viewRouter: ViewRouter()))
            }

            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    private func initSdk() {
        guard let clientToken = Bundle.main.infoDictionary?["AccuTerraClientToken"] as? String,
            let serviceUrl = Bundle.main.infoDictionary?["AccuTerraServiceUrl"] as? String else {
                fatalError("AccuTerraClientToken and AccuTerraServiceUrl is missing in info.plist")
        }
        SdkManager.shared.initSdkAsync(config: SdkConfig(clientToken: clientToken, wsUrl: serviceUrl), delegate: self)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func showDownloadErrors(error: String){
        let alertVC = UIAlertController(title: "SDK Init Error" , message: "Error: \(error)", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.cancel) { (alert) in }
        alertVC.addAction(okAction)
        DispatchQueue.main.async {
            var presentVC = self.window?.rootViewController
            while let next = presentVC?.presentedViewController {
                presentVC = next
            }
            presentVC?.present(alertVC, animated: true, completion: nil)
        }
    }

    func gotoHomeView() {
        let viewRouter = ViewRouter()
        viewRouter.currentPage = "home"
        self.window?.rootViewController = UIHostingController(rootView: ControllerView(viewRouter: viewRouter))
        window?.makeKeyAndVisible()
    }

}

extension SceneDelegate : SdkInitDelegate {
    
    func onProgressChanged(progress: Int) {}
    
    func onStateChanged(state: SdkInitState, detail: SdkInitStateDetail?) {
        DispatchQueue.main.async {
            switch state {
            case .COMPLETED:
                self.gotoHomeView()
             case .FAILED(let error):
                print("Download error: \(String(describing: error))")
                self.showDownloadErrors(error: String(describing: error))
            default:
                break
            }
        }
    }
}

