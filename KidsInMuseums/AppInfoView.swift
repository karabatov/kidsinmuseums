//
//  AppInfoView.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 17.03.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class AppInfoView: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    let asTableView = ASTableView()

    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.view.addSubview(asTableView)

        asTableView.asyncDataSource = self
        asTableView.asyncDelegate = self
        asTableView.separatorStyle = .None

        self.title = NSLocalizedString("About the app", comment: "")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        asTableView.frame = self.view.frame
    }

    // MARK: ASTableView

    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        switch (indexPath.row) {
        case 0: return AppInfoNode()
        case 1: return EventDescTitleNode(text: NSLocalizedString("Developer", comment: "About the developer section title"))
        default: fatalError("Invalid row number")
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        switch (indexPath.row) {
        case 0:
            if let url = NSURL(string: "mailto:support@golovamedia.ru") {
                UIApplication.sharedApplication().openURL(url)
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        default: break
        }
    }
}
