//
//  MuseumAnnotation.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 06.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import MapKit

public class MuseumAnnotation: MKPointAnnotation {
    public var museum: Museum

    required public init(museum: Museum) {
        self.museum = museum
        super.init()
        self.coordinate = museum.coordinate()
        self.title = museum.name
    }
}
