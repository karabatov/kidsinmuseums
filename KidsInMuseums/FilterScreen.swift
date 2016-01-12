//
//  FilterScreen.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 07.04.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import CoreLocation

enum FilterScreenMode {
    case Tags, Museums, Search
}

class FilterScreen: UIViewController, ASTableViewDataSource, ASTableViewDelegate, UISearchBarDelegate {
    var filterScreenMode = FilterScreenMode.Tags {
        didSet {
            filterScreenModeSet(filterScreenMode)
        }
    }
    let tagButton: FilterButton
    let museumButton: FilterButton
    let searchBar = UISearchBar()
    let listTags = ASTableView()
    let listMuseums = ASTableView()
    let listSearch = ASTableView()
    var tagCloudNode: TagCloudNode?
    var ageCloudNode: AgeCloudNode?
    var filterButtonV: CGFloat = 0.0
    let searchBarV: CGFloat = 44.0
    var museums = [Museum]()
    var selectedMuseums = [Int]()
    var location: CLLocation?
    var searchMuseums: [Museum] = []
    var searchEvents: [Event] = []

    override required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        let tagText = NSLocalizedString("Tags", comment: "Filter by tags")
        let museumText = NSLocalizedString("Museums", comment: "Filter by museums")

        tagButton = FilterButton(text: tagText)
        tagButton.selected = true
        museumButton = FilterButton(text: museumText)

        museums = DataModel.sharedInstance.museums.sort({ (m1: Museum, m2: Museum) -> Bool in
            return m1.name < m2.name
        })
        let museumsFiltered = DataModel.sharedInstance.filter.museums
        if !museumsFiltered.isEmpty {
            selectedMuseums = museumsFiltered
        }
        searchMuseums = museums
        searchEvents = DataModel.sharedInstance.allEvents

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
        listMuseums.separatorStyle = UITableViewCellSeparatorStyle.None
        listMuseums.asyncDataSource = self
        listMuseums.asyncDelegate = self
        listMuseums.hidden = true
        listSearch.separatorStyle = UITableViewCellSeparatorStyle.None
        listSearch.backgroundColor = UIColor.whiteColor()
        listSearch.asyncDataSource = self
        listSearch.asyncDelegate = self
        listSearch.hidden = true

