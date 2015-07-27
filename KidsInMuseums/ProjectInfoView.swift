//
//  ProjectInfoView.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 28.07.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import UIKit

class ProjectInfoView: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    let asTableView = ASTableView()

    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.view.addSubview(asTableView)

        asTableView.asyncDataSource = self
        asTableView.asyncDelegate = self
        asTableView.separatorStyle = .None

        self.title = NSLocalizedString("About the project", comment: "")
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
        case 0:
            return AppInfoNode(text: "text")
        case 1: return EventDescTitleNode(text: NSLocalizedString("Project team", comment: "About the project team section title"))
        case 2: return DeveloperInfoNode(image: UIImage(named: "sophia-pantyulina.jpg")!, text: NSLocalizedString("Sophia Pantyulina, project creator", comment: "Sophia Pantyulina"))
        case 3: return DeveloperInfoNode(image: UIImage(named: "irina-novichkova.jpg")!, text: NSLocalizedString("Irina Novichkova, project coordinator", comment: "Irina Novichkova"))
        case 4: return DeveloperInfoNode(image: UIImage(named: "yulia-smolchenko.jpg")!, text: NSLocalizedString("Yulia Smolchenko, media support", comment: "Yulia Smolchenko"))
        default: fatalError("Invalid row number")
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        switch (indexPath.row) {
        case 0:
            if let url = NSURL(string: "mailto:support@golovamedia.ru") {
                UIApplication.sharedApplication().openURL(url)
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        case 2:
            if let url = NSURL(string: "http://www.golovamedia.ru") {
                UIApplication.sharedApplication().openURL(url)
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        default: break
        }
    }
}
