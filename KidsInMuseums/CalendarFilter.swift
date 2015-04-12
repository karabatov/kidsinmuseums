//
//  CalendarFilter.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 12.04.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class CalendarFilter: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    let listDays = ASTableView()
    let days: [NSDate]
    let dateFormatter = NSDateFormatter()
    var selectedDays = [NSDate]()

    required init(days: [NSDate]) {
        self.days = days
        super.init(nibName: nil, bundle: nil)
        edgesForExtendedLayout = UIRectEdge.None
        title = NSLocalizedString("Calendar", comment: "Calendar filter title")

        // TODO: Add weekday to date format string
        dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("dMMMM", options: 0, locale: NSLocale.currentLocale())

        listDays.allowsSelection = true
        listDays.asyncDataSource = self
        listDays.asyncDelegate = self

        view.addSubview(listDays)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        listDays.frame = view.bounds
    }

    // MARK: - ASTableView delegate

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        if days.count > indexPath.row {
            let day = days[indexPath.row]
            let dayNode = DayFilterNode(text: dateFormatter.stringFromDate(day))
            dayNode.selected = contains(selectedDays, day)
            return dayNode
        }
        return ASCellNode()
    }

    func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if days.count > indexPath.row {
            var selected: Bool
            let day = days[indexPath.row]
            if contains(selectedDays, day) {
                selected = false
                if let index = find(selectedDays, day) {
                    selectedDays.removeAtIndex(index)
                }
            } else {
                selected = true
                selectedDays.append(day)
            }
            for node in listDays.visibleNodes() {
                if let dayNode = node as? DayFilterNode {
                    if dayNode.text == dateFormatter.stringFromDate(day) {
                        dayNode.selected = selected
                        break
                    }
                }
            }
        }
    }
}
