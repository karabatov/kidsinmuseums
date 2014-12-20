//
//  DataModel.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 20.12.14.
//  Copyright (c) 2014 Golova Media. All rights reserved.
//

import Foundation

let kKIMAPIServerURL = "http://www.kidsinmuseums.ru"
let kKIMAPIDateFormat: NSString = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

class KImage: Deserializable {
    var url: String = ""
    var big: KImage?
    var thumb: KImage?

    required init(data: [String : AnyObject]) {
        url <<< data["url"]
        url = kKIMAPIServerURL + url;
        big <<<< data["big"]
        thumb <<<< data["thumb"]
    }
}

class NewsItem: Deserializable {
    var id: Int = -1
    var title: String = ""
    var image: KImage?
    var description: String = ""
    var text: String = ""
    var createdAt: NSDate = NSDate(timeIntervalSince1970: 0)
    var updatedAt: NSDate = NSDate(timeIntervalSince1970: 0)

    required init(data: [String : AnyObject]) {
        id <<< data["id"]
        title <<< data["title"]
        image <<<< data["image"]
        description <<< data["description"]
        text <<< data["text"]
        createdAt <<< (value: data["created_at"], format: kKIMAPIDateFormat)
        updatedAt <<< (value: data["updated_at"], format: kKIMAPIDateFormat)
    }
}