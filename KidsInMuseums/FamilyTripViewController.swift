//
//  FamilyTripViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 05.08.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import UIKit

class FamilyTripViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    var trip = FamilyTrip() {
        didSet {
            title = trip.name
            numberOfRows = baseNumberOfRows + ((trip.museums.count > 0) ? trip.museums.count + 2 : 0)
            if listView.asyncDataSource != nil && listView.asyncDelegate != nil {
                listView.reloadData()
            }
        }
    }
    let listView = ASTableView()
    let baseNumberOfRows = 4
    var numberOfRows = 4

    override required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, .FlexibleWidth]
        self.view.backgroundColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = UIRectEdge.None

        self.view.addSubview(listView)
        listView.directionalLockEnabled = true
        listView.separatorStyle = UITableViewCellSeparatorStyle.None;
        listView.backgroundColor = UIColor.clearColor()
        listView.asyncDelegate = self
        listView.asyncDataSource = self
    }

    override func viewWillLayoutSubviews() {
        let b = self.view.bounds
        if (listView.frame != b) {
            listView.frame = b
            listView.reloadData()
        }
    }

    // MARK: ASTableView

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }

    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        switch indexPath.row {
        case 0:
            if let image = trip.previewImage {
                let imageNode = EventImageNode(image: image)
                return imageNode
            }
        case 1:
            let titleNode = EventTitleNode(name: trip.name, ageFrom: trip.ageFrom, ageTo: trip.ageTo)
            return titleNode
        case 2:
            if !trip.timeText.isEmpty || !trip.timeComment.isEmpty {
                let timeNode = TripScheduleNode(text: trip.timeText, comment: trip.timeComment)
                return timeNode
            }
        case 3:
            let descCell = EventDescriptionNode(description: trip.description)
            return descCell
        case 4:
            let museumsTitleCell = EventDescTitleNode(text: NSLocalizedString("Route museums", comment: "Section title for family trip museum list"))
            return museumsTitleCell
        default:
            let prospectedIndex = indexPath.row - (baseNumberOfRows + 1)
            if prospectedIndex >= 0 && prospectedIndex < trip.museums.count {
                let museumNode = TripMuseumNode(museumId: trip.museums[prospectedIndex], trip: trip)
                return museumNode
            } else {
                return EmptyNode(height: 50.0)
            }
        }

        return ASCellNode()
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

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
}
