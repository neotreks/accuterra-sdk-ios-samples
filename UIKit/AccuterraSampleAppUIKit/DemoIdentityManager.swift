//
// Created by Rudolf Kopřiva on 09/10/2020.
// Copyright (c) 2020 NeoTreks. All rights reserved.
//

import Foundation
import AccuTerraSDK

class DemoIdentityManager : IIdentityProvider {

    private static let defaultUserId = "test driver uuid"

    public static var shared: DemoIdentityManager = {
        DemoIdentityManager()
    }()

    private init() {
    }

    func getUserId() -> String {
        // Read from UserDefaults

        return DemoIdentityManager.defaultUserId // We need to set default value here since settings cannot be reset to null and returns "" instead
    }

    func setUserId(userId: String?) {
        // Write to UserDefaults
    }
}
