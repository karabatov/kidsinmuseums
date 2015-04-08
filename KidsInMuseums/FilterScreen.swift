//
//  FilterScreen.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 07.04.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

enum FilterScreenMode {
    case Tags, Museums
}

class FilterScreen: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    let myToolbar = UIToolbar()
    let tagButton: FilterButton
    let museumButton: FilterButton
    let listTags = ASTableView()
    var tagCloudNode: TagCloudNode?
    var ageCloudNode: AgeCloudNode?
    var filterButtonV: CGFloat = 0.0

    override required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        let tagText = NSLocalizedString("Tags", comment: "Filter by tags")
        let museumText = NSLocalizedString("Museums", comment: "Filter by museums")

        tagButton = FilterButton(text: tagText)
        tagButton.selected = true
        museumButton = FilterButton(text: museumText)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        edgesForExtendedLayout = UIRectEdge.None
        title = NSLocalizedString("Filter", comment: "Filter screen title")
        view.opaque = true
        view.backgroundColor = UIColor.whiteColor()
        tagButton.addTarget(self, action: "filterButtonTapped:", forControlEvents: ASControlNodeEvent.TouchUpInside)
        museumButton.addTarget(self, action: "filterButtonTapped:", forControlEvents: ASControlNodeEvent.TouchUpInside)

        listTags.separatorStyle = UITableViewCellSeparatorStyle.None
        listTags.asyncDataSource = self
        listTags.asyncDelegate = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let halfWidth = UIScreen.mainScreen().applicationFrame.size.width / 2.0
            self.filterButtonV = self.tagButton.measure(CGSizeMake(halfWidth, 0.0)).height
            self.museumButton.measure(CGSizeMake(UIScreen.mainScreen().applicationFrame.size.width / 2.0, 0.0)).height
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.view.addSubview(self.tagButton.view)
                self.view.addSubview(self.museumButton.view)
                self.view.addSubview(self.listTags)
                self.tagButton.frame = CGRectMake(0, 0, halfWidth, self.filterButtonV)
                self.museumButton.frame = CGRectMake(halfWidth, 0, halfWidth, self.filterButtonV)
                self.listTags.frame = CGRectMake(0, self.filterButtonV, UIScreen.mainScreen().applicationFrame.size.width, UIScreen.mainScreen().applicationFrame.size.height - self.filterButtonV)
            })
        })

        if let clearButton: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton {
            clearButton.setTitle(NSLocalizedString(" Clear", comment: "Clear button title"), forState: UIControlState.Normal)
            clearButton.setImage(UIImage(named: "icon-clear"), forState: UIControlState.Normal)
            clearButton.addTarget(self, action: "clearButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            clearButton.sizeToFit()
            let leftBarItem = UIBarButtonItem(customView: clearButton)
            navigationItem.leftBarButtonItem = leftBarItem
        }
        let rightBarItem = UIBarButtonItem(title: NSLocalizedString("Apply", comment: "Apply filter button title"), style: UIBarButtonItemStyle.Plain, target: self, action: "applyButtonTapped:")
        navigationItem.rightBarButtonItem = rightBarItem
    }

    func filterButtonTapped(sender: FilterButton) {
        switch sender {
        case tagButton:
            museumButton.selected = !tagButton.selected
        case museumButton:
            tagButton.selected = !museumButton.selected
        default: NSLog("UGH")
        }
        listTags.hidden = !tagButton.selected
    }

    // MARK: ASTableView

    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        switch tableView {
        case listTags:
            switch indexPath.row {
            case 0:
                let node = EventDescTitleNode(text: NSLocalizedString("Age", comment: "Age title"))
                return node
            case 1:
                if let node = ageCloudNode {
                    return node
                } else {
                    ageCloudNode = AgeCloudNode()
                    return ageCloudNode
                }
            case 2:
                let node = EventDescTitleNode(text: NSLocalizedString("Event subjects", comment: "Event topics title"))
                return node
            case 3:
                if let node = tagCloudNode {
                    return node
                } else {
                    tagCloudNode = TagCloudNode(tags: DataModel.sharedInstance.tags)
                    return tagCloudNode
                }
            default: return ASCellNode()
            }
        default: return ASCellNode()
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case listTags: return 4
        default: return 0
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return false
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    }

    func clearButtonTapped(sender: UIButton) {
        tagCloudNode?.clearSelectedTags()
        ageCloudNode?.clearSelectedAges()
    }

    func applyButtonTapped(sender: UIButton) {
        NSLog("Apply button tapped")
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })
    }
}
