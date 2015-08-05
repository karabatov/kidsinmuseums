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
    var numberOfRows = 5

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

        self.view.addSubview(listView)
        listView.directionalLockEnabled = true
        listView.separatorStyle = UITableViewCellSeparatorStyle.None;
        listView.backgroundColor = UIColor.clearColor()
        listView.asyncDelegate = self
        listView.asyncDataSource = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "familyTripRulesUpdated:", name: kKIMNotificationFamilyTripRulesUpdated, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewWillLayoutSubviews() {
        let b = self.view.bounds
        if (listView.frame != b) {
            listView.frame = b
            listView.reloadData()
        }
    }

    func familyTripRulesUpdated(notification: NSNotification) {
        listView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
    }

    // MARK: ASTableView

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }

    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
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

        // Trip rules heading
        case 1:
            let titleParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
            let attrStr = NSAttributedString(string: NSLocalizedString("Trip rules", comment: "Family trip rules heading"), attributes: titleParams)
            let node = TripTextCell(text: attrStr)
            return node

        // Trip rules
        case 2:
            return FamilyTripRulesNode(rules: DataModel.sharedInstance.familyTripRules)

        // Countdown
        case 3:
            if DataModel.sharedInstance.specialProject.countdown {
                return ASCellNode()
            } else {
                return ASCellNode()
            }

        // Family trip routes title
        case 4:
            let node = EventDescTitleNode(text: NSLocalizedString("Family trip routes", comment: "Family trip routes title"))
            return node
        default:
            return ASCellNode()
        }
    }

    func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return false
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.listView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
}
