//
//  PhoneDividerNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 20.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class PhoneDividerNode: TextDividerNode {
    let phoneButton = ASImageNode()

    required init(attributedText: NSAttributedString) {
        super.init(attributedText: attributedText)

        phoneButton.image = UIImage(named: "icon-phone")
        phoneButton.contentMode = UIViewContentMode.Center
        addSubnode(phoneButton)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let phoneSize = phoneButton.image.size
        let textSize = textView.measure(CGSizeMake(constrainedSize.width - kTextDividerNodeMarginH * 3 - phoneSize.width, CGFloat.max))
        return CGSizeMake(constrainedSize.width, max(textSize.height, phoneSize.height) + kTextDividerNodeMarginV * 2)
    }

    override func layout() {
        let textSize = textView.calculatedSize
        let phoneSize = phoneButton.image.size
        textView.frame = CGRectMake(kTextDividerNodeMarginH, (calculatedSize.height - textSize.height) / 2, textSize.width, textSize.height)
        phoneButton.frame = CGRectMake(calculatedSize.width - phoneSize.width - kTextDividerNodeMarginH, (calculatedSize.height - phoneSize.height) / 2, phoneSize.width, phoneSize.height)

        let pixelSize: CGFloat = 1.0 / UIScreen.mainScreen().scale
        divider.frame = CGRectMake(0, calculatedSize.height - pixelSize, calculatedSize.width, pixelSize)
    }
}
