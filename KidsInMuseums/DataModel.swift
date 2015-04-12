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

let kKIMAPIDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
let kKIMDataStorageKeyNews = "kKIMDataStorageKeyNews"
let kKIMDataStorageKeyMuseums = "kKIMDataStorageKeyMuseums"
let kKIMDataStorageKeyEvents = "kKIMDataStorageKeyEvents"

struct AgeRange: Equatable {
    let from: Int
    let to: Int
}
func ==(lhs: AgeRange, rhs: AgeRange) -> Bool {
    return lhs.from == rhs.from && lhs.to == rhs.to
}

public class KImage {
    var url: String = ""
    var big: KImage?
    var thumb: KImage?
    var thumb2: KImage?

    required public init(data: NSDictionary) {
        if let urlString = data["url"] as? String {
            url = kKIMAPIServerURL + urlString
        }
        if let bigDic = data["big"] as? NSDictionary {
            big = KImage(data: bigDic)
        }
        if let thumbDic = data["thumb"] as? NSDictionary {
            thumb = KImage(data: thumbDic)
        }
        if let thumb2Dic = data["thumb2"] as? NSDictionary {
            thumb2 = KImage(data: thumb2Dic)
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

    required public init(data: NSDictionary) {
        if let idInt = data["id"] as? Int {
            id = idInt
        }
        if let titleStr = data["title"] as? String {
            title = titleStr
        }
        if let imageDic = data["image"] as? NSDictionary {
            image = KImage(data: imageDic)
        }
        if let descStr = data["description"] as? String {
            description = descStr
        }
        if let textStr = data["text"] as? String {
            text = textStr
        }
        createdAt = DataModel.sharedInstance.dateFromString(data["created_at"] as? String)
        updatedAt = DataModel.sharedInstance.dateFromString(data["updated_at"] as? String)
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

    required public init(data: NSDictionary) {
        if let idInt = data["id"] as? Int {
            id = idInt
        }
        if let emailStr = data["email"] as? String {
            email = emailStr
        }
        if let showcaseIdInt = data["showcase_id"] as? Int {
            showcaseId = showcaseIdInt
        }
        if let nameStr = data["name"] as? String {
            name = nameStr
        }
        if let contactsStr = data["contacts"] as? String {
            contacts = contactsStr
        }
        if let addressStr = data["address"] as? String {
            address = addressStr
        }
        if let directionsStr = data["directions"] as? String {
            directions = directionsStr
        }
        if let openingHoursStr = data["opening_hours"] as? String {
            openingHours = openingHoursStr
        }
        if let faresStr = data["fares"] as? String {
            fares = faresStr
        }
        if let descriptionStr = data["description"] as? String {
            description = descriptionStr
        }
        if let latitudeDbl = data["latitude"] as? Double {
            latitude = latitudeDbl
        }
        if let longitudeDbl = data["longitude"] as? Double {
            longitude = longitudeDbl
        }
        if let imageDic = data["preview_image"] as? NSDictionary {
            previewImage = KImage(data: imageDic)
        }
        if let shortDescriptionStr = data["short_description"] as? String {
            shortDescription = shortDescriptionStr
        }
        if let phoneStr = data["phone"] as? String {
            phone = phoneStr
        }
        if let siteStr = data["site"] as? String {
            site = siteStr
        }
    }

    public func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public func location() -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    public func distanceFromLocation(location: CLLocation) -> CLLocationDistance {
        let myLocation = self.location()
        return location.distanceFromLocation(myLocation)
    }
}

public class EventTime {
    var id: Int = -1
    var eventId: Int = -1
    var timeFrom: NSDate = NSDate(timeIntervalSince1970: 0)
    var comment: String = ""
    var durationHours: Int = -1
    var durationMinutes: Int = -30

    required public init(data: NSDictionary) {
        if let idInt = data["id"] as? Int {
            id = idInt
        }
        if let eventIdInt = data["event_id"] as? Int {
            eventId = eventIdInt
        }
        timeFrom = DataModel.sharedInstance.dateFromString(data["time_from"] as? String)
        if let durationHoursInt = data["duration_hours"] as? Int {
            durationHours = durationHoursInt
        }
        if let durationMinutesInt = data["duration_minutes"] as? Int {
            durationMinutes = durationMinutesInt
        }
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

    required public init(data: NSDictionary) {
        if let idInt = data["id"] as? Int {
            id = idInt
        }
        if let eventIdInt = data["event_id"] as? Int {
            eventId = eventIdInt
        }
        if let timeStr = data["time"] as? String {
            time = timeStr
        }
        if let commentStr = data["comment"] as? String {
            comment = commentStr
        }
    }
}

public class KUser {
    var id: Int = -1
    var name: String = ""

    required public init(data: NSDictionary) {
        if let idInt = data["id"] as? Int {
            id = idInt
        }
        if let nameStr = data["name"] as? String {
            name = nameStr
        }
    }
}

public class Review {
    var text: String = ""
    var user: KUser?
    var createdAt: NSDate = NSDate(timeIntervalSince1970: 0)

    required public init(data: NSDictionary) {
        if let textStr = data["text"] as? String {
            text = textStr
        }
        if let userDic = data["user"] as? NSDictionary {
            user = KUser(data: userDic)
        }
        createdAt = DataModel.sharedInstance.dateFromString(data["created_at"] as? String)
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

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    required public init(data: NSDictionary) {
        if let idInt = data["id"] as? Int {
            id = idInt
        }
        if let nameStr = data["name"] as? String {
            name = nameStr
        }
        if let muInt = data["museum_user_id"] as? Int {
            museumUserId = muInt
        }
        if let ageFromInt = data["age_from"] as? Int {
            ageFrom = ageFromInt
        }
        if let ageToInt = data["age_to"] as? Int {
            ageTo = ageToInt
        }
        if let descriptionStr = data["description"] as? String {
            description = descriptionStr
        }
        if let imageDic = data["preview_image"] as? NSDictionary {
            previewImage = KImage(data: imageDic)
        }
        if let shortDescriptionStr = data["short_description"] as? String {
            shortDescription = shortDescriptionStr
        }
        if let eventTimesArray = data["event_times"] as? NSArray {
            for eventTimeObject in eventTimesArray {
                if let eventTimeDic = eventTimeObject as? NSDictionary {
                    let eventTime = EventTime(data: eventTimeDic)
                    eventTimes.append(eventTime)
                }
            }
        }
        if let tagsArray = data["tags"] as? NSArray {
            for tagObject in tagsArray {
                if let tagStr = tagObject as? String {
                    tags.append(tagStr)
                }
            }
        }
        if let ratingDbl = data["avg_rating"] as? Double {
            rating = ratingDbl
        }
        if let eventTimesArray = data["event_human_times"] as? NSArray {
            for eventTimeObject in eventTimesArray {
                if let eventTimeDic = eventTimeObject as? NSDictionary {
                    let eventHumanTime = EventHumanTime(data: eventTimeDic)
                    eventHumanTimes.append(eventHumanTime)
                }
            }
        }
        if let reviewsArray = data["reviews"] as? NSArray {
            for reviewObject in reviewsArray {
                if let reviewDic = reviewObject as? NSDictionary {
                    let review = Review(data: reviewDic)
                    reviews.append(review)
                }
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
            return museum.location()
        }
        return CLLocation()
    }

    public func distanceFromLocation(location: CLLocation) -> CLLocationDistance {
        let myLocation = self.location()
        return location.distanceFromLocation(myLocation)
    }
}

public struct Filter {
    let ageRanges: [AgeRange]
    let tags: [String]
    let museums: [Int]
    let days: [NSDate]

    func isEmpty() -> Bool {
        return ageRanges.isEmpty && tags.isEmpty && museums.isEmpty && days.isEmpty
    }

    static func emptyFilter() -> Filter {
        return Filter(ageRanges: [AgeRange](), tags: [String](), museums: [Int](), days: [NSDate]())
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

    public var news: [NewsItem] = [NewsItem]()
    public var museums: [Museum] = [Museum]()
    public var allEvents: [Event] = [Event]()
    public var filteredEvents: [Event] = [Event]()
    public var tags: [String] = [String]()
    public var filter: Filter = Filter.emptyFilter() {
        didSet {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                self.filteredEvents = self.applyFilterToEvents(self.allEvents)
                NSNotificationCenter.defaultCenter().postNotificationName(kKIMNotificationEventsUpdated, object: self)
            })
        }
    }

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
        if news.count > 0 && museums.count > 0 && allEvents.count > 0 {
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
                    self.allEvents = self.eventsWithData(data)
                    self.filteredEvents = self.applyFilterToEvents(self.allEvents)
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
                self.allEvents = self.eventsWithData(cachedEventsJSON)
                self.filteredEvents = self.applyFilterToEvents(self.allEvents)
                if (self.allEvents.count > 0) {
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

    internal func newsWithData(data: NSData) -> [NewsItem] {
        var news = [NewsItem]()
        let jsonObject: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
        if let jsonArray = jsonObject as? NSArray {
            for newsObject: AnyObject in jsonArray {
                if let newsItemDic = newsObject as? NSDictionary {
                    let newsItem = NewsItem(data: newsItemDic)
                    news.append(newsItem)
                }
            }
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
        let jsonObject: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
        if let jsonArray = jsonObject as? NSArray {
            for eventObject: AnyObject in jsonArray {
                if let eventDic = eventObject as? NSDictionary {
                    var shouldCreateEvent = false
                    if let eventTimesArray = eventDic["event_times"] as? NSArray {
                        for eventTimeObject in eventTimesArray {
                            if let eventTimeDic = eventTimeObject as? NSDictionary {
                                let date = DataModel.sharedInstance.dateFromString(eventTimeDic["time_from"] as? String)
                                if date.compare(NSDate()) == NSComparisonResult.OrderedDescending {
                                    shouldCreateEvent = true
                                    break
                                }
                            }
                        }
                    }
                    if shouldCreateEvent {
                        let event = Event(data: eventDic)
                        events.append(event)
                    }
                }
            }
        }
        tags = tagsFromEvents(events)
        return events
    }

    private func applyFilterToEvents(events: [Event]) -> [Event] {
        let filteredEvents = events.filter({ (event: Event) -> Bool in
            var filterAge = true
            var filterTag = true
            var filterMuseum = true
            var filterDay = true
            let filter = self.filter
            if !filter.ageRanges.isEmpty {
                filterAge = false
                let eventRange = AgeRange(from: event.ageFrom, to: event.ageTo)
                for ageRange in filter.ageRanges {
                    if !(eventRange.to < ageRange.from || eventRange.from > ageRange.to) {
                        filterAge = true
                        break
                    }
                }
            }
            if !filter.tags.isEmpty {
                filterTag = false
                for tag in event.tags {
                    if contains(filter.tags, tag) {
                        filterTag = true
                        break
                    }
                }
            }
            if !filter.museums.isEmpty {
                filterMuseum = contains(filter.museums, event.museumUserId)
            }
            if !filter.days.isEmpty {
                filterDay = false
                for day in filter.days {
                    if event.hasEventsDuringTheDay(day) {
                        filterDay = true
                        break
                    }
                }
            }
            return filterAge && filterTag && filterMuseum && filterDay
        })
        return filteredEvents
    }

    internal func tagsFromEvents(events: [Event]) -> [String] {
        var tags = [String]()
        for event in events {
            for tag in event.tags {
                if !contains(tags, tag) {
                    tags.append(tag)
                }
            }
        }
        tags.sort { (s1: String, s2: String) -> Bool in
            return s1 < s2
        }
        return tags
    }

    internal func museumsWithData(data: NSData) -> [Museum] {
        var museums = [Museum]()
        let jsonObject: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
        if let jsonArray = jsonObject as? NSArray {
            for museumObject: AnyObject in jsonArray {
                if let museumDic = museumObject as? NSDictionary {
                    let museum = Museum(data: museumDic)
                    museums.append(museum)
                }
            }
        }
        return museums
    }
}