//
//  DataModel.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 20.12.14.
//  Copyright (c) 2014 Golova Media. All rights reserved.
//

import Foundation
import CoreLocation

public let kKIMNotificationNewsUpdated = "kKIMNotificationNewsUpdated"
public let kKIMNotificationNewsUpdateFailed = "kKIMNotificationNewsUpdateFailed"
public let kKIMNotificationMuseumsUpdated = "kKIMNotificationMuseumsUpdated"
public let kKIMNotificationMuseumsUpdateFailed = "kKIMNotificationMuseumsUpdateFailed"
public let kKIMNotificationEventsUpdated = "kKIMNotificationEventsUpdated"
public let kKIMNotificationEventsUpdateFailed = "kKIMNotificationEventsUpdateFailed"

let kKIMAPIServerURL = "http://www.kidsinmuseums.ru"
let kKIMAPINewsURL = "/api/news_articles/all"
let kKIMAPIMuseumsURL = "/api/museum_users/all"
let kKIMAPIEventsURL = "/api/events/all"

let kKIMAPIDateFormat: NSString = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
let kKIMDataStorageKeyNews = "kKIMDataStorageKeyNews"
let kKIMDataStorageKeyMuseums = "kKIMDataStorageKeyMuseums"
let kKIMDataStorageKeyEvents = "kKIMDataStorageKeyEvents"

public class KImage {
    var url: String = ""
    var big: KImage?
    var thumb: KImage?
    var thumb2: KImage?

    required public init(data: JSON) {
        url = kKIMAPIServerURL + data["url"].stringValue
        if let bigURL = data["big"]["url"].string {
            big = KImage(data: data["big"])
        }
        if let thumbURL = data["thumb"]["url"].string {
            thumb = KImage(data: data["thumb"])
        }
        if let thumb2URL = data["thumb2"]["url"].string {
            thumb2 = KImage(data: data["thumb2"])
        }
    }
}

public class NewsItem {
    var id: Int = -1
    var title: String = ""
    var image: KImage?
    var description: String = ""
    var text: String = ""
    var createdAt: NSDate = NSDate(timeIntervalSince1970: 0)
    var updatedAt: NSDate = NSDate(timeIntervalSince1970: 0)

    required public init(jsonData: JSON) {
        id = jsonData["id"].intValue
        title = jsonData["title"].stringValue
        if let imageURL = jsonData["image"]["url"].string {
            image = KImage(data: jsonData["image"])
        }
        description = jsonData["description"].stringValue
        text = jsonData["text"].stringValue
        createdAt = DataModel.sharedInstance.dateFromString(jsonData["created_at"].string)
        updatedAt = DataModel.sharedInstance.dateFromString(jsonData["updated_at"].string)
    }

    public func formattedDate() -> String {
        var df = NSDateFormatter()
        df.dateStyle = NSDateFormatterStyle.LongStyle
        df.timeStyle = NSDateFormatterStyle.NoStyle
        return df.stringFromDate(updatedAt)
    }
}

public class Museum {
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
    var latitude: Double = 0
    var longitude: Double = 0
    var previewImage: KImage?
    var shortDescription: String = ""
    var phone: String = ""
    var site: String = ""

    required public init(data: JSON) {
        id = data["id"].intValue
        email = data["email"].stringValue
        showcaseId = data["showcase_id"].intValue
        name = data["name"].stringValue
        contacts = data["contacts"].stringValue
        address = data["address"].stringValue
        directions = data["directions"].stringValue
        openingHours = data["opening_hours"].stringValue
        fares = data["fares"].stringValue
        description = data["description"].stringValue
        latitude = data["latitude"].doubleValue
        longitude = data["longitude"].doubleValue
        if let imageURL = data["preview_image"]["url"].string {
            previewImage = KImage(data: data["preview_image"])
        }
        shortDescription = data["short_description"].stringValue
        phone = data["phone"].stringValue
        site = data["site"].stringValue
    }

