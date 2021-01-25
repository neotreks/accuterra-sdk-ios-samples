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
            delegate: coordinator)
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
