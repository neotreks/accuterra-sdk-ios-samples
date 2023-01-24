//
//  SdkInitView.swift
//  AccuterraSampleAppSwiftUI
//
//  Created by Rudolf Kopřiva on 14.01.2021.
//

import UIKit
import SwiftUI
import AccuTerraSDK
import Mapbox

struct SdkInitView: UIViewRepresentable {
    @ObservedObject var sdkInitObserver: SdkInitObserver

    var appSdkConfig: ApkSdkConfig = {
        guard let WS_BASE_URL = Bundle.main.infoDictionary?["WS_BASE_URL"] as? String else {
            fatalError("WS_BASE_URL is missing in info.plist")
        }
        guard let WS_AUTH_URL = Bundle.main.infoDictionary?["WS_AUTH_URL"] as? String else {
            fatalError("WS_AUTH_URL is missing in info.plist")
        }
        let sdkEndpointConfig = SdkEndpointConfig(wsUrl: WS_BASE_URL, wsAuthUrl: WS_AUTH_URL)
        return ApkSdkConfig(
            sdkEndpointConfig: sdkEndpointConfig,
            mapConfig: MapConfig(
                // providing nil value will load map token and style url from backend
                accuTerraMapConfig: nil,
                // custom imagery style
                imageryMapConfig: ImageryMapConfig(styleURL: ApkHereMapClass.styleURL)),
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
            mapRequestInterceptor: ApkHereMapClass()
        )
    }()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SdkInitView>) -> UIActivityIndicatorView {
        initializeSdk(coordinator: context.coordinator)
        return UIActivityIndicatorView(style: .large)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<SdkInitView>) {
        uiView.startAnimating()
    }
    
    private func initializeSdk(coordinator: Coordinator) {
        // Initialize SDK
        
        SdkManager.shared.initSdkAsync(
            config: appSdkConfig,
            accessProvider: DemoCredentialsAccessManager.shared,
            identityProvider: DemoIdentityManager.shared,
            delegate: coordinator,
            dbEncryptConfigProvider: nil)
    }
}

class SdkInitObserver: ObservableObject {
    @Published var isInitialized: Bool = false
}

extension SdkInitView {
    class Coordinator: NSObject, SdkInitDelegate {
        var controlView: SdkInitView
        
        init(_ view: SdkInitView) {
            self.controlView = view
        }
        
        func onStateChanged(state: SdkInitState, detail: SdkInitStateDetail?) {
            switch state {
            case .COMPLETED:
                DispatchQueue.main.async {
                    self.controlView.sdkInitObserver.isInitialized = true
                }
            default:
                break
            }
        }
        
        func onProgressChanged(progress: Int) {
        }
    }
}
