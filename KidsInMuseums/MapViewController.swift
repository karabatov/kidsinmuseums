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
    var calloutStartRect = CGRect.zero
    var calloutShouldOffset = false
    var shouldDisplayMuseumId: Int?
    var shouldDisplayFamilyTrip: FamilyTrip?

    // MARK: UIViewController

    override required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = NSLocalizedString("Map", comment: "Map controller title")
        tabBarItem = UITabBarItem(title: title, image: UIImage(named: "icon-map"), tag: 0)
    }

    required init?(coder aDecoder: NSCoder) {
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "markersUpdated:", name: kKIMNotificationFamilyTripsUpdated, object: nil)
        updateMarkers()
    }

    override func viewDidAppear(animated: Bool) {
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            delegate.requestLocationPermissions()
            delegate.wantsLocation = true
        }
        tryDisplayingPreselectedMuseum()
    }

    override func viewWillDisappear(animated: Bool) {
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            delegate.wantsLocation = false
        }
    }

    func markersUpdated(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateMarkers()
        })
    }

    func updateMarkers() {
        if DataModel.sharedInstance.dataLoaded() {
            if let mapView = view as? MKMapView {
                if mapView.selectedAnnotations.count == 1 {
                    if let ann = mapView.selectedAnnotations.first as? MuseumAnnotation {
                        shouldDisplayMuseumId = ann.museum.id
                    }
                }
                mapView.removeAnnotations(mapView.annotations)
                var museumsWithEvents = NSMutableSet()

                if let showTrip = shouldDisplayFamilyTrip {
                    for museumId in showTrip.museums {
                        museumsWithEvents.addObject(museumId)
                    }
                } else {
                    for event in DataModel.sharedInstance.allEvents {
                        museumsWithEvents.addObject(event.museumUserId)
                    }
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
                tryDisplayingPreselectedMuseum()
            }
        }
    }

    func showMyLocation() {
        if let mapView = view as? MKMapView {
            mapView.setCenterCoordinate(mapView.userLocation.coordinate, animated: true)
        }
    }

    // MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return MKTileOverlayRenderer(overlay: overlay)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MuseumAnnotation) {
            var annView = mapView.dequeueReusableAnnotationViewWithIdentifier(kKIMMapPinAnnotationView)
            if annView == nil {
                annView = MKAnnotationView(annotation: annotation, reuseIdentifier: kKIMMapPinAnnotationView)
            }
            if let annView = annView {
                annView.image = UIImage(named: "marker")
                annView.centerOffset = CGPointMake(0, -annView.image!.size.height / 2)
                annView.enabled = true
                annView.canShowCallout = false
                return annView
            }
        }
        return nil
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let museumAnnotation = view.annotation as? MuseumAnnotation {
            let museumInfoView = MuseumInfoView(museum: museumAnnotation.museum, maxWidth: self.view.frame.size.width - kCalloutMargin * 2, showsEvents: true)
            calloutView.contentView = museumInfoView

            calloutShouldOffset = true
            calloutStartRect = mapView.convertRect(view.bounds, fromView: view)
            calloutView.presentCalloutFromRect(calloutStartRect, inView: mapView, constrainedToView: mapView, animated: true)
        }
    }

    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        calloutView.dismissCalloutAnimated(true)
    }

    func calloutView(calloutView: SMCalloutView!, delayForRepositionWithSize offset: CGSize) -> NSTimeInterval {
        // When the callout is being asked to present in a way where it or its target will be partially offscreen, it asks us
        // if we'd like to reposition our surface first so the callout is completely visible. Here we scroll the map into view,
        // but it takes some math because we have to deal in lon/lat instead of the given offset in pixels.

        if let mapView = self.view as? MKMapView where calloutShouldOffset {
            var coordinate = mapView.centerCoordinate

            // where's the center coordinate in terms of our view?
            var center = mapView.convertCoordinate(coordinate, toPointToView:self.view)

            // move it by the requested offset
            center.x -= offset.width
            center.y -= offset.height

            // and translate it back into map coordinates
            coordinate = mapView.convertPoint(center, toCoordinateFromView:self.view);

            // move the map!
            mapView.setCenterCoordinate(coordinate, animated: true)

            calloutShouldOffset = false
            calloutStartRect.offsetInPlace(dx: offset.width, dy: offset.height)
            self.calloutView.dismissCalloutAnimated(false)
            let time: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(kSMCalloutViewRepositionDelayForUIScrollView * Double(NSEC_PER_SEC)))
            dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
                self.calloutView.presentCalloutFromRect(self.calloutStartRect, inView: mapView, constrainedToView: mapView, animated: true)
            })
        }

        // tell the callout to wait for a while while we scroll (we assume the scroll delay for MKMapView matches UIScrollView)
        return kSMCalloutViewRepositionDelayForUIScrollView
    }

    func selectMuseum(museum: Museum) {
        shouldDisplayMuseumId = museum.id
    }

    func tryDisplayingPreselectedMuseum() {
        if let mapView = view as? MKMapView where mapView.bounds != CGRect.zero {
            for anno in mapView.annotations {
                if let
                    ann = anno as? MuseumAnnotation,
                    museumId = shouldDisplayMuseumId
                    where ann.museum.id == museumId
                {
                    shouldDisplayMuseumId = nil
                    let time: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(kSMCalloutViewRepositionDelayForUIScrollView * Double(NSEC_PER_SEC)))
                    dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
                        mapView.selectAnnotation(ann, animated: true)
                    })
                }
            }
        }
    }
}