    public func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

public class EventTime {
    var id: Int = -1
    var eventId: Int = -1
    var timeFrom: NSDate = NSDate(timeIntervalSince1970: 0)
    var comment: String = ""
    var durationHours: Int = -1
    var durationMinutes: Int = -30

    required public init(data: JSON) {
        id = data["id"].intValue
        eventId = data["event_id"].intValue
        timeFrom = DataModel.sharedInstance.dateFromString(data["time_from"].string)
        comment = data["comment"].stringValue
        durationHours = data["duration_hours"].intValue
        durationMinutes = data["duration_minutes"].intValue
    }

    public func timeString() -> String {
        var timeFormat = NSDateFormatter.dateFormatFromTemplate("jm", options: 0, locale: NSLocale.currentLocale())
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = timeFormat
        let timeFromStr = dateFormatter.stringFromDate(timeFrom)
        if durationHours >= 0 && durationMinutes >= 0 {
            let endTime = NSDate(timeInterval: Double(durationHours) * 3600 + Double(durationMinutes) * 60, sinceDate: timeFrom)
            let timeToStr = dateFormatter.stringFromDate(endTime)
            return String(format: NSLocalizedString("%@ to %@", comment: "Event duration, time only"), timeFromStr, timeToStr)
        } else {
            return String(format: NSLocalizedString("starts at %@", comment: "Event duration if no end time, time only"), timeFromStr)
        }
    }

    public func dateString() -> String {
        var timeFormat = NSDateFormatter.dateFormatFromTemplate("dMMMM", options: 0, locale: NSLocale.currentLocale())
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = timeFormat
        return dateFormatter.stringFromDate(timeFrom)
    }

    public func humanReadable(filterMode: EventFilterMode) -> String {
        switch filterMode {
        case .Date: return timeString()
        case .Distance, .Rating:
            let date = dateString()
            let time = timeString()
            return String(format: NSLocalizedString("%@, %@", comment: "Full event date string"), dateString(), timeString())
        }
    }
}

public class EventHumanTime {
    var id: Int = -1
    var eventId: Int = -1
    var time: String = ""
    var comment: String = ""

    required public init(data: JSON) {
        id = data["id"].intValue
        eventId = data["event_id"].intValue
        time = data["time"].stringValue
        comment = data["comment"].stringValue
    }
}

public class KUser {
    var id: Int = -1
    var name: String = ""

    required public init(data: JSON) {
        id = data["id"].intValue
        name = data["name"].stringValue
    }
}

public class Review {
    var text: String = ""
    var user: KUser?
    var createdAt: NSDate = NSDate(timeIntervalSince1970: 0)

    required public init(data: JSON) {
        text = data["text"].stringValue
        if let userName = data["user"]["name"].string {
            user = KUser(data: data["user"])
        }
        createdAt = DataModel.sharedInstance.dateFromString(data["created_at"].string)
    }
}

public class Event {
    var id: Int = -1
    var name: String = ""
    var museumUserId: Int = -1
    var ageFrom: Int = -1
    var ageTo: Int = -1
    var description: String = ""
    var previewImage: KImage?
    var shortDescription: String = ""
    var eventTimes = [EventTime]()
    var tags: [String] = [String]()
    var rating: Double = 0.0
    var eventHumanTimes = [EventHumanTime]()
    var reviews = [Review]()

    required public init(data: JSON) {
        if let idInt = data["id"].int {
            id = idInt
        }
        if let nameStr = data["name"].string {
            name = nameStr
        }
        if let muInt = data["museum_user_id"].int {
            museumUserId = muInt
        }
        if let ageFromInt = data["age_from"].int {
            ageFrom = ageFromInt
        }
        if let ageToInt = data["age_to"].int {
            ageTo = ageToInt
        }
        if let descriptionStr = data["description"].string {
            description = descriptionStr
        }
        if let imageURL = data["preview_image"]["url"].string {
            previewImage = KImage(data: data["preview_image"])
        }
        if let shortDescriptionStr = data["short_description"].string {
            shortDescription = shortDescriptionStr
        }
        for (index: String, subJson: JSON) in data["event_times"] {
            if let eventTimeFromStr = subJson["time_from"].string {
                let eventTime = EventTime(data: subJson)
                eventTimes.append(eventTime)
            }
        }
        for (index: String, subJson: JSON) in data["tags"] {
            if let tag = subJson.string {
                tags.append(tag)
            }
        }
        if let ratingDbl = data["avg_rating"].double {
            rating = ratingDbl
        }
        for (index: String, subJson: JSON) in data["event_human_times"] {
            if let ehtTime = subJson["time"].string {
                let eventHumanTime = EventHumanTime(data: subJson)
                eventHumanTimes.append(eventHumanTime)
            }
        }
        for (index: String, subJson: JSON) in data["reviews"] {
            if let reviewText = subJson["text"].string {
                let review = Review(data: subJson)
                reviews.append(review)
            }
        }
    }

