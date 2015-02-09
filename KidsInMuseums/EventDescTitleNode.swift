//
//  EventDescTitleNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 09.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class EventDescTitleNode: ASCellNode {
    let textNode = ASTextNode()
    let dividerTop = ASDisplayNode()
    let dividerBottom = ASDisplayNode()
    let kEventDescTitleNodeMarginH: CGFloat = 16.0
    let kEventDescTitleNodeMarginV: CGFloat = 6.0

    required override init() {
        let textParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote), NSForegroundColorAttributeName: UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)]
        let dividerColor = UIColor(red: 200.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        let bgColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)

        let textStr = NSAttributedString(string: NSLocalizedString("Description", comment: "Event screen description subtitle"), attributes: textParams)
        textNode.attributedString = textStr

        dividerTop.backgroundColor = dividerColor
        dividerBottom.backgroundColor = dividerColor

        super.init()

        self.backgroundColor = bgColor
        addSubnode(dividerTop)
        addSubnode(dividerBottom)
        addSubnode(textNode)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let textSize = textNode.measure(CGSizeMake(constrainedSize.width - kEventDescTitleNodeMarginH * 2, CGFloat.max))
        return CGSizeMake(constrainedSize.width, textSize.height + kEventDescTitleNodeMarginV * 2)
    }

    override func layout() {
        let pixelHeight: CGFloat = 1.0 / UIScreen.mainScreen().scale
        dividerTop.frame = CGRectMake(0, 0, calculatedSize.width, pixelHeight)
        dividerBottom.frame = CGRectMake(0, calculatedSize.height - pixelHeight, calculatedSize.width, pixelHeight)
        let textSize = textNode.calculatedSize
        textNode.frame = CGRectMake(kEventDescTitleNodeMarginH, kEventDescTitleNodeMarginV, textSize.width, textSize.height)
    }
}
