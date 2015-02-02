//
//  EventCell.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 01.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

let kEventCellMargin: CGFloat = 15.0
let kEventCellMarginIntra: CGFloat = 4.0

public class EventCell: ASCellNode {
    let eventRef: Event
    let museumRef: Museum?
    var eventTitle: ASTextNode
    var museumNode: ASTextNode
    var divider: ASDisplayNode

    required public init(event: Event) {
        eventRef = event
        eventTitle = ASTextNode()
        museumNode = ASTextNode()
        divider = ASDisplayNode()
        super.init()

        let headingParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.blackColor()]
        let museumParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)]

        var wholeTitleStr = NSMutableAttributedString()
        let titleStr = NSAttributedString(string: "\(event.name)   ", attributes: headingParams)
        wholeTitleStr.appendAttributedString(titleStr)

        var attachment = NSTextAttachment()
        attachment.image = attachmentImageForAge(from: event.ageFrom, to: event.ageTo)
        let attStr = NSAttributedString(attachment: attachment)
        wholeTitleStr.appendAttributedString(attStr)

        var museumStr = NSMutableAttributedString()
        if let museum = DataModel.sharedInstance.findMuseum(event.museumUserId) {
            museumRef = museum
            let museumTitleStr = NSAttributedString(string: museum.name, attributes: museumParams)
            museumStr.appendAttributedString(museumTitleStr)
        }

        eventTitle.attributedString = wholeTitleStr
        museumNode.attributedString = museumStr
        divider.backgroundColor = UIColor.lightGrayColor()

        self.addSubnode(eventTitle)
        self.addSubnode(museumNode)
        self.addSubnode(divider)
        self.backgroundColor = UIColor.whiteColor()
    }

    public override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let cSize = CGSizeMake(constrainedSize.width - 2 * kEventCellMargin, CGFloat.max)
        let titleSize: CGSize = eventTitle.measure(cSize)
        let museumSize: CGSize = museumNode.measure(cSize)
        return CGSizeMake(constrainedSize.width, titleSize.height + kEventCellMarginIntra + museumSize.height + 2 * kEventCellMargin)
    }

    public override func layout() {
        let pixelHeight: CGFloat = 1.0 / UIScreen.mainScreen().scale
        divider.frame = CGRectMake(0.0, 0.0, calculatedSize.width, pixelHeight)
        let titleSize = eventTitle.calculatedSize
        let museumSize = museumNode.calculatedSize
        eventTitle.frame = CGRectMake(kEventCellMargin, kEventCellMargin, titleSize.width, titleSize.height)
        museumNode.frame = CGRectMake(kEventCellMargin, kEventCellMargin + titleSize.height + kEventCellMarginIntra, museumSize.width, museumSize.height)
    }

    func attachmentImageForAge(from fromAge: Int, to toAge: Int) -> UIImage {
        let orangeColor = UIColor(red: 231.0/255.0, green: 121.0/255.0, blue: 43.0/255.0, alpha: 1.0)
        let attParams = [NSFontAttributeName: UIFont.systemFontOfSize(10.0), NSForegroundColorAttributeName: orangeColor]

        var yearStr: NSString
        switch (toAge) {
        case 0, 5...20, 30, 40, 50, 60, 70, 80, 90, 100: yearStr = NSLocalizedString("years0", comment: "0, 5-19, x0")
        case 1, 21, 31, 41, 51, 61, 71, 81, 91, 101: yearStr = NSLocalizedString("year1", comment: "x1 (except 11)")
        case 2...4, 22...24, 32...34, 42...44, 52...54, 62...64, 72...74, 82...84, 92...94, 102...104: yearStr = NSLocalizedString("years24", comment: "x2, x3, x4 except 12...14")
        default: yearStr = NSLocalizedString("years59", comment: "x5...x9 except 15...19")
        }
        yearStr = NSLocalizedString("\(fromAge) – \(toAge) ", comment: "5 – 7 ") + yearStr

        let strSize = yearStr.sizeWithAttributes(attParams)
        let vMargin: CGFloat = 2.0
        let radius = ceil(strSize.height + 2.0 * vMargin) / 2.0
        let frame = CGRectMake(0, 0, ceil(strSize.width + 2.0 * radius), ceil(strSize.height + 2.0 * vMargin))

        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
        var context = UIGraphicsGetCurrentContext()

        UIColor.whiteColor().set()
        CGContextFillRect(context, frame)

        let roundedRectPath = newPathForRoundedRect(frame, radius: frame.size.height / 2.0)
        orangeColor.set()
        CGContextAddPath(context, roundedRectPath)
        CGContextSetLineWidth(context, 1.0 / UIScreen.mainScreen().scale)
        CGContextStrokePath(context)

        let textRect = CGRectMake(frame.origin.x + floor((frame.size.width - strSize.width) / 2),
            frame.origin.y - 1.0 + floor((frame.size.height - strSize.height) / 2),
            strSize.width,
            strSize.height)

        yearStr.drawInRect(textRect, withAttributes: attParams)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func newPathForRoundedRect(rect: CGRect, radius: CGFloat) -> CGPathRef {
        var retPath: CGMutablePathRef = CGPathCreateMutable()

        let innerRect = CGRectInset(rect, radius, radius)

        let inside_right = innerRect.origin.x + innerRect.size.width - 1.0
        let outside_right = rect.origin.x + rect.size.width - 1.0
        let inside_bottom = innerRect.origin.y + innerRect.size.height - 1.0
        let outside_bottom = rect.origin.y + rect.size.height - 1.0

        let inside_top = innerRect.origin.y - 1.0
        let inside_left = innerRect.origin.x + 1.0
        let outside_top = rect.origin.y + 1.0
        let outside_left = rect.origin.x + 1.0

        CGPathMoveToPoint(retPath, nil, inside_left, outside_top);

        CGPathAddLineToPoint(retPath, nil, inside_right, outside_top)
        CGPathAddArcToPoint(retPath, nil, outside_right, outside_top, outside_right, inside_top, radius - 2.0)
        CGPathAddLineToPoint(retPath, nil, outside_right, inside_bottom)
        CGPathAddArcToPoint(retPath, nil,  outside_right, outside_bottom, inside_right, outside_bottom, radius - 2.0)

        CGPathAddLineToPoint(retPath, nil, inside_left, outside_bottom)
        CGPathAddArcToPoint(retPath, nil,  outside_left, outside_bottom, outside_left, inside_bottom, radius - 2.0)
        CGPathAddLineToPoint(retPath, nil, outside_left, inside_top)
        CGPathAddArcToPoint(retPath, nil,  outside_left, outside_top, inside_left, outside_top, radius - 2.0)
        
        CGPathCloseSubpath(retPath)
        
        return retPath
    }
}
