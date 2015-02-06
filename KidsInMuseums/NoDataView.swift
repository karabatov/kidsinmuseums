//
//  NoDataView.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 23.12.14.
//  Copyright (c) 2014 Golova Media. All rights reserved.
//

import Foundation

let kNoDataViewMarginX: CGFloat = 45.0
let kNoDataViewMarginY: CGFloat = 100.0

public class NoDataView: ASDisplayNode {
    var textMessage: ASTextNode

    required public override init() {
        textMessage = ASTextNode()
        textMessage.layerBacked = true
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .Center
        let attributes = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSParagraphStyleAttributeName : paragraph]
        textMessage.attributedString = NSAttributedString(string: NSLocalizedString("No data is currently available. Please pull down to refresh.", comment: "Message when there is no data in the news table view"), attributes: attributes)
        super.init()
        self.backgroundColor = UIColor.whiteColor()
        self.addSubnode(textMessage)
        self.shouldRasterizeDescendants = true
    }

    public override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let cSize = CGSizeMake(constrainedSize.width - 2 * kNoDataViewMarginX, CGFloat.max)
        let textSize: CGSize = textMessage.measure(cSize)
        return CGSizeMake(constrainedSize.width, textSize.height + 2 * kNoDataViewMarginX)
    }

    public override func layout() {
        let textSize = textMessage.calculatedSize
        textMessage.frame = CGRectMake(kNoDataViewMarginX, kNoDataViewMarginY, textSize.width, textSize.height)
    }
}
