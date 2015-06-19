//
//  EventTitleNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 09.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class EventTitleNode: ASCellNode {
    let kEventTitleNodeMarginH: CGFloat = 16.0
    let kEventTitleNodeMarginV: CGFloat = 6.0
    let textNode = ASTextNode()

    required init(name: String, ageFrom: Int, ageTo: Int) {
        super.init()

        let headingParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.blackColor()]
        var titleStr = NSMutableAttributedString(string: "\(name)   ", attributes: headingParams)
        let attachment = NSTextAttachment()
        attachment.image = attachmentImageForAge(from: ageFrom, to: ageTo)
        let attStr = NSAttributedString(attachment: attachment)
        titleStr.appendAttributedString(attStr)

        textNode.attributedString = titleStr
        textNode.placeholderEnabled = true
        textNode.placeholderColor = UIColor.whiteColor()
        textNode.placeholderFadeDuration = 0.25

        addSubnode(textNode)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let textSize = textNode.measure(CGSizeMake(constrainedSize.width - kEventTitleNodeMarginH * 2, CGFloat.max))
        return CGSizeMake(constrainedSize.width, textSize.height + kEventTitleNodeMarginV * 2)
    }

    override func layout() {
        let textSize = textNode.calculatedSize
        textNode.frame = CGRectMake(kEventTitleNodeMarginH, kEventTitleNodeMarginV, textSize.width, textSize.height)
    }
}
