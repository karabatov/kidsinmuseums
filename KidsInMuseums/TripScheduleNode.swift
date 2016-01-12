//
//  TripScheduleNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 05.08.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import UIKit

class TripScheduleNode: ASCellNode {
    let clockNode = ASTextNode()
    let textNode = ASTextNode()
    let marginH: CGFloat = 16.0
    let marginV: CGFloat = 6.0
    let pinFontSize: CGFloat = 14.0

    required init(text: String, comment: String) {
        super.init()

        let textParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.blackColor()]
        let titleStr = NSMutableAttributedString(string: text, attributes: textParams)
        if !text.isEmpty && !comment.isEmpty {
            titleStr.appendAttributedString(NSAttributedString(string: "\n", attributes: textParams))
        }
        if !comment.isEmpty {
            titleStr.appendAttributedString(NSAttributedString(string: comment, attributes: textParams))
        }

        let clock = FAKFontAwesome.clockOIconWithSize(pinFontSize)
        clock.addAttribute(NSForegroundColorAttributeName, value: UIColor.kimColor())
        clockNode.attributedString = clock.attributedString()

        textNode.attributedString = titleStr

        addSubnode(clockNode)
        addSubnode(textNode)

        placeholderEnabled = true
        placeholderFadeDuration = 0.25
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let clockSize = clockNode.measure(CGSizeMake(constrainedSize.width, CGFloat.max))
        let textSize = textNode.measure(CGSizeMake(constrainedSize.width - marginH * 2, CGFloat.max))
        return CGSizeMake(constrainedSize.width, max(clockSize.height + marginV * 3, textSize.height + marginV * 2))
    }

    override func layout() {
        let clockSize = clockNode.calculatedSize
        let textSize = textNode.calculatedSize
        clockNode.frame = CGRectMake(marginH, marginV, clockSize.width, clockSize.height)
        textNode.frame = CGRectMake(marginH * 2, marginV, textSize.width, textSize.height)
    }
}
