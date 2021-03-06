//
//  CLLocationHumanReadable.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 02.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import CoreLocation

extension CLLocationDistance {
    func humanReadable() -> String {
        if self > 999 {
            return NSString(format: NSLocalizedString("%0.0f km", comment: "Distance in km format"), self / 1000) as String
        } else {
            return NSString(format: NSLocalizedString("%0.0f m", comment: "Distance in m format"), self) as String
        }
    }
}