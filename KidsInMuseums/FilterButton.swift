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
    let marginV: CGFloat = 12.0
    let bgColorHighlighted = UIColor.kimOrangeColor()
    let bgColorInactive = UIColor.kimColor()
    var selected: Bool = false {
        didSet {
            updateBackgroundColor()
        }
    }

    required init(text: String) {
        super.init()
        let textParams = [ NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.whiteColor() ]
        textNode.placeholderEnabled = true
        textNode.placeholderFadeDuration = 0.25
        textNode.attributedString = NSAttributedString(string: text, attributes: textParams)
        addSubnode(textNode)
        updateBackgroundColor()
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

    override func sendActionsForControlEvents(controlEvents: ASControlNodeEvent, withEvent touchEvent: UIEvent!) {
        if controlEvents == .TouchUpInside {
            selected = !selected
        }
        super.sendActionsForControlEvents(controlEvents, withEvent: touchEvent)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let textSize = textNode.measure(CGSizeMake(constrainedSize.width - 2 * marginH, CGFloat.max))
        return CGSizeMake(constrainedSize.width, textSize.height + 2 * marginV)
    }

    override func layout() {
        let textSize = textNode.calculatedSize
        textNode.frame = CGRectMake((calculatedSize.width - textSize.width) / 2.0, marginV, textSize.width, textSize.height)
    }

    func updateBackgroundColor() {
        if !selected {
            backgroundColor = highlighted ? bgColorHighlighted : bgColorInactive
        } else {
            backgroundColor = highlighted ? bgColorInactive : bgColorHighlighted
        }
        textNode.placeholderColor = backgroundColor
    }
}