        searchBar.delegate = self
        searchBar.tintColor = UIColor.kimColor()
        searchBar.placeholder = NSLocalizedString("Place or event", comment: "Search bar placeholder")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        let offset = filterButtonV + searchBarV
        self.listTags.frame = CGRectMake(0, offset, view.bounds.width, view.bounds.height - offset)
        self.listMuseums.frame = CGRectMake(0, offset, view.bounds.width, view.bounds.height - offset)
        self.listSearch.frame = CGRectMake(0, offset, view.bounds.width, view.bounds.height - offset)
    }

    override func viewDidLoad() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let halfWidth = UIScreen.mainScreen().applicationFrame.size.width / 2.0
            self.filterButtonV = self.tagButton.measure(CGSizeMake(halfWidth, 0.0)).height
            self.museumButton.measure(CGSizeMake(UIScreen.mainScreen().applicationFrame.size.width / 2.0, 0.0)).height
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.view.addSubview(self.tagButton.view)
                self.view.addSubview(self.museumButton.view)
                self.view.addSubview(self.searchBar)
                self.view.addSubview(self.listTags)
                self.view.addSubview(self.listMuseums)
                self.view.addSubview(self.listSearch)
                self.tagButton.frame = CGRectMake(0, 0, halfWidth, self.filterButtonV)
                self.museumButton.frame = CGRectMake(halfWidth, 0, halfWidth, self.filterButtonV)
                self.searchBar.frame = CGRect(x: 0, y: self.filterButtonV, width: halfWidth * 2, height: self.searchBarV)
            })
        })

        if let clearButton: UIButton = UIButton(type: UIButtonType.System) as? UIButton {
            clearButton.setTitle(NSLocalizedString(" Clear", comment: "Clear button title"), forState: UIControlState.Normal)
            clearButton.setImage(UIImage(named: "icon-clear"), forState: UIControlState.Normal)
            clearButton.addTarget(self, action: "clearButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            clearButton.sizeToFit()
            let leftBarItem = UIBarButtonItem(customView: clearButton)
            navigationItem.leftBarButtonItem = leftBarItem
        }
        if let applyButton: UIButton = UIButton(type: UIButtonType.System) as? UIButton {
            applyButton.setTitle(NSLocalizedString("Apply", comment: "Apply filter button title"), forState: UIControlState.Normal)
            applyButton.addTarget(self, action: "applyButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            applyButton.sizeToFit()
            let rightBarItem = UIBarButtonItem(customView: applyButton)
            navigationItem.rightBarButtonItem = rightBarItem
        }
    }

    func filterButtonTapped(sender: FilterButton) {
        switch sender {
        case tagButton:
            filterScreenMode = .Tags
        case museumButton:
            filterScreenMode = .Museums
        default: NSLog("UGH")
        }
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
                if DataModel.sharedInstance.tags.count > 0 {
                    let node = EventDescTitleNode(text: NSLocalizedString("Event subjects", comment: "Event topics title"))
                    return node
                } else {
                    return ASCellNode()
                }
            case 3:
                if let node = tagCloudNode {
                    return node
                } else {
                    tagCloudNode = TagCloudNode(tags: DataModel.sharedInstance.tags, enabled: true)
                    return tagCloudNode
                }
            default: return ASCellNode()
            }
        case listMuseums:
            let museum = museums[indexPath.row]
            let museumNode = FilterMuseumNode(museum: museum, location: location)
            if selectedMuseums.contains(museum.id) {
                museumNode.selected = true
            }
            return museumNode
        case listSearch:
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 0:
                    if searchEvents.count > 0 {
                        let found = NSLocalizedString("Events found: ", comment: "Search section for events")
                        return EventDescTitleNode(text: found + String(searchEvents.count))
                    } else {
                        return EventDescTitleNode(text: NSLocalizedString("Events not found", comment: "Search section for events when not found"))
                    }
                default:
                    let event = searchEvents[indexPath.row - 1]
                    let eventNode = EventCell(event: event, filterMode: EventFilterMode.Distance, referenceDate: NSDate(), location: location)
                    return eventNode
                }
            case 1:
                switch indexPath.row {
                case 0:
                    if searchMuseums.count > 0 {
                        let found = NSLocalizedString("Museums found: ", comment: "Search section for museums")
                        return EventDescTitleNode(text: found + String(searchMuseums.count))
                    } else {
                        return EventDescTitleNode(text: NSLocalizedString("Museums not found", comment: "Search section for museums when not found"))
                    }
                default:
                    let museum = searchMuseums[indexPath.row - 1]
                    let museumNode = FilterMuseumNode(museum: museum, location: location)
                    museumNode.accessoryNode.hidden = true
                    return museumNode
                }
            default: return ASCellNode()
            }
        default: return ASCellNode()
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case listTags: return 4
        case listMuseums: return museums.count
        case listSearch:
            switch section {
            case 0: return searchEvents.count > 0 ? searchEvents.count + 1 : 1
            case 1: return searchMuseums.count > 0 ? searchMuseums.count + 1 : 1
            default: return 0
            }
        default: return 0
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        if tableView == listSearch {
            return 2
        }
        return 1
    }

    func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        if tableView == listTags {
            return false
        }
        return true
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var selected: Bool
        if tableView == listMuseums {
            let museum = museums[indexPath.row]
            if selectedMuseums.contains(museum.id) {
                selected = false
                if let index = selectedMuseums.indexOf(museum.id) {
                    selectedMuseums.removeAtIndex(index)
                }
            } else {
                selected = true
                selectedMuseums.append(museum.id)
            }
            for node in listMuseums.visibleNodes() {
                if let museumNode = node as? FilterMuseumNode {
                    if museumNode.museum.id == museum.id {
                        museumNode.selected = selected
                    }
                }
            }
        }
        if tableView == listSearch {
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 0: return
                default:
                    let event = searchEvents[indexPath.row - 1]
                    openEvent(event)
                }
            case 1:
                switch indexPath.row {
                case 0: return
                default:
                    let museum = searchMuseums[indexPath.row - 1]
                    openMuseum(museum)
                }
            default: return
            }
        }
    }

    func clearButtonTapped(sender: UIButton) {
        tagCloudNode?.clearSelectedTags()
        ageCloudNode?.clearSelectedAges()
        selectedMuseums = []
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.listMuseums.reloadData()
        })
    }

    func applyButtonTapped(sender: UIButton) {
        let currentFilterDays = DataModel.sharedInstance.filter.days
        if let
            ageRanges = ageCloudNode?.selectedAges,
            tags = tagCloudNode?.selectedTags {
                let filter = Filter(ageRanges: ageRanges, tags: tags, museums: selectedMuseums, days: currentFilterDays)
                DataModel.sharedInstance.filter = filter
        }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })
    }

    func filterScreenModeSet(newMode: FilterScreenMode) {
        switch newMode {
        case .Tags:
            tagButton.selected = true
            museumButton.selected = false
            listTags.hidden = false
            listMuseums.hidden = true
            listSearch.hidden = true
        case .Museums:
            tagButton.selected = false
            museumButton.selected = true
            listTags.hidden = true
            listMuseums.hidden = false
            listSearch.hidden = true
        case .Search:
            listTags.hidden = true
            listMuseums.hidden = true
            listSearch.hidden = false
            searchBar.becomeFirstResponder()
        }
    }

    // MARK: UISearchBarDelegate

    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if let searchText = searchBar.text where !searchText.isEmpty {
                startSearchWithText(searchText)
                return false
            } else {
                searchBarCancelButtonClicked(searchBar)
            }
        }
        return true
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.setShowsCancelButton(!searchText.isEmpty || searchBar.isFirstResponder(), animated: true)
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        if tagButton.selected {
            filterScreenMode = .Tags
        } else {
            filterScreenMode = .Museums
        }
        searchEvents = DataModel.sharedInstance.allEvents
        searchMuseums = museums
        listSearch.reloadData()
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        filterScreenMode = .Search
    }

    func startSearchWithText(text: String) {
        let comps = text.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        searchMuseums = museums.filter() { museum in
            for substr in comps {
                if let range = museum.name.lowercaseString.rangeOfString(substr.lowercaseString) {
                    return true
                }
            }
            return false
        }

        searchEvents = DataModel.sharedInstance.allEvents.filter() { event in
            for substr in comps {
                if let range = event.name.lowercaseString.rangeOfString(substr.lowercaseString) {
                    return true
                }
            }
            return false
        }

        searchBar.resignFirstResponder()
        listSearch.reloadData()
    }

    func openMuseum(museum: Museum) {
        let vc = MuseumInfoController()
        vc.museum = museum
        navigationController?.pushViewController(vc, animated: true)
    }

    func openEvent(event: Event) {
        let vc = EventItemViewController(event: event, frame: view.bounds)
        navigationController?.pushViewController(vc, animated: true)
    }
}
