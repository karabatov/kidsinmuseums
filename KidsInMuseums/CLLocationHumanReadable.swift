//
//  CLLocationHumanReadable.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 02.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

extension CLLocationDistance {
    func humanReadable() -> String {
        if self > 999 {
            return NSString(format: NSLocalizedString("%0.2f km", comment: "Distance in km format"), self / 1000)
        } else {
            return NSString(format: NSLocalizedString("%0.0f m", comment: "Distance in m format"), self)
        }
    }
}