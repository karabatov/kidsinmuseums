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
    var numberOfRows = 0

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(event: Event) {
        self.event = event
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: "Navbar back button title"), style: .Plain, target: nil, action: nil)
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | .FlexibleWidth
        self.view.backgroundColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = UIRectEdge.None
        let b = self.view.bounds
        listView.frame = b
        view.addSubview(listView)
        listView.separatorStyle = UITableViewCellSeparatorStyle.None
        listView.backgroundColor = UIColor.whiteColor()

        // Calculate the number of rows
        numberOfRows += 1 // 6 rows are always present
        // Here be reviews calculation

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
        default:
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
}