    public func earliestEventTime(afterDate: NSDate) -> EventTime? {
        var evT: EventTime?
        for eventTime in eventTimes {
            if evT == nil && eventTime.timeFrom.compare(afterDate) == NSComparisonResult.OrderedDescending {
                evT = eventTime
                continue
            }
            if eventTime.timeFrom.compare(afterDate) == NSComparisonResult.OrderedDescending && eventTime.timeFrom.compare(evT!.timeFrom) == NSComparisonResult.OrderedAscending {
                evT = eventTime
            }
        }
        return evT
    }

    public func futureDays(afterDate: NSDate) -> [NSDate] {
        var futureDays = [NSDate]()
        for eventTime in eventTimes {
            if eventTime.timeFrom.compare(afterDate) == NSComparisonResult.OrderedDescending {
                let cal = NSCalendar.currentCalendar()
                let comps = cal.components(.DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit, fromDate: eventTime.timeFrom)
                if let day = cal.dateFromComponents(comps) {
                    futureDays.append(day)
                }
            }
        }
        return futureDays
    }

    public func hasEventsDuringTheDay(day: NSDate) -> Bool {
        if let evT = self.earliestEventTime(day) {
            return evT.timeFrom.compare(NSDate(timeInterval: 60 * 60 * 24, sinceDate: day)) == NSComparisonResult.OrderedAscending
        }
        return false
    }

    public func museum() -> Museum? {
        if let museum = DataModel.sharedInstance.findMuseum(self.museumUserId) {
            return museum
        }
        return nil
    }

    public func location() -> CLLocation {
        if let museum = self.museum() {
            return CLLocation(latitude: museum.latitude, longitude: museum.longitude)
        }
        return CLLocation()
    }

