//
//  EventsListViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 01.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import CoreLocation

public enum EventFilterMode {
    case Date, Distance, Rating
}

let kKIMSegmentedControlMarginV: CGFloat = 6.0
let kKIMSegmentedControlMarginH: CGFloat = 8.0
let kKIMSegmentedControlHeight: CGFloat = 30.0
let kKIMSectionHeaderParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0)]
let kKIMSectionHeaderMarginH: CGFloat = 8.0
let kKIMSectionHeaderMarginV: CGFloat = 6.0

let kKIMEventSectionId = -1337

public func removeDuplicates<C: RangeReplaceableCollectionType where C.Generator.Element : Equatable>(aCollection: C) -> C {
    var container = C()

    for element in aCollection {
        if !container.contains(element) {
            container.append(element)
        }
    }

    return container
}

class EventsListViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    let listDay = ASTableView()
    let listRating = ASTableView()
    let listDistance = ASTableView()
    var listViews = [ASTableView]()
    var eventItems: [Event] = [Event]()
    var eventsByDay = [Event]()
    var eventsByDistance = [Event]()
    var eventsByRating = [Event]()
    var refreshControlDay: UIRefreshControl?
    var refreshControlDistance: UIRefreshControl?
    var refreshControlRating: UIRefreshControl?
    let bgView = NoDataView()
    let loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    let filterInfoNode = FilterInfoNode(filter: DataModel.sharedInstance.filter)
    var location: CLLocation?
    var filterMode = EventFilterMode.Date
    var segControl: UISegmentedControl?
    var days = [NSDate]()
    var sectionHeaderFormatter = NSDateFormatter()
    var sectionHeaderHeight: CGFloat = 0
    let serialQ = dispatch_queue_create("com.golovamedia.KiM.serialQ", DISPATCH_QUEUE_SERIAL)

    // MARK: UIViewController

    override required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = NSLocalizedString("Events", comment: "Events controller title")
        tabBarItem = UITabBarItem(title: title, image: UIImage(named: "icon-events"), tag: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        listViews.append(listDay)
        listViews.append(listRating)
        listViews.append(listDistance)
        if let filterButton: UIButton = UIButton(type: UIButtonType.System) as? UIButton {
            filterButton.setTitle(NSLocalizedString(" Filter", comment: "Filter button title"), forState: UIControlState.Normal)
            filterButton.setImage(UIImage(named: "icon-filter"), forState: UIControlState.Normal)
            filterButton.addTarget(self, action: "filterButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            filterButton.sizeToFit()
            let leftBarItem = UIBarButtonItem(customView: filterButton)
            navigationItem.leftBarButtonItem = leftBarItem
        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: "Navbar back button title"), style: .Plain, target: nil, action: nil)
        let calendarButton = UIBarButtonItem(image: UIImage(named: "icon-calendar"), style: UIBarButtonItemStyle.Plain, target: self, action: "calendarFilterButtonTapped:")
        self.navigationItem.rightBarButtonItem = calendarButton
        self.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, .FlexibleWidth]
        self.view.backgroundColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = UIRectEdge.None
        let b = self.view.bounds
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.bgView.measure(b.size)
            self.bgView.frame = b
        })
        loadingView.startAnimating()
        view.addSubview(loadingView)
        view.addSubview(filterInfoNode.view)
        for listView in listViews {
            self.view.addSubview(listView)
            listView.hidden = listView != listDay
            listView.separatorStyle = UITableViewCellSeparatorStyle.None;
            listView.backgroundColor = UIColor.clearColor()
            listView.asyncDelegate = self
            listView.asyncDataSource = self
        }
        var segItems = [String]()
        segItems.append(NSLocalizedString("Date", comment: "Date filter segment"))
        segItems.append(NSLocalizedString("Distance", comment: "Distance filter segment"))
        segItems.append(NSLocalizedString("Rating", comment: "Rating filter segment"))
        segControl = UISegmentedControl(items: segItems)
        segControl?.selectedSegmentIndex = 0
        segControl?.addTarget(self, action: "controlValueChanged:", forControlEvents: .ValueChanged)
        self.view.addSubview(segControl!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventItemsUpdated:", name: kKIMNotificationEventsUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventItemsUpdated:", name: kKIMNotificationMuseumsUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventItemsUpdated:", name: kKIMNotificationNewsUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventItemsUpdateFailed:", name: kKIMNotificationEventsUpdateFailed, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationUpdated:", name: kKIMLocationUpdated, object: nil)

        let timeFormat = NSDateFormatter.dateFormatFromTemplate("EEEE, dMMMM", options: 0, locale: NSLocale.currentLocale())
        sectionHeaderFormatter.dateFormat = timeFormat
    }

    override func viewWillLayoutSubviews() {
        let a = self.view.bounds
        let fi = self.filterInfoSize()
        let sf = self.segControlSize()
        filterInfoNode.frame = CGRectMake(0, 0, fi.width, fi.height)
        filterInfoNode.setNeedsLayout()
        segControl?.frame = CGRectMake(kKIMSegmentedControlMarginH, fi.height + kKIMSegmentedControlMarginV, sf.width, sf.height)
        let vDiff: CGFloat = fi.height + sf.height + kKIMSegmentedControlMarginV * 2.0
        let b = CGRectMake(0, vDiff, a.size.width, a.size.height - vDiff)
        for listView in listViews {
            if (listView.frame != b) {
                listView.frame = b
            }
        }
        self.bgView.measure(a.size)
        self.bgView.frame = a
        self.loadingView.center = CGPoint(x: a.midX, y: a.midY)
    }

    override func viewDidAppear(animated: Bool) {
        if (refreshControlDay == nil) {
            refreshControlDay = addRefreshControl(listDay)
        }
        if (refreshControlDistance == nil) {
            refreshControlDistance = addRefreshControl(listDistance)
        }
        if (refreshControlRating == nil) {
            refreshControlRating = addRefreshControl(listRating)
        }
        var dispatch_token: dispatch_once_t = 0
        dispatch_once(&dispatch_token) {
            if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                delegate.requestLocationPermissions()
                delegate.wantsLocation = true
            }
        }
        if DataModel.sharedInstance.filteredEvents.count > 0 && !loadingView.hidden {
            eventItemsUpdated(NSNotification(name: kKIMNotificationEventsUpdated, object: nil))
        }
    }

    func addRefreshControl(view: ASTableView) -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.kimColor()
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: "updateEvents", forControlEvents: UIControlEvents.ValueChanged)
        view.addSubview(refreshControl)
        view.sendSubviewToBack(refreshControl)
        return refreshControl
    }

    func scrollToTop() {
        for listView in listViews {
            listView.scrollRectToVisible(CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1)), animated: true)
        }
    }

    // MARK: Data

    func fillAndReload() {
        dispatch_async(serialQ) {
            var oldRowsDict = [ASTableView: Int]()
            for listView in self.listViews {
                let oldRows = self.tableView(listView, numberOfRowsInSection: 0)
                oldRowsDict[listView] = oldRows
            }

            let events = DataModel.sharedInstance.filteredEvents

            // Date
            self.days.removeAll(keepCapacity: false)
            self.eventsByDay.removeAll(keepCapacity: false)

            let reduced = events.flatMap({(event: Event) -> [NSDate] in
                return event.futureDays(NSDate())})
            self.days.appendContentsOf(removeDuplicates(reduced))
            self.days.sortInPlace({ (d1: NSDate, d2: NSDate) -> Bool in
                return d1.compare(d2) == NSComparisonResult.OrderedAscending
            })

            let filteredDays = DataModel.sharedInstance.filter.days.isEmpty ? self.days : DataModel.sharedInstance.filter.days

            for day in filteredDays {
                var evts = events.filter({(testEvt: Event) -> Bool in
                    return testEvt.hasEventsDuringTheDay(day)
                })
                evts.sortInPlace({ (e1: Event, e2: Event) -> Bool in
                    let d1 = e1.earliestEventTime(day)!.timeFrom
                    let d2 = e2.earliestEventTime(day)!.timeFrom
                    return d1.compare(d2) == NSComparisonResult.OrderedAscending
                })
                if evts.count > 0 {
                    let sectTitle = self.sectionHeaderFormatter.stringFromDate(day)
                    let sectionEvt = Event(id: kKIMEventSectionId, name: sectTitle)
                    self.eventsByDay.append(sectionEvt)
                    self.eventsByDay.appendContentsOf(evts)
                }
            }

            // Distance 
            self.eventsByDistance.removeAll(keepCapacity: false)
            self.eventsByDistance.appendContentsOf(events)
            if let loc = self.location {
                self.eventsByDistance.sortInPlace({(e1: Event, e2: Event) -> Bool in
                    return e1.distanceFromLocation(loc) < e2.distanceFromLocation(loc)
                })
            }

            // Rating
            self.eventsByRating.removeAll(keepCapacity: false)
            self.eventsByRating.appendContentsOf(events)
            self.eventsByRating.sortInPlace({(e1: Event, e2: Event) -> Bool in
                return e1.rating > e2.rating
            })

            for listView in self.listViews {
                let newRows = self.tableView(listView, numberOfRowsInSection: 0)
                if let oldRows = oldRowsDict[listView] {
                    self.smoothReload(listView, oldRows: oldRows, newRows: newRows)
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.viewWillLayoutSubviews()
            }
        }
    }

    func updateEvents() {
        DataModel.sharedInstance.update()
        bgView.hidden = true
        loadingView.hidden = DataModel.sharedInstance.filteredEvents.count > 0
    }

    func eventItemsUpdated(notification: NSNotification) {
        if DataModel.sharedInstance.dataLoaded() {
            self.fillAndReload()
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshControlDay?.endRefreshing()
                self.refreshControlDistance?.endRefreshing()
                self.refreshControlRating?.endRefreshing()
                self.loadingView.hidden = true
                self.bgView.hidden = true
            }
        }
    }

    func eventItemsUpdateFailed(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.refreshControlDay?.endRefreshing()
            self.refreshControlDistance?.endRefreshing()
            self.refreshControlRating?.endRefreshing()
            self.loadingView.hidden = true
            if DataModel.sharedInstance.filteredEvents.count == 0 {
                if self.bgView.view.superview == nil {
                    self.view.insertSubview(self.bgView.view, aboveSubview: self.loadingView)
                }
                self.bgView.hidden = false
            }
        }
    }

    func locationUpdated(notification: NSNotification) {
        if let loc = notification.userInfo?[kKIMLocationUpdatedKey] as? CLLocation {
            self.location = loc
            dispatch_async(serialQ) {
                for listView in self.listViews {
                    let rows = self.tableView(listView, numberOfRowsInSection: 0)
                    self.smoothReload(listView, oldRows: rows, newRows: rows)
                }
            }
        }
    }

    // MARK: ASTableView

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case listDay: return eventsByDay.count
        case listDistance: return eventsByDistance.count
        case listRating: return eventsByRating.count
        default: return eventItems.count
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        var referenceDate = NSDate()
        if filterMode == .Date && days.count > indexPath.section {
            referenceDate = days[indexPath.section]
        }

        if let evt = self.eventForIndexPath(tableView, indexPath: indexPath) {
            if evt.id != kKIMEventSectionId {
                let node = EventCell(event: evt, filterMode: filterMode, referenceDate: referenceDate, location: location)
                return node
            } else {
                let node = EventDescTitleNode(text: evt.name)
                return node
            }
        }
        return ASCellNode()
    }

    func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if filterMode == .Date && indexPath.row == 0 {
            return
        }
        if let event = eventForIndexPath(tableView, indexPath: indexPath) {
            let eventItemVC = EventItemViewController(event: event, frame: view.bounds)
            navigationController?.pushViewController(eventItemVC, animated: true)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    // MARK: UISegmentedControl

    func controlValueChanged(sender: UISegmentedControl) {
        dispatch_async(dispatch_get_main_queue()) {
            switch sender.selectedSegmentIndex {
            case 0:
                self.filterMode = .Date
                self.listDay.hidden = false
                self.listRating.hidden = true
                self.listDistance.hidden = true
            case 1:
                self.filterMode = .Distance
                self.listDay.hidden = true
                self.listRating.hidden = true
                self.listDistance.hidden = false
            case 2: self.filterMode = .Rating
                self.listDay.hidden = true
                self.listRating.hidden = false
                self.listDistance.hidden = true
            default: fatalError("The segment that should not be!")
            }
        }
    }

    // MARK: Helpers

    func eventForIndexPath(listView: UITableView, indexPath: NSIndexPath) -> Event? {
        var event: Event?
        switch listView {
        case listDay:
            if eventsByDay.count > indexPath.row {
                event = eventsByDay[indexPath.row]
            }
        case listDistance:
            if eventsByDistance.count > indexPath.row {
                event = eventsByDistance[indexPath.row]
            }
        case listRating:
            if eventsByRating.count > indexPath.row {
                event = eventsByRating[indexPath.row]
            }
        default:
            event = eventItems[indexPath.row]
        }
        return event
    }

    func filterInfoSize() -> CGSize {
        if !DataModel.sharedInstance.filter.isEmpty() {
            filterInfoNode.filter = DataModel.sharedInstance.filter
            return filterInfoNode.measure(CGSizeMake(UIScreen.mainScreen().bounds.size.width, CGFloat.max))
        }
        return CGSizeZero
    }

    func segControlSize() -> CGSize {
        return CGSizeMake(UIScreen.mainScreen().bounds.size.width - kKIMSegmentedControlMarginH * 2, kKIMSegmentedControlHeight)
    }

    func smoothReload(listView: ASTableView, oldRows: Int, newRows: Int) {
        listView.beginUpdates()
        var oldIdxSet = [NSIndexPath]()
        if oldRows > 0 {
            oldIdxSet.append(NSIndexPath(forRow: 0, inSection: 0))
        }
        if oldRows > 1 {
            for index in 1..<oldRows {
                oldIdxSet.append(NSIndexPath(forRow: index, inSection: 0))
            }
        }
        listView.deleteRowsAtIndexPaths(oldIdxSet, withRowAnimation: UITableViewRowAnimation.Fade)
        var newIdxSet = [NSIndexPath]()
        if newRows > 0 {
            newIdxSet.append(NSIndexPath(forRow: 0, inSection: 0))
        }
        if newRows > 1 {
            for index in 1..<newRows {
                newIdxSet.append(NSIndexPath(forRow: index, inSection: 0))
            }
        }
        listView.insertRowsAtIndexPaths(newIdxSet, withRowAnimation: UITableViewRowAnimation.Fade)
        listView.endUpdates()
    }

    func filterButtonTapped(sender: UIButton) {
        let filterView = FilterScreen(nibName: nil, bundle: nil)
        filterView.location = self.location
        let navi = UINavigationController(rootViewController: filterView)
        navi.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        presentViewController(navi, animated: true) { () -> Void in
            //
        }
    }

    func calendarFilterButtonTapped(sender: UIBarButtonItem) {
        let filterView = CalendarFilter(days: days)
        let navi = UINavigationController(rootViewController: filterView)
        navi.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        presentViewController(navi, animated: true) { () -> Void in
            //
        }
    }
}
