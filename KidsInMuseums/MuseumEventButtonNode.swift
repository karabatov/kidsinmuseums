//
//  MuseumEventButtonNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 04.03.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class MuseumEventButtonNode: ASControlNode {
    let borderNode = ASDisplayNode()
    let textNode = ASTextNode()
    let textParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.kimOrangeColor()]
    let kMuseumEventButtonNodeMarginV: CGFloat = 8.0
    let kMuseumEventButtonNodeMarginH: CGFloat = 16.0

    required init(text: String) {
        super.init()

        borderNode.borderColor = UIColor.kimOrangeColor().CGColor
        borderNode.borderWidth = 1.0

        textNode.attributedString = NSAttributedString(string: text, attributes: textParams)

        self.addSubnode(borderNode)
        self.addSubnode(textNode)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let textSize = textNode.measure(CGSizeMake(constrainedSize.width - 2 * kMuseumEventButtonNodeMarginH, CGFloat.max))

        return CGSizeMake(constrainedSize.width, textSize.height + 4 * kMuseumEventButtonNodeMarginV)
    }

    override func layout() {
        let textSize = textNode.calculatedSize
        let borderSize = CGSizeMake(textSize.width + (calculatedSize.width - textSize.width) / 2.0, textSize.height + 2 * kMuseumEventButtonNodeMarginV)

        textNode.frame = CGRectMake((calculatedSize.width - textSize.width) / 2.0, 2 * kMuseumEventButtonNodeMarginV, textSize.width, textSize.height)
        borderNode.frame = CGRectMake((calculatedSize.width - borderSize.width) / 2.0, kMuseumEventButtonNodeMarginV, borderSize.width, borderSize.height)

        borderNode.cornerRadius = borderSize.height / 2.0
    }
}
