//
//  EventCell.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 01.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

let kEventCellMargin: CGFloat = 15.0

public class EventCell: ASCellNode {
    var eventTitle: ASTextNode
    var divider: ASDisplayNode

    required public init(event: Event) {
        let headingParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.blackColor()]

        var wholeTitleStr = NSMutableAttributedString()
        let titleStr = NSAttributedString(string: event.name, attributes: headingParams)
        wholeTitleStr.appendAttributedString(titleStr)

        eventTitle = ASTextNode()
        eventTitle.attributedString = wholeTitleStr

        divider = ASDisplayNode()
        divider.backgroundColor = UIColor.lightGrayColor()

        super.init()
        self.addSubnode(eventTitle)
        self.addSubnode(divider)
        self.backgroundColor = UIColor.whiteColor()
    }

    public override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let cSize = CGSizeMake(constrainedSize.width - 2 * kEventCellMargin, CGFloat.max)
        let textSize: CGSize = eventTitle.measure(cSize)
        return CGSizeMake(constrainedSize.width, textSize.height + 2 * kEventCellMargin)
    }

    public override func layout() {
        let pixelHeight: CGFloat = 1.0 / UIScreen.mainScreen().scale
        divider.frame = CGRectMake(0.0, 0.0, calculatedSize.width, pixelHeight)
        let textSize = eventTitle.calculatedSize
        eventTitle.frame = CGRectMake(kEventCellMargin, kEventCellMargin, textSize.width, textSize.height)
    }
}
