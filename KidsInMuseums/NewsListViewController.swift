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
    let loadingView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    let bgView = NoDataView()

    // MARK: UIViewController

    override required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = NSLocalizedString("News", comment: "News controller title")
        tabBarItem = UITabBarItem(title: title, image: UIImage(named: "icon-news"), tag: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: "Navbar back button title"), style: .Plain, target: nil, action: nil)
        self.view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, .FlexibleWidth]
        self.view.backgroundColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = UIRectEdge.None
        let b = self.view.bounds
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.bgView.measure(b.size)
            self.bgView.frame = b
        })
        loadingView.startAnimating()
        self.view.addSubview(loadingView)
        self.view.addSubview(listView)
        listView.separatorStyle = UITableViewCellSeparatorStyle.None;
        listView.backgroundColor = UIColor.clearColor()
        listView.asyncDelegate = self
        listView.asyncDataSource = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newsItemsUpdated:", name: kKIMNotificationNewsUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newsItemsUpdateFailed:", name: kKIMNotificationNewsUpdateFailed, object: nil)
        newsItems = DataModel.sharedInstance.news
    }

    override func viewWillLayoutSubviews() {
        let b = self.view.bounds
        if (listView.frame != b) {
            listView.frame = b
            self.bgView.measure(b.size)
            self.bgView.frame = b
            listView.reloadData()
        }
        loadingView.center = CGPoint(x: b.midX, y: b.midY)
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

    func scrollToTop() {
        listView.scrollRectToVisible(CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1)), animated: true)
    }

    // MARK: Data

    func updateNews() {
        DataModel.sharedInstance.update()
        bgView.hidden = true
        loadingView.hidden = DataModel.sharedInstance.news.count > 0
    }

    func newsItemsUpdated(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.refreshControl?.endRefreshing()
            self.newsItems = DataModel.sharedInstance.news
            self.listView.reloadData()
            if self.newsItems.count == 0 && self.bgView.view.superview == nil {
                self.view.insertSubview(self.bgView.view, aboveSubview: self.loadingView)
                self.bgView.hidden = false
            } else {
                self.bgView.hidden = true
            }
            self.loadingView.hidden = true
        }
    }

    func newsItemsUpdateFailed(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.refreshControl?.endRefreshing()
            self.loadingView.hidden = true
            if self.newsItems.count == 0 {
                if self.bgView.view.superview == nil {
                    self.view.insertSubview(self.bgView.view, aboveSubview: self.loadingView)
                }
                self.bgView.hidden = false
            }
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
        return true
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let news = newsItems[indexPath.row]
        let nic = NewsItemViewController(newsItem: news, frame: self.view.bounds)
        nic.title = self.title
        self.navigationController?.pushViewController(nic, animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.listView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
}