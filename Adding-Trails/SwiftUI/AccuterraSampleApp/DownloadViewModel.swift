//
//  DownloadViewModel.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/19/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import Foundation
import AccuTerraSDK

class DownloadViewModel: ObservableObject {
    
    enum LoadingState {
        case loading, loaded, failed
    }
    
    private var downloadService: DownloadService!
    
    @Published var loadingState: LoadingState = .loading
    @Published var downloadPercentage:Double = 0
    @Published var downloadError:String = ""
    @Published var downloadSuccess:Bool = false
    
    init() {
        self.downloadService = DownloadService()
    }
    
    var downloadPercentString: String {
        return "\(downloadPercentage) % Complete"
    }
        
    func fetchTrails() {
        self.downloadService.downloadTrails(delegate: self)
    }
}

extension DownloadViewModel : SdkInitDelegate {
    
    func onProgressChanged(progress: Int) {
        DispatchQueue.main.async {
            self.downloadPercentage = Double(progress)
         }
    }
    
    func onStateChanged(state: SdkInitState, detail: SdkInitStateDetail?) {
        DispatchQueue.main.async {
            switch state {
            case .COMPLETED:
                self.loadingState = .loaded
                self.downloadSuccess = true
             case .FAILED(let error):
                print("Download error: \(String(describing: error))")
                self.loadingState = .failed
                self.downloadError = "\(String(describing: error))"
            default:
                break
            }
        }
    }
}
