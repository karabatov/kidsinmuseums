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
    let textParamsInactive = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.kimOrangeColor()]
    let textParamsHighlighted = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.whiteColor()]
    let kMuseumEventButtonNodeMarginV: CGFloat = 8.0
    let kMuseumEventButtonNodeMarginH: CGFloat = 16.0
    var buttonText = ""

    required init(text: String) {
        super.init()

        borderNode.borderColor = UIColor.kimOrangeColor().CGColor
        borderNode.borderWidth = 1.0

        buttonText = text
        textNode.attributedString = NSAttributedString(string: buttonText, attributes: textParamsInactive)

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
    
    override func beginTrackingWithTouch(touch: UITouch!, withEvent touchEvent: UIEvent!) -> Bool {
        updateBackgroundColor()
        return true
    }

    override func cancelTrackingWithEvent(touchEvent: UIEvent!) {
        super.cancelTrackingWithEvent(touchEvent)
        updateBackgroundColor()
    }

    override func endTrackingWithTouch(touch: UITouch!, withEvent touchEvent: UIEvent!) {
        super.endTrackingWithTouch(touch, withEvent: touchEvent)
        updateBackgroundColor()
    }

    func updateBackgroundColor() {
        if highlighted {
            borderNode.backgroundColor = UIColor.kimOrangeColor()
            textNode.attributedString = NSAttributedString(string: buttonText, attributes: textParamsHighlighted)
        } else {
            borderNode.backgroundColor = UIColor.whiteColor()
            textNode.attributedString = NSAttributedString(string: buttonText, attributes: textParamsInactive)
        }
    }
}
