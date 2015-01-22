//
//  MapViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 22.01.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import Foundation

class MapViewController: UIViewController {
    var museums: [Museum] = [Museum]()
    var markers: [GMSMarker] = [GMSMarker]()

    // MARK: UIViewController

    override required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = NSLocalizedString("Map", comment: "Map controller title")
        tabBarItem = UITabBarItem(title: title, image: UIImage(named: "icon-map"), tag: 0)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: "Navbar back button title"), style: .Plain, target: nil, action: nil)
        edgesForExtendedLayout = UIRectEdge.None

        var camera = GMSCameraPosition.cameraWithLatitude(55.75, longitude: 37.61, zoom: 10)
        var mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        view = mapView
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "markersUpdated:", name: kKIMNotificationMuseumsUpdated, object: nil)
        updateMarkers()
    }

    override func viewDidAppear(animated: Bool) {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        delegate.requestLocationPermissions()
        delegate.wantsLocation = true
    }

    override func viewWillDisappear(animated: Bool) {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        delegate.wantsLocation = false
    }

    func markersUpdated(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateMarkers()
        })
    }

    func updateMarkers() {
        museums = DataModel.sharedInstance.museums
        for marker in markers {
            marker.map = nil
        }
        markers.removeAll(keepCapacity: true)
        for museum in museums {
            var marker = GMSMarker(position: CLLocationCoordinate2DMake(museum.latitude, museum.longitude))
            marker.title = museum.name
            marker.userData = museum.id
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.icon = UIImage(named: "marker")
            marker.map = self.view as GMSMapView
            markers.append(marker)
        }
    }
}