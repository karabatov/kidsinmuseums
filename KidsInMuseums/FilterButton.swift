//
//  FilterButton.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 07.04.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class FilterButton: ASControlNode {
    let textNode = ASTextNode()
    let marginH: CGFloat = 16.0
    let marginV: CGFloat = 8.0
    let bgColorEnabled = UIColor.kimOrangeColor()
    let bgColorDisabled = UIColor.kimColor()

    required init(text: String) {
        super.init()
        let textParams = [ NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.whiteColor() ]
        textNode.attributedString = NSAttributedString(string: text, attributes: textParams)
        addSubnode(textNode)

        backgroundColor = bgColorDisabled
    }

    override func beginTrackingWithTouch(touch: UITouch!, withEvent touchEvent: UIEvent!) -> Bool {
        NSLog("begin tracking")
        return true
    }

    override func endTrackingWithTouch(touch: UITouch!, withEvent touchEvent: UIEvent!) {
        NSLog("end tracking")
        super.endTrackingWithTouch(touch, withEvent: touchEvent)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let textSize = textNode.measure(CGSizeMake(constrainedSize.width - 2 * marginH, CGFloat.max))
        return CGSizeMake(constrainedSize.width, textSize.height + 2 * marginV)
    }

    override func layout() {
        let textSize = textNode.calculatedSize
        textNode.frame = CGRectMake((calculatedSize.width - textSize.width) / 2.0, marginV, textSize.width, textSize.height)
    }
}
