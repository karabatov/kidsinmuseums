//
//  EventCell.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 01.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import CoreLocation

let kEventCellMargin: CGFloat = 15.0
let kEventCellMarginIntra: CGFloat = 4.0

public class EventCell: ASCellNode {
    let eventRef: Event
    var eventTitle: ASTextNode
    var museumNode: ASTextNode
    var timeNode: ASTextNode
    var rating: ASTextNode
    var divider: ASDisplayNode

    required public init(event: Event, filterMode: EventFilterMode, referenceDate: NSDate, location: CLLocation?) {
        eventRef = event
        eventTitle = ASTextNode()
        museumNode = ASTextNode()
        timeNode = ASTextNode()
        rating = ASTextNode()
        divider = ASDisplayNode()
        super.init()

        shouldRasterizeDescendants = true

        let caption1Font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        let timeFontSize = caption1Font.pointSize - 2
        let headingParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.blackColor()]
        let museumParams = [NSFontAttributeName: caption1Font, NSForegroundColorAttributeName: UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)]
        let timeParams = [NSFontAttributeName: UIFont.systemFontOfSize(timeFontSize), NSForegroundColorAttributeName: UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0)]
        let star = FAKFontAwesome.starOIconWithSize(caption1Font.pointSize)
        star.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 248.0/255.0, green: 184.0/255.0, blue: 28.0/255.0, alpha: 1.0))

        let wholeTitleStr = NSMutableAttributedString()
        let titleStr = NSAttributedString(string: "\(event.name)   ", attributes: headingParams)
        wholeTitleStr.appendAttributedString(titleStr)

        let attachment = NSTextAttachment()
        attachment.image = attachmentImageForAge(from: event.ageFrom, to: event.ageTo)
        let attStr = NSAttributedString(attachment: attachment)
        wholeTitleStr.appendAttributedString(attStr)

        let museumStr = NSMutableAttributedString()
        if let museum = event.museum() {
            if let loc = location {
                let distance = event.distanceFromLocation(loc)
                let locStr = NSAttributedString(string: "\(distance.humanReadable()) \u{25b8} ", attributes: museumParams)
                museumStr.appendAttributedString(locStr)
            }

            let museumTitleStr = NSAttributedString(string: museum.name, attributes: museumParams)
            museumStr.appendAttributedString(museumTitleStr)
        }

        let timeStr = NSMutableAttributedString()
        if let evtTime = event.earliestEventTime(referenceDate) {
            let showTimeStr = NSAttributedString(string: evtTime.humanReadable(filterMode), attributes: timeParams)
            timeStr.appendAttributedString(showTimeStr)
        }

        let ratingStr = NSMutableAttributedString()
        for var i = 0; i < Int(round(event.rating)); i++ {
            ratingStr.appendAttributedString(star.attributedString())
        }

        eventTitle.placeholderColor = UIColor.whiteColor()
        eventTitle.attributedString = wholeTitleStr
        museumNode.placeholderColor = UIColor.whiteColor()
        museumNode.attributedString = museumStr
        timeNode.placeholderColor = UIColor.whiteColor()
        timeNode.attributedString = timeStr
        rating.placeholderColor = UIColor.whiteColor()
        rating.attributedString = ratingStr
        divider.backgroundColor = UIColor.lightGrayColor()

        self.addSubnode(eventTitle)
        self.addSubnode(museumNode)
        self.addSubnode(timeNode)
        self.addSubnode(rating)
        self.addSubnode(divider)
        self.backgroundColor = UIColor.whiteColor()
    }

    public override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let cSize = CGSizeMake(constrainedSize.width - 2 * kEventCellMargin, CGFloat.max)
        let titleSize: CGSize = eventTitle.measure(cSize)
        let museumSize: CGSize = museumNode.measure(cSize)
        let ratingSize: CGSize = rating.measure(cSize)
        let tSize = CGSizeMake(cSize.width - ratingSize.width - kEventCellMarginIntra, CGFloat.max)
        let timeSize: CGSize = timeNode.measure(tSize)
        return CGSizeMake(constrainedSize.width, titleSize.height + museumSize.height + max(ratingSize.height, timeSize.height) + kEventCellMarginIntra * 2 + kEventCellMargin * 2)
    }

    public override func layout() {
        let pixelHeight: CGFloat = 1.0 / UIScreen.mainScreen().scale
        divider.frame = CGRectMake(0.0, 0.0, calculatedSize.width, pixelHeight)
        let titleSize = eventTitle.calculatedSize
        let museumSize = museumNode.calculatedSize
        let timeSize = timeNode.calculatedSize
        let ratingSize = rating.calculatedSize
        eventTitle.frame = CGRectMake(kEventCellMargin, kEventCellMargin, titleSize.width, titleSize.height)
        museumNode.frame = CGRectMake(kEventCellMargin, kEventCellMargin + titleSize.height + kEventCellMarginIntra, museumSize.width, museumSize.height)
        timeNode.frame = CGRectMake(kEventCellMargin, kEventCellMargin + titleSize.height + museumSize.height + kEventCellMarginIntra * 2, timeSize.width, timeSize.height)
        rating.frame = CGRectMake(calculatedSize.width - ratingSize.width - kEventCellMargin, kEventCellMargin + titleSize.height + museumSize.height + kEventCellMarginIntra * 2, ratingSize.width, ratingSize.height)
    }
}
