//
//  EventReviewNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 10.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class EventReviewNode: ASCellNode {
    let textNode = ASTextNode()
    let divider = ASDisplayNode()
    let kEventReviewNodeMarginH: CGFloat = 16.0
    let kEventReviewNodeMarginV: CGFloat = 10.0

    required init(review: Review) {
        super.init()

        let divColor = UIColor(red: 200.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        divider.backgroundColor = divColor

        let captionFont = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        let nameFont = UIFont.boldSystemFontOfSize(captionFont.pointSize + 1)
        let mainColor = UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        let nameParams = [NSFontAttributeName: nameFont, NSForegroundColorAttributeName: mainColor]
        let textParams = [NSFontAttributeName: captionFont, NSForegroundColorAttributeName: mainColor]

        var textStr = NSMutableAttributedString()
        if let user = review.user {
            let name = NSAttributedString(string: "\(user.name)\n\n", attributes: nameParams)
            textStr.appendAttributedString(name)
        }
        let text = NSAttributedString(string: review.text, attributes: textParams)
        textStr.appendAttributedString(text)

        textNode.attributedString = textStr

        addSubnode(textNode)
        addSubnode(divider)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let textSize = textNode.measure(CGSizeMake(constrainedSize.width - kEventReviewNodeMarginH * 2, CGFloat.max))
        return CGSizeMake(constrainedSize.width, textSize.height + kEventReviewNodeMarginV * 2)
    }

    override func layout() {
        let textSize = textNode.calculatedSize
        textNode.frame = CGRectMake(kEventReviewNodeMarginH, kEventReviewNodeMarginV, textSize.width, textSize.height)
        let pixelHeight: CGFloat = 1.0 / UIScreen.mainScreen().scale
        divider.frame = CGRectMake(kEventReviewNodeMarginH, calculatedSize.height - pixelHeight, calculatedSize.width - kEventReviewNodeMarginH, pixelHeight)
    }
}
