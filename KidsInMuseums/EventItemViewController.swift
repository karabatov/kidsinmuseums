//
//  EventItemViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 09.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class EventItemViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    let event: Event
    let listView = ASTableView()
    var reviews = [Review]()
    var numberOfRows = 0
    var smallFrame: CGRect

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(event: Event, frame b: CGRect) {
        self.event = event
        if reviews.count > 0 {
            self.reviews.extend(reviews)
            self.reviews.sort({(r1: Review, r2: Review) -> Bool in
                return r1.createdAt.compare(r2.createdAt) == NSComparisonResult.OrderedAscending
            })
        }
        smallFrame = b
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: "Navbar back button title"), style: .Plain, target: nil, action: nil)
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | .FlexibleWidth
        self.view.backgroundColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = UIRectEdge.None
        listView.frame = smallFrame
        view.addSubview(listView)
        listView.separatorStyle = UITableViewCellSeparatorStyle.None
        listView.backgroundColor = UIColor.whiteColor()

        // Calculate the number of rows
        numberOfRows += 7 // 7 rows are always present
        if reviews.count > 0 {
            numberOfRows++
            numberOfRows += reviews.count
        }

        listView.asyncDataSource = self
        listView.asyncDelegate = self
    }

    // MARK: ASTableView

    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        switch indexPath.row {
        case 0:
            if let image = event.previewImage {
                let imageNode = EventImageNode(image: image)
                return imageNode
            }
        case 1:
            let titleNode = EventTitleNode(name: event.name, ageFrom: event.ageFrom, ageTo: event.ageTo)
            return titleNode
        case 2:
            let museumNode = EventMuseumNode(museumId: event.museumUserId)
            return museumNode
        case 3:
            let timeNode = EventScheduleNode(event: event)
            return timeNode
        case 4:
            let descNode = EventDescTitleNode(text: NSLocalizedString("Description", comment: "Event screen description subtitle"))
            return descNode
        case 5:
            let textNode = EventDescriptionNode(description: event.description)
            return textNode
        case 6:
            let tagNode = TagCloudNode(tags: event.tags)
            return tagNode
        case 7:
            let reviewTitleNode = EventDescTitleNode(text: NSLocalizedString("Reviews", comment: "Review section description subtitle"))
            return reviewTitleNode
        default:
            if reviews.count > indexPath.row - 8 {
                let review = reviews[indexPath.row - 8]
                let reviewNode = EventReviewNode(review: review)
                return reviewNode
            }
            return ASCellNode()
        }
        return ASCellNode()
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }

    func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return false
    }
}