    public func distanceFromLocation(location: CLLocation) -> CLLocationDistance {
        let myLocation = self.location()
        return location.distanceFromLocation(myLocation)
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
    public var events : [Event] = [Event]()

    private let inDateFormatter = NSDateFormatter()

    required public init() {
        inDateFormatter.dateFormat = kKIMAPIDateFormat
        loadFromCache()
    }

    public func update() {
        updateMuseums()
        updateEvents()
        updateNews()
    }

    public func dataLoaded() -> Bool {
        if news.count > 0 && museums.count > 0 && events.count > 0 {
            return true
        }
        return false
    }

    public func dateFromString(dateString: String?) -> NSDate {
        if let dateStringGiven = dateString {
            if let date = inDateFormatter.dateFromString(dateStringGiven) {
                return date
            }
        }
        return NSDate(timeIntervalSince1970: 0)
    }

    public func updateNews() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let newsUrl = NSURL(string: kKIMAPIServerURL + kKIMAPINewsURL)
            let newsRequest = NSURLSession.sharedSession().dataTaskWithURL(newsUrl!) { (data, response, error) -> Void in
                if (error == nil) {
                    self.news = self.newsWithData(data)
                    NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationNewsUpdated, object: self)
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        NSUserDefaults.standardUserDefaults().setObject(data, forKey: kKIMDataStorageKeyNews)
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                }
                else {
                    NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationNewsUpdateFailed, object: self)
                }
                NSLog("News updated.")
            }
            newsRequest.resume()
        }
    }

    public func updateMuseums() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let museumsUrl = NSURL(string: kKIMAPIServerURL + kKIMAPIMuseumsURL)
            let museumsRequest = NSURLSession.sharedSession().dataTaskWithURL(museumsUrl!) { (data, response, error) -> Void in
                if (error == nil) {
                    self.museums = self.museumsWithData(data)
                    NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationMuseumsUpdated, object: self)
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        NSUserDefaults.standardUserDefaults().setObject(data, forKey: kKIMDataStorageKeyMuseums)
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                }
                else {
                    NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationMuseumsUpdateFailed, object: self)
                }
                NSLog("Museums updated.")
            }
            museumsRequest.resume()
        }
    }

    public func updateEvents() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let eventsUrl = NSURL(string: kKIMAPIServerURL + kKIMAPIEventsURL)
            let eventsRequest = NSURLSession.sharedSession().dataTaskWithURL(eventsUrl!) { (data, response, error) -> Void in
                if (error == nil) {
                    self.events = self.eventsWithData(data)
                    NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationEventsUpdated, object: self)
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        NSUserDefaults.standardUserDefaults().setObject(data, forKey: kKIMDataStorageKeyEvents)
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                }
                else {
                    NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationEventsUpdateFailed, object: self)
                }
                NSLog("Events updated.")
            }
            eventsRequest.resume()
        }
    }

    public func loadFromCache() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let cachedNewsJSON = NSUserDefaults.standardUserDefaults().objectForKey(kKIMDataStorageKeyNews) as? NSData {
                self.news = self.newsWithData(cachedNewsJSON)
                if (self.news.count > 0) {
                    NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationNewsUpdated, object: self)
                }
            }
            if let cachedMuseumsJSON = NSUserDefaults.standardUserDefaults().objectForKey(kKIMDataStorageKeyMuseums) as? NSData {
                self.museums = self.museumsWithData(cachedMuseumsJSON)
                if (self.museums.count > 0) {
                    NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationMuseumsUpdated, object: self)
                }
            }
            if let cachedEventsJSON = NSUserDefaults.standardUserDefaults().objectForKey(kKIMDataStorageKeyEvents) as? NSData {
                self.events = self.eventsWithData(cachedEventsJSON)
                if (self.events.count > 0) {
                    NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationEventsUpdated, object: self)
                }
            }
            NSLog("Finished loading from cache. Updating now.")
            self.update()
        }
    }

    public func findMuseum(museumId: Int) -> Museum? {
        if museumId == -1 || self.museums.count == 0 {
            return nil
        }
        for museum in self.museums {
            if museum.id == museumId {
                return museum
            }
        }
        return nil
    }

    internal func futureEventsFilter(event: Event) -> Bool {
        for eventTime in event.eventTimes {
            if eventTime.timeFrom.compare(NSDate()) == NSComparisonResult.OrderedDescending {
                return true
            }
        }
        return false
    }

    internal func newsWithData(data: NSData) -> [NewsItem] {
        var news = [NewsItem]()
        let json = JSON(data: data)
        for (index: String, subJson: JSON) in json {
            let newsItem = NewsItem(jsonData: subJson)
            news.append(newsItem)
        }
        news = news.sorted({ (obj1: NewsItem, obj2: NewsItem) -> Bool in
            if (obj1.updatedAt.compare(obj2.updatedAt) == NSComparisonResult.OrderedAscending) {
                return false
            }
            return true
        })
        return news
    }

    internal func eventsWithData(data: NSData) -> [Event] {
        var events = [Event]()
        let json = JSON(data: data)
        for (index: String, subJson: JSON) in json {
            if let eventName = subJson["name"].string {
                let event = Event(data: subJson)
                events.append(event)
            }
        }
        events = events.filter(self.futureEventsFilter)
        return events
    }

    internal func museumsWithData(data: NSData) -> [Museum] {
        var museums = [Museum]()
        let json = JSON(data: data)
        for (index: String, subJson: JSON) in json {
            let museum = Museum(data: subJson)
            museums.append(museum)
        }
        return museums
    }
}