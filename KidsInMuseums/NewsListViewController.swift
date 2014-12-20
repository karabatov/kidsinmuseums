//
//  NewsListViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 20.12.14.
//  Copyright (c) 2014 Golova Media. All rights reserved.
//

import Foundation
import UIKit

class NewsListController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    var listView = UITableView()
    var newsItems: [NewsItem] = [NewsItem]()

    override func viewDidLoad() {
        title = NSLocalizedString("News", comment: "News controller title")
        self.view.backgroundColor = UIColor.whiteColor()
        self.tableView = listView
        listView.setTranslatesAutoresizingMaskIntoConstraints(false)
        listView.registerClass(NewsListCell.self, forCellReuseIdentifier: NewsListCell.reuseIdentifier())
        listView.delegate = self
        listView.dataSource = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newsItemsUpdated:", name: kKIMNotificationNewsUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newsItemsUpdateFailed:", name: kKIMNotificationNewsUpdated, object: nil)
        DataModel.sharedInstance.updateNews()
        var refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(red: 127.0/255.0, green: 86.0/255.0, blue: 149.0/255.0, alpha: 1.0)
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: "updateNews", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }

    func updateNews() {
        DataModel.sharedInstance.updateNews()
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        //
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let news = newsItems[indexPath.row]
        return NewsListCell.sharedCell.heightForCellWithNewsItem(news) + 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (newsItems.count == 0) {
            var messageLabel = UILabel()
            messageLabel.text = NSLocalizedString("No data is currently available. Please pull down to refresh.", comment: "Message when there is no data in the news table view")
            messageLabel.textColor = UIColor.blackColor()
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .Center;
            messageLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            messageLabel.sizeToFit()

            listView.backgroundView = messageLabel;
            listView.separatorStyle = UITableViewCellSeparatorStyle.None;
        }
        else {
            listView.backgroundView = nil;
            listView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }
        return newsItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let news = newsItems[indexPath.row]
        var newsCell = tableView.dequeueReusableCellWithIdentifier(NewsListCell.reuseIdentifier(), forIndexPath: indexPath)
         as NewsListCell
        newsCell.configureWithNewsItem(news)
        return newsCell
    }

    func newsItemsUpdated(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.refreshControl?.endRefreshing()
            self.newsItems = DataModel.sharedInstance.news
            self.listView.reloadData()
        }
    }

    func newsItemsUpdateFailed(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.refreshControl?.endRefreshing()
            return
        }
    }
}