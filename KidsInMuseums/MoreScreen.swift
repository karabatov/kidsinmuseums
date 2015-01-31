//
//  MoreScreen.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 31.01.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class MoreScreen: UITableViewController {
    var searchCell = UITableViewCell()
    var familyTripCell = UITableViewCell()
    var aboutProjectCell = UITableViewCell()
    var aboutAppCell = UITableViewCell()
    var facebookCell = UITableViewCell()
    var vkCell = UITableViewCell()

    override required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override required init(style: UITableViewStyle) {
        super.init(style: style)
        title = NSLocalizedString("More", comment: "More controller title")
        tabBarItem = UITabBarItem(title: title, image: UIImage(named: "icon-more"), tag: 0)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        searchCell.textLabel?.text = NSLocalizedString("Search", comment: "Search")
        searchCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        familyTripCell.textLabel?.text = NSLocalizedString("Family trip", comment: "Family trip")
        familyTripCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        aboutProjectCell.textLabel?.text = NSLocalizedString("About the project", comment: "About the project")
        aboutProjectCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        aboutAppCell.textLabel?.text = NSLocalizedString("About the app", comment: "About the app")
        aboutAppCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        facebookCell.textLabel?.text = NSLocalizedString("Facebook", comment: "Facebook")
        vkCell.textLabel?.text = NSLocalizedString("Vkontakte", comment: "Vkontakte")
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0: return 4
        case 1: return 2
        default: fatalError("Unknown section")
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
            case 0: return searchCell
            case 1: return familyTripCell
            case 2: return aboutProjectCell
            case 3: return aboutAppCell
            default: fatalError("Unknown row")
            }
        case 1:
            switch (indexPath.row) {
            case 0: return facebookCell
            case 1: return vkCell
            default: fatalError("Unknown row")
            }
        default: fatalError("Unknown section")
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 0: return nil
        case 1: return NSLocalizedString("Connect with us on social networks", comment: "Social networks section")
        default: fatalError("Unknown section")
        }
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch (section) {
        case 0: return CGFloat.min
        case 1: return UITableViewAutomaticDimension
        default: fatalError("Unknown section")
        }
    }
}
