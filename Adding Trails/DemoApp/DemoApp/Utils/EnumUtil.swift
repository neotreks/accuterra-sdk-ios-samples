//
//  EnumUtil.swift
//  DemoApp
//
//  Created by Rudolf Kopřiva on 02/03/2020.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import Foundation
import AccuTerraSDK

///
/// Utility class for caching enums values.
///

public class EnumUtil {
    private static var techRatings = [String: TechnicalRating]()
    
    ///
    /// Caches enum values by accessing those for a first time.
    ///
    static func cacheEnums() {
        let _ = getTechRatings()
    }
    
    static func getTechRatingForCode(code: String) -> TechnicalRating? {
        initTechRatings()
        return techRatings[code]
    }

    static func getTechRatings() -> [TechnicalRating] {
        initTechRatings()
        return Array(techRatings.values.sorted(by: { (r1, r2) -> Bool in
            return r1.level < r2.level
        }))
    }
    
    private static func initTechRatings() {
        if techRatings.count == 0 {
            synchronized(lock: self) {
                if techRatings.count == 0 {
                    do {
                        let ratings = try ServiceFactory.getEnumService().getTechRatings()
                        ratings.forEach { (rating) in
                            techRatings[rating.code] = rating
                        }
                    }
                    catch {
                        debugPrint("\(error)")
                    }
                }
            }
        }
    }
}
