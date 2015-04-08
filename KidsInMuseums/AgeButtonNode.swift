//
//  AgeButtonNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 08.04.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class AgeButtonNode: ASControlNode {
    let ageRange: AgeRange
    private let ageStr: String
    let borderNode = ASDisplayNode()
    let textNode = ASTextNode()
    let textParamsNormal = [ NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.kimColor() ]
    let textParamsSelected = [ NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.whiteColor() ]
    let backgroundColorNormal = UIColor.whiteColor()
    let backgroundColorSelected = UIColor.kimColor()
    let marginH: CGFloat = 4.0
    let marginV: CGFloat = 4.0
    let circleRadius: CGFloat = 30.0
    var selected: Bool = false {
        didSet {
            updateButtonState()
        }
    }

    required init(ageRange: AgeRange) {
        self.ageRange = ageRange
        if self.ageRange.to > 100 {
            ageStr = "\(self.ageRange.from)+"
        } else {
            ageStr = "\(self.ageRange.from) – \(self.ageRange.to)"
        }
        super.init()

        borderNode.borderColor = UIColor.kimColor().CGColor
        borderNode.backgroundColor = backgroundColorNormal
        borderNode.borderWidth = 1.0
        borderNode.cornerRadius = circleRadius

        textNode.attributedString = NSAttributedString(string: ageStr, attributes: textParamsNormal)

        addSubnode(borderNode)
        addSubnode(textNode)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let textSize = textNode.measure(CGSizeMake(circleRadius * 2.0, CGFloat.max))

        return CGSizeMake(circleRadius * 2.0 + marginH * 2.0, circleRadius * 2.0 + marginV * 2.0)
    }

    override func layout() {
        let textSize = textNode.calculatedSize
        let borderSize = CGSizeMake(circleRadius * 2.0, circleRadius * 2.0)

        textNode.frame = CGRectMake((calculatedSize.width - textSize.width) / 2.0, (calculatedSize.height - textSize.height) / 2.0, textSize.width, textSize.height)
        borderNode.frame = CGRectMake(marginH, marginV, circleRadius * 2.0, circleRadius * 2.0)

    }

    func updateButtonState() {
        if !selected {
            borderNode.backgroundColor = highlighted ? backgroundColorSelected : backgroundColorNormal
            textNode.attributedString = highlighted ? NSAttributedString(string: ageStr, attributes: textParamsSelected) : NSAttributedString(string: ageStr, attributes: textParamsNormal)
        } else {
            borderNode.backgroundColor = highlighted ? backgroundColorNormal : backgroundColorSelected
            textNode.attributedString = highlighted ? NSAttributedString(string: ageStr, attributes: textParamsNormal) : NSAttributedString(string: ageStr, attributes: textParamsSelected)
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
