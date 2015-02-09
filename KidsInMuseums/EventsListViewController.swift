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

public func removeDuplicates<C: ExtensibleCollectionType where C.Generator.Element : Equatable>(aCollection: C) -> C {
    var container = C()

    for element in aCollection {
        if !contains(container, element) {
            container.append(element)
        }
    }

    return container
}

class EventsListViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    var listView = ASTableView()
    var eventItems: [Event] = [Event]()
    var eventsByDay = [[Event]]()
    var eventsByDistance = [Event]()
    var eventsByRating = [Event]()
    var refreshControl: BDBSpinKitRefreshControl?
    var bgView = NoDataView()
    var location: CLLocation?
    var filterMode = EventFilterMode.Date
    var segControl: UISegmentedControl?
    var days = [NSDate]()
    var sectionHeaderFormatter = NSDateFormatter()
    var sectionHeaderHeight: CGFloat = 0

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
        segControl?.selectedSegmentIndex = 0
        segControl?.addTarget(self, action: "controlValueChanged:", forControlEvents: .ValueChanged)
        segControl?.frame = self.segControlFrame()
        self.view.addSubview(segControl!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventItemsUpdated:", name: kKIMNotificationEventsUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventItemsUpdated:", name: kKIMNotificationMuseumsUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventItemsUpdateFailed:", name: kKIMNotificationEventsUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationUpdated:", name: kKIMLocationUpdated, object: nil)

        let timeFormat = NSDateFormatter.dateFormatFromTemplate("EEEE, dMMMM", options: 0, locale: NSLocale.currentLocale())
        sectionHeaderFormatter.dateFormat = timeFormat
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

//    override func viewWillAppear(animated: Bool) {
//        if DataModel.sharedInstance.dataLoaded() {
//            self.fillAndReload()
//            bgView.hidden = true
//        }
//    }

    override func viewDidAppear(animated: Bool) {
        if (refreshControl == nil) {
            refreshControl = BDBSpinKitRefreshControl(style: RTSpinKitViewStyle.StyleThreeBounce, color: UIColor.whiteColor())
            let purpleColor = UIColor(red: 127.0/255.0, green: 86.0/255.0, blue: 149.0/255.0, alpha: 1.0)
            refreshControl?.backgroundColor = purpleColor
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

    func fillAndReload() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let events = DataModel.sharedInstance.events

            // Date
            self.days.removeAll(keepCapacity: false)
            self.eventsByDay.removeAll(keepCapacity: false)

            let reduced = events.map({ (event: Event) -> [NSDate] in
                    return event.futureDays(NSDate())
            }).reduce([], +)
            self.days.extend(removeDuplicates(reduced))
            self.days.sort({ (d1: NSDate, d2: NSDate) -> Bool in
                return d1.compare(d2) == NSComparisonResult.OrderedAscending
            })

            for day in self.days {
                var evts = events.filter({(testEvt: Event) -> Bool in
                    return testEvt.hasEventsDuringTheDay(day)
                })
                evts.sort({ (e1: Event, e2: Event) -> Bool in
                    let d1 = e1.earliestEventTime(day)!.timeFrom
                    let d2 = e2.earliestEventTime(day)!.timeFrom
                    return d1.compare(d2) == NSComparisonResult.OrderedAscending
                })
                self.eventsByDay.append(evts)
            }

            // Distance 
            self.eventsByDistance.removeAll(keepCapacity: false)
            self.eventsByDistance.extend(events)
            if let loc = self.location {
                self.eventsByDistance.sort({(e1: Event, e2: Event) -> Bool in
                    return e1.distanceFromLocation(loc) < e2.distanceFromLocation(loc)
                })
            }

            // Rating
            self.eventsByRating.removeAll(keepCapacity: false)
            self.eventsByRating.extend(events)
            self.eventsByRating.sort({(e1: Event, e2: Event) -> Bool in
                return e1.rating > e2.rating
            })

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.listView.reloadData()
            })
        })
    }

    func updateEvents() {
        DataModel.sharedInstance.updateEvents()
    }

    func eventItemsUpdated(notification: NSNotification) {
        if DataModel.sharedInstance.dataLoaded() {
            dispatch_async(dispatch_get_main_queue()) {
                self.fillAndReload()
                self.refreshControl?.endRefreshing()
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
                self.listView.reloadRowsAtIndexPaths(self.listView.indexPathsForVisibleRows(), withRowAnimation: UITableViewRowAnimation.Automatic)
            })
        }
    }

    // MARK: ASTableView

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch filterMode {
        case .Date: return eventsByDay[section].count
        case .Distance: return eventsByDistance.count
        case .Rating: return eventsByRating.count
        default: return eventItems.count
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        switch filterMode {
        case .Date: return days.count
        default: return 1
        }
    }

    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        var referenceDate = NSDate()
        if filterMode == .Date {
            referenceDate = days[indexPath.section]
        }

        if let evt = self.eventForIndexPath(indexPath) {
            let node = EventCell(event: evt, filterMode: filterMode, referenceDate: referenceDate, location: location)
            return node
        }
        return ASCellNode()
    }

    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        if filterMode == .Date && days.count > section {
            if sectionHeaderHeight == 0 {
                let text = sectionHeaderFormatter.stringFromDate(days[section])
                let attrText = NSAttributedString(string: text, attributes: kKIMSectionHeaderParams)
                let size = attrText.boundingRectWithSize(CGSizeMake(UIScreen.mainScreen().bounds.width - kKIMSectionHeaderMarginH * 2, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
                sectionHeaderHeight = size.height + kKIMSectionHeaderMarginV * 2
            }
            return sectionHeaderHeight
        }
        return 0
    }

    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let header = UITableViewHeaderFooterView()
        header.contentView.backgroundColor = UIColor.whiteColor()
        if filterMode == .Date && days.count > section {
            let text = sectionHeaderFormatter.stringFromDate(days[section])
            header.textLabel.attributedText = NSAttributedString(string: text, attributes: kKIMSectionHeaderParams)
        }
        return header
    }

    func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if let event = eventForIndexPath(indexPath) {
            let eventItemVC = EventItemViewController(event: event)
            navigationController?.pushViewController(eventItemVC, animated: true)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    // MARK: UISegmentedControl

    func controlValueChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: self.filterMode = .Date
        case 1: self.filterMode = .Distance
        case 2: self.filterMode = .Rating
        default: fatalError("The segment that should not be!")
        }
        listView.reloadData()
    }

    // MARK: Helpers

    func eventForIndexPath(indexPath: NSIndexPath) -> Event? {
        var event: Event?
        switch filterMode {
        case .Date:
            event = eventsByDay[indexPath.section][indexPath.row]
        case .Distance:
            event = eventsByDistance[indexPath.row]
        case .Rating:
            event = eventsByRating[indexPath.row]
        default:
            event = eventItems[indexPath.row]
        }
        return event
    }

    func segControlFrame() -> CGRect {
        return CGRectMake(kKIMSegmentedControlMarginH, kKIMSegmentedControlMarginV, UIScreen.mainScreen().bounds.size.width - kKIMSegmentedControlMarginH * 2, kKIMSegmentedControlHeight)
    }
}
