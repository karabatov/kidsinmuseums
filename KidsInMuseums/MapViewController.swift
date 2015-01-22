//
//  MapViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 22.01.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import Foundation

class MapViewController: UIViewController {
    // MARK: UIViewController

    override func viewDidLoad() {
        title = NSLocalizedString("Map", comment: "Map controller title")
        tabBarItem = UITabBarItem(title: title, image: UIImage(named: "icon-map"), tag: 0)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: "Navbar back button title"), style: .Plain, target: nil, action: nil)
        edgesForExtendedLayout = UIRectEdge.None

        var camera = GMSCameraPosition.cameraWithLatitude(55.75, longitude: 37.61, zoom: 12)
        var mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        view = mapView
    }
}