//
//  EventsListViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 01.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

public enum EventFilterMode {
    case Date, Proximity, Rating
}

let kKIMSegmentedControlMarginV: CGFloat = 6.0
let kKIMSegmentedControlMarginH: CGFloat = 8.0
let kKIMSegmentedControlHeight: CGFloat = 30.0

class EventsListViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    var listView = ASTableView()
    var eventItems: [Event] = [Event]()
    var refreshControl: UIRefreshControl?
    var bgView = NoDataView()
    var location: CLLocation?
    var filterMode = EventFilterMode.Proximity
    var segControl: UISegmentedControl?

    // MARK: UIViewController

    override required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = NSLocalizedString("Events", comment: "Events controller title")
        tabBarItem = UITabBarItem(title: title, image: UIImage(named: "icon-events"), tag: 0)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: "Navbar back button title"), style: .Plain, target: nil, action: nil)
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | .FlexibleWidth
        self.view.backgroundColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = UIRectEdge.None
        let b = self.view.bounds
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.bgView.measure(b.size)
            self.bgView.frame = b
            dispatch_async(dispatch_get_main_queue(), {
                self.view.addSubview(self.bgView.view)
                self.view.sendSubviewToBack(self.bgView.view)
            })
        })
        self.view.addSubview(listView)
        listView.separatorStyle = UITableViewCellSeparatorStyle.None;
        listView.backgroundColor = UIColor.clearColor()
        listView.asyncDelegate = self
        listView.asyncDataSource = self
        var segItems = [String]()
        segItems.append(NSLocalizedString("Date", comment: "Date filter segment"))
        segItems.append(NSLocalizedString("Distance", comment: "Distance filter segment"))
        segItems.append(NSLocalizedString("Rating", comment: "Rating filter segment"))
        segControl = UISegmentedControl(items: segItems)
        segControl?.frame = self.segControlFrame()
        self.view.addSubview(segControl!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventItemsUpdated:", name: kKIMNotificationEventsUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventItemsUpdated:", name: kKIMNotificationMuseumsUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventItemsUpdateFailed:", name: kKIMNotificationEventsUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationUpdated:", name: kKIMLocationUpdated, object: nil)
    }

    override func viewWillLayoutSubviews() {
        let a = self.view.bounds
        let sf = self.segControlFrame()
        let vDiff: CGFloat = sf.size.height + kKIMSegmentedControlMarginV * 2
        let b = CGRectMake(0, vDiff, a.size.width, a.size.height - vDiff)
        if (listView.frame != b) {
            listView.frame = b
            self.bgView.measure(a.size)
            self.bgView.frame = a
            listView.reloadData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        if DataModel.sharedInstance.dataLoaded() {
            eventItems = DataModel.sharedInstance.events
            listView.reloadData()
            bgView.hidden = true
        }
    }

    override func viewDidAppear(animated: Bool) {
        if (refreshControl == nil) {
            refreshControl = UIRefreshControl()
            refreshControl?.backgroundColor = UIColor(red: 127.0/255.0, green: 86.0/255.0, blue: 149.0/255.0, alpha: 1.0)
            refreshControl?.tintColor = UIColor.whiteColor()
            refreshControl?.addTarget(self, action: "updateEvents", forControlEvents: UIControlEvents.ValueChanged)
            listView.addSubview(refreshControl!)
            listView.sendSubviewToBack(refreshControl!)
        }
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        delegate.requestLocationPermissions()
        delegate.wantsLocation = true
    }

    override func viewWillDisappear(animated: Bool) {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        delegate.wantsLocation = false
    }

    // MARK: Data

    func updateEvents() {
        DataModel.sharedInstance.updateEvents()
    }

    func eventItemsUpdated(notification: NSNotification) {
        if DataModel.sharedInstance.dataLoaded() {
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshControl?.endRefreshing()
                self.eventItems = DataModel.sharedInstance.events
                self.listView.reloadData()
                self.bgView.hidden = true
            }
        }
    }

    func eventItemsUpdateFailed(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.refreshControl?.endRefreshing()
            return
        }
    }

    func locationUpdated(notification: NSNotification) {
        if let loc = notification.userInfo?[kKIMLocationUpdatedKey] as? CLLocation {
            dispatch_async(dispatch_get_main_queue(), {
                self.location = loc
                self.listView.reloadRowsAtIndexPaths(self.listView.indexPathsForVisibleRows(), withRowAnimation: UITableViewRowAnimation.None)
            })
        }
    }

    // MARK: ASTableView

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventItems.count
    }

    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        let event = eventItems[indexPath.row]
        let node = EventCell(event: event, filterMode: filterMode, referenceDate: NSDate(), location: location)
        return node
    }

    func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    }

    // MARK: Helpers

    func segControlFrame() -> CGRect {
        return CGRectMake(kKIMSegmentedControlMarginH, kKIMSegmentedControlMarginV, UIScreen.mainScreen().bounds.size.width - kKIMSegmentedControlMarginH * 2, kKIMSegmentedControlHeight)
    }
}
