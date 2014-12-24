//
//  NewsCell.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 22.12.14.
//  Copyright (c) 2014 Golova Media. All rights reserved.
//

import Foundation

let kNewsCellMargin: CGFloat = 15.0

public class NewsCell : ASCellNode {
    var newsText: ASTextNode
    var divider: ASDisplayNode

    required public init(newsItem: NewsItem) {
        let dateParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0)]
        let headingParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.blackColor()]
        let descriptionParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), NSForegroundColorAttributeName: UIColor(red: 71.0/255.0, green: 71.0/255.0, blue: 71.0/255.0, alpha: 1.0)]

        var labelStr = NSMutableAttributedString()
        let dateStr = NSAttributedString(string: newsItem.formattedDate() + "\n\n", attributes: dateParams)
        let titleStr = NSAttributedString(string: newsItem.title, attributes: headingParams)
        let descriptionStr = NSAttributedString(string: "\n\n" + newsItem.description, attributes: descriptionParams)
        labelStr.appendAttributedString(dateStr)
        labelStr.appendAttributedString(titleStr)
        labelStr.appendAttributedString(descriptionStr)

        newsText = ASTextNode()
        newsText.attributedString = labelStr

        divider = ASDisplayNode()
        divider.backgroundColor = UIColor.lightGrayColor()

        super.init()
        self.addSubnode(newsText)
        self.addSubnode(divider)
    }

    public override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let cSize = CGSizeMake(constrainedSize.width - 2 * kNewsCellMargin, CGFloat.max)
        let textSize: CGSize = newsText.measure(cSize)
        return CGSizeMake(constrainedSize.width, textSize.height + 2 * kNewsCellMargin)
    }

    public override func layout() {
        let pixelHeight: CGFloat = 1.0 / UIScreen.mainScreen().scale
        divider.frame = CGRectMake(0.0, 0.0, calculatedSize.width, pixelHeight)
        let textSize = newsText.calculatedSize
        newsText.frame = CGRectMake(kNewsCellMargin, kNewsCellMargin, textSize.width, textSize.height)
    }
}