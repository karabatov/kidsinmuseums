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
    var eventTitle: ASTextNode
    var museumNode: ASTextNode
    var divider: ASDisplayNode

    required public init(event: Event) {
        let headingParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.blackColor()]
        let museumParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)]

        var wholeTitleStr = NSMutableAttributedString()
        let titleStr = NSAttributedString(string: event.name, attributes: headingParams)
        wholeTitleStr.appendAttributedString(titleStr)

        var museumStr = NSMutableAttributedString()
        if let museum = DataModel.sharedInstance.findMuseum(event.museumUserId) {
            let museumTitleStr = NSAttributedString(string: museum.name, attributes: museumParams)
            museumStr.appendAttributedString(museumTitleStr)
        }

        eventTitle = ASTextNode()
        eventTitle.attributedString = wholeTitleStr

        museumNode = ASTextNode()
        museumNode.attributedString = museumStr

        divider = ASDisplayNode()
        divider.backgroundColor = UIColor.lightGrayColor()

        super.init()
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
}
