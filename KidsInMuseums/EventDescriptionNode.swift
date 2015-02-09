//
//  EventDescriptionNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 09.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class EventDescriptionNode: ASCellNode {
    let textNode = ASTextNode()
    let kEventDescriptionNodeMarginH: CGFloat = 16.0
    let kEventDescriptionNodeMarginV: CGFloat = 6.0

    required init(description: String) {
        let textParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)]

        let textStr = NSAttributedString(string: description, attributes: textParams)
        textNode.attributedString = textStr

        super.init()

        addSubnode(textNode)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let textSize = textNode.measure(CGSizeMake(constrainedSize.width - kEventDescriptionNodeMarginH * 2, CGFloat.max))
        return CGSizeMake(constrainedSize.width, textSize.height + kEventDescriptionNodeMarginV * 2)
    }

    override func layout() {
        let textSize = textNode.calculatedSize
        textNode.frame = CGRectMake(kEventDescriptionNodeMarginH, kEventDescriptionNodeMarginV, textSize.width, textSize.height)
    }
}
