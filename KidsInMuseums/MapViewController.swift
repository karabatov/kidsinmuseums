//
//  MapViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 22.01.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    var museums: [Museum] = [Museum]()

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "location"), style: .Plain, target: self, action: "showMyLocation")
        edgesForExtendedLayout = UIRectEdge.None

        let mapView = MKMapView()
        mapView.showsUserLocation = true
        view = mapView
        mapView.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 55.75, longitude: 37.61), 10000, 10000)
        mapView.delegate = self
        let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(URLTemplate: template)
        overlay.canReplaceMapContent = true
        mapView.addOverlay(overlay, level: MKOverlayLevel.AboveLabels)

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
        let mapView = view as MKMapView
        mapView.removeAnnotations(mapView.annotations)
        museums = DataModel.sharedInstance.museums
        for museum in museums {
            let annotation = MKPointAnnotation()
            annotation.coordinate = museum.coordinate()
            annotation.title = museum.name
            mapView.addAnnotation(annotation)
        }
    }

    func showMyLocation() {
        let mapView = view as MKMapView
        if let location = mapView.userLocation {
            mapView.setCenterCoordinate(location.coordinate, animated: true)
        }
    }

    // MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay.isKindOfClass(MKTileOverlay) {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        return nil
    }
}
