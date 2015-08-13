//
//  SpecialProjectViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 27.07.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import UIKit

class SpecialProjectViewController: UIViewController, ASTableViewDelegate, ASTableViewDataSource {
    let listView = ASTableView()
    var numberOfRoutes = 0

    override required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = NSLocalizedString("Family trip", comment: "Family trip")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | .FlexibleWidth
        self.view.backgroundColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = UIRectEdge.None

        updateNumberOfRows()

        self.view.addSubview(listView)
        listView.directionalLockEnabled = true
        listView.separatorStyle = UITableViewCellSeparatorStyle.None;
        listView.backgroundColor = UIColor.clearColor()
        listView.asyncDelegate = self
        listView.asyncDataSource = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "familyTripRulesUpdated:", name: kKIMNotificationFamilyTripRulesUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "familyTripsUpdated:", name: kKIMNotificationFamilyTripsUpdated, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    private func updateNumberOfRows() {
        numberOfRoutes = DataModel.sharedInstance.familyTrips.count
    }

    override func viewWillLayoutSubviews() {
        let b = self.view.bounds
        if (listView.frame != b) {
            listView.frame = b
            listView.reloadData()
        }
    }

    func familyTripRulesUpdated(notification: NSNotification) {
        listView.reloadSections(NSIndexSet(index: 2), withRowAnimation: UITableViewRowAnimation.Fade)
    }

    func familyTripsUpdated(notification: NSNotification) {
        updateNumberOfRows()
        listView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
    }

    // MARK: ASTableView

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return numberOfRoutes == 0 ? 0 : numberOfRoutes + 2
        case 2: return 2
        default: return 0
        }
    }

    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        switch indexPath.section {
        case 0:
            switch indexPath.row {

            // Trip dates
            case 0:
                if DataModel.sharedInstance.specialProject.startDate.compare(NSDate(timeIntervalSince1970: 0)) != NSComparisonResult.OrderedSame && DataModel.sharedInstance.specialProject.endDate.compare(NSDate(timeIntervalSince1970: 0)) != NSComparisonResult.OrderedSame {
                    let formatter = NSDateFormatter()
                    formatter.dateFormat = "d MMMM"
                    let startDate = formatter.stringFromDate(DataModel.sharedInstance.specialProject.startDate)
                    formatter.dateFormat = "d MMMM y"
                    let endDate = formatter.stringFromDate(DataModel.sharedInstance.specialProject.endDate)
                    let titleParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), NSForegroundColorAttributeName: UIColor.lightGrayColor()]
                    let attrStr = NSAttributedString(string: "\(startDate) – \(endDate)".uppercaseString, attributes: titleParams)
                    let node = TripTextCell(text: attrStr)
                    return node
                } else {
                    return ASCellNode()
                }

            // Countdown
            case 1:
                if DataModel.sharedInstance.specialProject.countdown {
                    return TripCountdownNode(date: DataModel.sharedInstance.specialProject.startDate)
                } else {
                    return ASCellNode()
                }
            default: return ASCellNode()
            }
        case 1:
            if numberOfRoutes == 0 {
                return ASCellNode()
            } else {
                switch indexPath.row {

                // Family trip routes title
                case 0:
                    let node = EventDescTitleNode(text: NSLocalizedString("Family trip routes", comment: "Family trip routes title"))
                    return node

                // Empty node
                case (numberOfRoutes + 1):
                    return EmptyNode(height: 50.0)

                default:
                    let prospectedIndex = indexPath.row - 1
                    if prospectedIndex >= 0 && prospectedIndex < DataModel.sharedInstance.familyTrips.count {
                        let familyTrip = DataModel.sharedInstance.familyTrips[prospectedIndex]
                        let familyTripNode = FamilyTripNode(title: familyTrip.name, ageFrom: familyTrip.ageFrom, ageTo: familyTrip.ageTo, image: familyTrip.previewImage ?? KImage())
                        return familyTripNode
                    } else {
                        return ASCellNode()
                    }
                }
            }
        case 2:
            switch indexPath.row {

            // Trip rules heading
            case 0:
            let titleParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
            let attrStr = NSAttributedString(string: NSLocalizedString("Trip rules", comment: "Family trip rules heading"), attributes: titleParams)
            let node = TripTextCell(text: attrStr)
            return node

            // Trip rules
            case 1:
            return FamilyTripRulesNode(rules: DataModel.sharedInstance.familyTripRules)

            default: return ASCellNode()
            }
        default: return ASCellNode()
        }
    }

    func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        if indexPath.section == 1 {
            let prospectedIndex = indexPath.row - 1
            if prospectedIndex >= 0 && prospectedIndex < DataModel.sharedInstance.familyTrips.count {
                return true
            }
        }
        return false
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.listView.deselectRowAtIndexPath(indexPath, animated: false)
        }

        if indexPath.section == 1 {
            let prospectedIndex = indexPath.row - 1
            if prospectedIndex >= 0 && prospectedIndex < DataModel.sharedInstance.familyTrips.count {
                let familyTrip = DataModel.sharedInstance.familyTrips[prospectedIndex]
                let tripController = FamilyTripViewController(nibName: nil, bundle: nil)
                tripController.trip = familyTrip
                navigationController?.pushViewController(tripController, animated: true)
            }
        }
    }
}
