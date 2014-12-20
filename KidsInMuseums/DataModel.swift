//
//  DataModel.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 20.12.14.
//  Copyright (c) 2014 Golova Media. All rights reserved.
//

import Foundation

public let kKIMNotificationNewsUpdated = "kKIMNotificationNewsUpdated"
public let kKIMNotificationNewsUpdateFailed = "kKIMNotificationNewsUpdateFailed"

let kKIMAPIServerURL = "http://www.kidsinmuseums.ru"
let kKIMAPINewsURL = "/api/news_articles/all"

let kKIMAPIDateFormat: NSString = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
let kKIMDataStorageKeyNews = "kKIMDataStorageKeyNews"

public class KImage: Deserializable {
    var url: String = ""
    var big: KImage?
    var thumb: KImage?

    required public init(data: [String : AnyObject]) {
        url <<< data["url"]
        url = kKIMAPIServerURL + url;
        big <<<< data["big"]
        thumb <<<< data["thumb"]
    }
}

public class NewsItem: Deserializable {
    var id: Int = -1
    var title: String = ""
    var image: KImage?
    var description: String = ""
    var text: String = ""
    var createdAt: NSDate = NSDate(timeIntervalSince1970: 0)
    var updatedAt: NSDate = NSDate(timeIntervalSince1970: 0)

    required public init(data: [String : AnyObject]) {
        id <<< data["id"]
        title <<< data["title"]
        image <<<< data["image"]
        description <<< data["description"]
        text <<< data["text"]
        createdAt <<< (value: data["created_at"], format: kKIMAPIDateFormat)
        updatedAt <<< (value: data["updated_at"], format: kKIMAPIDateFormat)
    }
}

public class DataModel {
    // Singleton model as per https://github.com/hpique/SwiftSingleton
    public class var sharedInstance : DataModel {
        struct Static {
            static let instance : DataModel = DataModel()
        }
        return Static.instance
    }

    public var news : [NewsItem] = [NewsItem]()

    required public init() {
        loadFromCache()
    }

    public func update() {
        updateNews()
    }

    public func updateNews() {
        let newsUrl = NSURL(string: kKIMAPIServerURL + kKIMAPINewsURL)
        let newsRequest = NSURLSession.sharedSession().dataTaskWithURL(newsUrl!) { (data, response, error) -> Void in
            if (error == nil) {
                let pdata: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
                self.news <<<<* pdata
                NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationNewsUpdated, object: self)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: kKIMDataStorageKeyNews)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            }
            else {
                NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationNewsUpdateFailed, object: self)
            }
        }
        newsRequest.resume()
    }

    public func loadFromCache() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let cachedNewsJSON: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(kKIMDataStorageKeyNews) {
                self.news <<<<* cachedNewsJSON
                if (self.news.count > 0) {
                    NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationNewsUpdated, object: self)
                }
            }
        }
    }
}