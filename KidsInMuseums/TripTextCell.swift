//
//  TripDateCell.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 28.07.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import UIKit

class TripTextCell: ASCellNode {
    let marginH: CGFloat = 16.0
    let marginV: CGFloat = 6.0
    let textNode = ASTextNode()

    required init(text: NSAttributedString) {
        super.init()

        textNode.attributedString = text
        textNode.placeholderEnabled = true
        textNode.placeholderColor = UIColor.whiteColor()
        textNode.placeholderFadeDuration = 0.25

        addSubnode(textNode)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let textSize = textNode.measure(CGSizeMake(constrainedSize.width - marginH * 2, CGFloat.max))
        return CGSizeMake(constrainedSize.width, textSize.height + marginV * 2)
    }

    override func layout() {
        let textSize = textNode.calculatedSize
        textNode.frame = CGRectMake(marginH, marginV, textSize.width, textSize.height)
    }
}
