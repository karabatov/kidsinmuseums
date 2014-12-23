//
//  NewsListViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 20.12.14.
//  Copyright (c) 2014 Golova Media. All rights reserved.
//

import Foundation
import UIKit

class NewsListController: UIViewController, ASTableViewDelegate, ASTableViewDataSource {
    var listView = ASTableView()
    var newsItems: [NewsItem] = [NewsItem]()
    var refreshControl: UIRefreshControl?
    var bgView = NoDataView()

    // MARK: UIViewController

    override func viewDidLoad() {
        title = NSLocalizedString("News", comment: "News controller title")
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | .FlexibleWidth
        self.view.backgroundColor = UIColor.whiteColor()
        let b = self.view.bounds
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.bgView.measure(b.size)
            self.bgView.frame = b
            dispatch_async(dispatch_get_main_queue(), {
                self.view.addSubview(self.bgView.view)
                self.view.sendSubviewToBack(self.bgView.view)
            })
        })
        self.view.addSubview(listView)
        listView.separatorStyle = UITableViewCellSeparatorStyle.None;
        listView.backgroundColor = UIColor.clearColor()
        listView.asyncDelegate = self
        listView.asyncDataSource = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newsItemsUpdated:", name: kKIMNotificationNewsUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newsItemsUpdateFailed:", name: kKIMNotificationNewsUpdated, object: nil)
        // DataModel.sharedInstance.updateNews()
    }

    override func viewWillLayoutSubviews() {
        let b = self.view.bounds
        listView.frame = b
        self.bgView.measure(b.size)
        self.bgView.frame = b
        listView.reloadData()
    }

    override func viewDidAppear(animated: Bool) {
        if (refreshControl == nil) {
            refreshControl = UIRefreshControl()
            refreshControl?.backgroundColor = UIColor(red: 127.0/255.0, green: 86.0/255.0, blue: 149.0/255.0, alpha: 1.0)
            refreshControl?.tintColor = UIColor.whiteColor()
            refreshControl?.addTarget(self, action: "updateNews", forControlEvents: UIControlEvents.ValueChanged)
            listView.addSubview(refreshControl!)
            listView.sendSubviewToBack(refreshControl!)
        }
    }

    // MARK: Data

    func updateNews() {
        DataModel.sharedInstance.updateNews()
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

    // MARK: ASTableView

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }

    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        let news = newsItems[indexPath.row]
        let node = NewsCell(newsItem: news)
        return node
    }

    func tableView(tableView: UITableView!, shouldHighlightRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return false
    }
}