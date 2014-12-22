//
//  NewsListViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 20.12.14.
//  Copyright (c) 2014 Golova Media. All rights reserved.
//

import Foundation
import UIKit

let kNoDataViewMargin: CGFloat = 45.0

class NewsListController: UIViewController, ASTableViewDelegate, ASTableViewDataSource {
    var listView = ASTableView()
    var newsItems: [NewsItem] = [NewsItem]()
    var refreshControl: UIRefreshControl?
    var bgView: ASTextNode?
    var bgQ: dispatch_queue_t = dispatch_queue_create("concurrent queue", DISPATCH_QUEUE_CONCURRENT)

    // MARK: UIViewController

    override func viewDidLoad() {
        title = NSLocalizedString("News", comment: "News controller title")
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | .FlexibleWidth
        self.view.backgroundColor = UIColor.whiteColor()
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
        self.listView.frame = self.view.bounds
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
        updateBackgroundView()
    }

    func updateBackgroundView() {
        if (newsItems.count != 0) {
            return
        }
        if let bgV = bgView {
            dispatch_async(bgQ, { () -> Void in
                let lvf = self.listView.bounds
                let textSize = bgV.measure(CGSizeMake(lvf.width - 2 * kNoDataViewMargin, CGFloat.max))
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    bgV.frame = CGRectMake(kNoDataViewMargin, (lvf.height - textSize.height) / 2.0, textSize.width, textSize.height)
                })
            })
            return
        }
        dispatch_async(bgQ, { () -> Void in
            let bgV = ASTextNode()
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .Center
            let attributes = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSParagraphStyleAttributeName : paragraph]
            bgV.attributedString = NSAttributedString(string: NSLocalizedString("No data is currently available. Please pull down to refresh.", comment: "Message when there is no data in the news table view"), attributes: attributes)
            let lvf = self.listView.bounds
            let textSize = bgV.measure(CGSizeMake(lvf.width - 2.0 * kNoDataViewMargin, CGFloat.max))
            bgV.frame = CGRectMake(kNoDataViewMargin, (lvf.height - textSize.height) / 2.0, textSize.width, textSize.height)
            self.bgView = bgV
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.view.addSubview(bgV.view)
                self.view.sendSubviewToBack(bgV.view)
            })
        })

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
        updateBackgroundView()
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