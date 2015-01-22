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
public let kKIMNotificationMuseumsUpdated = "kKIMNotificationMuseumsUpdated"
public let kKIMNotificationMuseumsUpdateFailed = "kKIMNotificationMuseumsUpdateFailed"

let kKIMAPIServerURL = "http://www.kidsinmuseums.ru"
let kKIMAPINewsURL = "/api/news_articles/all"
let kKIMAPIMuseumsURL = "/api/museum_users/all"

let kKIMAPIDateFormat: NSString = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
let kKIMDataStorageKeyNews = "kKIMDataStorageKeyNews"
let kKIMDataStorageKeyMuseums = "kKIMDataStorageKeyMuseums"

public class KImage: Deserializable {
    var url: String = ""
    var big: KImage?
    var thumb: KImage?
    var thumb2: KImage?

    required public init(data: [String : AnyObject]) {
        url <<< data["url"]
        url = kKIMAPIServerURL + url;
        big <<<< data["big"]
        thumb <<<< data["thumb"]
        thumb2 <<<< data["thumb2"]
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

    public func formattedDate() -> String {
        var df = NSDateFormatter()
        df.dateStyle = NSDateFormatterStyle.LongStyle
        df.timeStyle = NSDateFormatterStyle.NoStyle
        return df.stringFromDate(updatedAt)
    }
}

public class Museum: Deserializable {
    var id: Int = -1
    var email: String = ""
    var showcaseId: Int = -1
    var name: String = ""
    var contacts: String = ""
    var address: String = ""
    var directions: String = ""
    var openingHours: String = ""
    var fares: String = ""
    var description: String = ""
    var latitude: Float = 0
    var longitude: Float = 0
    var previewImage: KImage?
    var shortDescription: String = ""

    required public init(data: [String : AnyObject]) {
        id <<< data["id"]
        email <<< data["email"]
        showcaseId <<< data["showcase_id"]
        name <<< data["name"]
        contacts <<< data["contacts"]
        address <<< data["address"]
        directions <<< data["directions"]
        openingHours <<< data["opening_hours"]
        fares <<< data["fares"]
        description <<< data["description"]
        latitude <<< data["latitude"]
        longitude <<< data["longitude"]
        previewImage <<<< data["preview_image"]
        shortDescription <<< data["short_description"]
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
    public var museums : [Museum] = [Museum]()

    required public init() {
        loadFromCache()
    }

    public func update() {
        updateNews()
        updateMuseums()
    }

    public func updateNews() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let newsUrl = NSURL(string: kKIMAPIServerURL + kKIMAPINewsURL)
            let newsRequest = NSURLSession.sharedSession().dataTaskWithURL(newsUrl!) { (data, response, error) -> Void in
                if (error == nil) {
                    let pdata: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
                    self.news <<<<* pdata
                    self.news = self.news.sorted({ (obj1: NewsItem, obj2: NewsItem) -> Bool in
                        if (obj1.updatedAt.compare(obj2.updatedAt) == NSComparisonResult.OrderedAscending) {
                            return false
                        }
                        return true
                    })
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
    }

    public func updateMuseums() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let museumsUrl = NSURL(string: kKIMAPIServerURL + kKIMAPIMuseumsURL)
            let museumsRequest = NSURLSession.sharedSession().dataTaskWithURL(museumsUrl!) { (data, response, error) -> Void in
                if (error == nil) {
                    let pdata: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
                    self.museums <<<<* pdata
                    NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationMuseumsUpdated, object: self)
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        NSUserDefaults.standardUserDefaults().setObject(data, forKey: kKIMDataStorageKeyMuseums)
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                }
                else {
                    NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationMuseumsUpdateFailed, object: self)
                }
            }
            museumsRequest.resume()
        }
    }

    public func loadFromCache() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let cachedNewsJSON: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(kKIMDataStorageKeyNews) {
                self.news <<<<* cachedNewsJSON
                if (self.news.count > 0) {
                    NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationNewsUpdated, object: self)
                }
            }
            if let cachedMuseumsJSON: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(kKIMDataStorageKeyMuseums) {
                self.museums <<<<* cachedMuseumsJSON
                if (self.museums.count > 0) {
                    NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationMuseumsUpdated, object: self)
                }
            }
        }
    }
}