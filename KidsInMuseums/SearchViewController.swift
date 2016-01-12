//
//  SearchViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 19.06.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, ASTableViewDelegate, ASTableViewDataSource {
    let searchBar = UISearchBar()
    let listSearch = ASTableView()
    var searchEvents: [Event] = DataModel.sharedInstance.allEvents
    let museums = DataModel.sharedInstance.museums.sort({ (m1: Museum, m2: Museum) -> Bool in
        return m1.name < m2.name
    })
    var searchMuseums: [Museum] = []
    let searchBarV: CGFloat = 44.0

    override func viewDidLoad() {
        super.viewDidLoad()

        searchMuseums = museums

        title = NSLocalizedString("Search", comment: "Search controller title")

        edgesForExtendedLayout = UIRectEdge.None

        listSearch.separatorStyle = UITableViewCellSeparatorStyle.None
        listSearch.backgroundColor = UIColor.whiteColor()
        listSearch.asyncDataSource = self
        listSearch.asyncDelegate = self

        searchBar.delegate = self
        searchBar.tintColor = UIColor.kimColor()
        searchBar.placeholder = NSLocalizedString("Place or event", comment: "Search bar placeholder")

        view.addSubview(searchBar)
        view.addSubview(listSearch)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        searchBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: searchBarV)
        listSearch.frame = CGRect(x: 0, y: searchBarV, width: view.bounds.width, height: view.bounds.height - searchBarV)
    }

    // MARK: ASTableView

    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
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
                let eventNode = EventCell(event: event, filterMode: EventFilterMode.Distance, referenceDate: NSDate(), location: nil)
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
                let museumNode = FilterMuseumNode(museum: museum, location: nil)
                museumNode.accessoryNode.hidden = true
                return museumNode
            }
        default: return ASCellNode()
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return searchEvents.count > 0 ? searchEvents.count + 1 : 1
        case 1: return searchMuseums.count > 0 ? searchMuseums.count + 1 : 1
        default: return 0
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 2
    }

    func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
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
        searchEvents = DataModel.sharedInstance.allEvents
        searchMuseums = museums
        listSearch.reloadData()
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
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
