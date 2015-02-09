//
//  EventMuseumNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 09.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class EventMuseumNode: ASCellNode {
    var museumFound = false
    let pinNode = ASTextNode()
    let textNode = ASTextNode()
    let kEventMuseumNodeMarginH: CGFloat = 16.0
    let kEventMuseumNodeMarginV: CGFloat = 6.0
    let kEventMuseumNodePinFontSize: CGFloat = 12.0

    required init(museumId: Int) {
        if let mus = DataModel.sharedInstance.findMuseum(museumId) {
            museumFound = true

            let pin = FAKFontAwesome.mapMarkerIconWithSize(kEventMuseumNodePinFontSize)
            pin.addAttribute(NSForegroundColorAttributeName, value: UIColor.kimColor())
            pinNode.attributedString = pin.attributedString()

            let nameParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.kimColor()]
            let addressParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.blackColor()]
            let titleStr = NSMutableAttributedString(string: mus.name, attributes: nameParams)
            if mus.address != "" {
                let addrStr = NSAttributedString(string: "\n\(mus.address)", attributes: addressParams)
                titleStr.appendAttributedString(addrStr)
            }
            textNode.attributedString = titleStr
        }

        super.init()

        if museumFound {
            addSubnode(pinNode)
            addSubnode(textNode)
        }
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        if museumFound {
            let pinSize = pinNode.measure(CGSizeMake(constrainedSize.width, CGFloat.max))
            let textSize = textNode.measure(CGSizeMake(constrainedSize.width - kEventMuseumNodeMarginH * 3, CGFloat.max))
            return CGSizeMake(constrainedSize.width, max(pinSize.height + kEventMuseumNodeMarginV * 2, textSize.height + kEventMuseumNodeMarginV * 2))
        } else {
            return CGSizeZero
        }
    }

    override func layout() {
        if museumFound {
            let pinSize = pinNode.calculatedSize
            let textSize = textNode.calculatedSize
            pinNode.frame = CGRectMake(kEventMuseumNodeMarginH, kEventMuseumNodeMarginV, pinSize.width, pinSize.height)
            textNode.frame = CGRectMake(kEventMuseumNodeMarginH * 2, kEventMuseumNodeMarginV, textSize.width, textSize.height)
        }
    }
}
