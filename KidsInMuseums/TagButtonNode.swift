//
//  TagButtonNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 03.04.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class TagButtonNode: ASControlNode {
    let tagStr: String
    let borderNode = ASDisplayNode()
    let textNode = ASTextNode()
    let textParamsNormal = [ NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.kimColor() ]
    let textParamsSelected = [ NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.whiteColor() ]
    let backgroundColorNormal = UIColor.whiteColor()
    let backgroundColorSelected = UIColor.kimColor()
    let marginH: CGFloat = 6.0
    let marginV: CGFloat = 6.0
    var selected: Bool = false {
        didSet {
            updateButtonState()
        }
    }

    required init(tagStr: String) {
        self.tagStr = tagStr
        super.init()

        borderNode.borderColor = UIColor.kimColor().CGColor
        borderNode.backgroundColor = backgroundColorNormal
        borderNode.borderWidth = 1.0

        textNode.attributedString = NSAttributedString(string: tagStr, attributes: textParamsNormal)
        textNode.maximumLineCount = 1
        textNode.truncationMode = NSLineBreakMode.ByTruncatingTail

        addSubnode(borderNode)
        addSubnode(textNode)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let textSize = textNode.measure(CGSizeMake(constrainedSize.width - 4 * marginH, CGFloat.max))

        return CGSizeMake(textSize.width + 4 * marginH, textSize.height + 4 * marginV)
    }

    override func layout() {
        let textSize = textNode.calculatedSize
        let borderSize = CGSizeMake(textSize.width + (calculatedSize.width - textSize.width) / 2.0, textSize.height + 2 * marginV)

        textNode.frame = CGRectMake((calculatedSize.width - textSize.width) / 2.0, 2 * marginV, textSize.width, textSize.height)
        borderNode.frame = CGRectMake((calculatedSize.width - borderSize.width) / 2.0, marginV, borderSize.width, borderSize.height)

        borderNode.cornerRadius = borderSize.height / 2.0
    }

    func updateButtonState() {
        if !selected {
            borderNode.backgroundColor = highlighted ? backgroundColorSelected : backgroundColorNormal
            textNode.attributedString = highlighted ? NSAttributedString(string: tagStr, attributes: textParamsSelected) : NSAttributedString(string: tagStr, attributes: textParamsNormal)
        } else {
            borderNode.backgroundColor = highlighted ? backgroundColorNormal : backgroundColorSelected
            textNode.attributedString = highlighted ? NSAttributedString(string: tagStr, attributes: textParamsNormal) : NSAttributedString(string: tagStr, attributes: textParamsSelected)
        }
    }

    override func beginTrackingWithTouch(touch: UITouch!, withEvent touchEvent: UIEvent!) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: touchEvent)
        updateButtonState()
        return true
    }

    override func cancelTrackingWithEvent(touchEvent: UIEvent!) {
        super.cancelTrackingWithEvent(touchEvent)
        updateButtonState()
    }

    override func endTrackingWithTouch(touch: UITouch!, withEvent touchEvent: UIEvent!) {
        super.endTrackingWithTouch(touch, withEvent: touchEvent)
        updateButtonState()
    }

    override func sendActionsForControlEvents(controlEvents: ASControlNodeEvent, withEvent touchEvent: UIEvent!) {
        if controlEvents == .TouchUpInside {
            selected = !selected
        }
        super.sendActionsForControlEvents(controlEvents, withEvent: touchEvent)
    }
}
