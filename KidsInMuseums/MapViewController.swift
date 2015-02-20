//
//  MapViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 22.01.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import Foundation
import MapKit

let kKIMMapPinAnnotationView = "com.yurikarabatov.kKIMMapPinAnnotationView"

class MapViewController: UIViewController, MKMapViewDelegate, SMCalloutViewDelegate {
    var museums: [Museum] = [Museum]()
    let calloutView = SMCalloutView.platformCalloutView()
    let kCalloutMargin: CGFloat = 14.0

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

        calloutView.delegate = self
        calloutView.constrainedInsets = UIEdgeInsetsMake(kCalloutMargin, kCalloutMargin, kCalloutMargin * 3, kCalloutMargin)

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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "markersUpdated:", name: kKIMNotificationEventsUpdated, object: nil)
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
        if DataModel.sharedInstance.dataLoaded() {
            let mapView = view as MKMapView
            mapView.removeAnnotations(mapView.annotations)
            var museumsWithEvents = NSMutableSet()
            for event in DataModel.sharedInstance.events {
                museumsWithEvents.addObject(event.museumUserId)
            }
            museums.removeAll(keepCapacity: false)
            for museum in DataModel.sharedInstance.museums {
                if museumsWithEvents.containsObject(museum.id) {
                    museums.append(museum)
                }
            }
            for museum in museums {
                let annotation = MuseumAnnotation(museum: museum)
                mapView.addAnnotation(annotation)
            }
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

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(MuseumAnnotation) {
            var annView = mapView.dequeueReusableAnnotationViewWithIdentifier(kKIMMapPinAnnotationView)
            if annView == nil {
                annView = MKAnnotationView(annotation: annotation, reuseIdentifier: kKIMMapPinAnnotationView)
            }
            annView.image = UIImage(named: "marker")
            annView.centerOffset = CGPointMake(0, -annView.image.size.height / 2)
            annView.enabled = true
            annView.canShowCallout = false
            return annView
        }
        return nil
    }

    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let museumAnnotation = view.annotation as? MuseumAnnotation {
            let museumInfoView = MuseumInfoView(museum: museumAnnotation.museum, maxWidth: self.view.frame.size.width - kCalloutMargin * 2)
            calloutView.contentView = museumInfoView
            calloutView.presentCalloutFromRect(view.bounds, inView: view, constrainedToView: self.view, animated: true)
        }
    }

    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        calloutView.dismissCalloutAnimated(true)
    }

    func calloutView(calloutView: SMCalloutView!, delayForRepositionWithSize offset: CGSize) -> NSTimeInterval {
        // When the callout is being asked to present in a way where it or its target will be partially offscreen, it asks us
        // if we'd like to reposition our surface first so the callout is completely visible. Here we scroll the map into view,
        // but it takes some math because we have to deal in lon/lat instead of the given offset in pixels.

        let mapView = self.view as MKMapView

        var coordinate = mapView.centerCoordinate

        // where's the center coordinate in terms of our view?
        var center = mapView.convertCoordinate(coordinate, toPointToView:self.view)

        // move it by the requested offset
        center.x -= offset.width
        center.y -= offset.height

        // and translate it back into map coordinates
        coordinate = mapView.convertPoint(center, toCoordinateFromView:self.view);

        // move the map!
        mapView.setCenterCoordinate(coordinate, animated:true)

        // tell the callout to wait for a while while we scroll (we assume the scroll delay for MKMapView matches UIScrollView)
        return kSMCalloutViewRepositionDelayForUIScrollView
    }
}
