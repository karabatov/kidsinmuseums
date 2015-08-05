//
//  FamilyTripNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 05.08.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import UIKit

class FamilyTripNode: ASCellNode, ASMultiplexImageNodeDataSource {
    let marginH: CGFloat = 16.0
    let marginV: CGFloat = 6.0
    let imageWidth: CGFloat = 120.0
    let minimumHeight: CGFloat = 64.0
    let textNode = ASTextNode()
    let imageNode: ASMultiplexImageNode
    let divider = ASDisplayNode()

    required init(title: String, ageFrom: Int, ageTo: Int, image: KImage?) {
        var images = [String]()
        if let imageUrl = image?.url {
            images.append(imageUrl)
        }
        if let thumbURL = image?.thumb?.url {
            images.append(thumbURL)
        }
        if let thumb2URL = image?.thumb2?.url {
            images.append(thumb2URL)
        }

        imageNode = ASMultiplexImageNode(cache: SDWebASDKImageManager.sharedManager(), downloader: SDWebASDKImageManager.sharedManager())
        imageNode.backgroundColor = UIColor(white: 0.1, alpha: 0.1)
        imageNode.contentMode = UIViewContentMode.ScaleAspectFill

        super.init()

        let headingParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), NSForegroundColorAttributeName: UIColor.blackColor()]
        var titleStr = NSMutableAttributedString(string: "\(title)   ", attributes: headingParams)
        let attachment = NSTextAttachment()
        attachment.image = attachmentImageForAge(from: ageFrom, to: ageTo)
        let attStr = NSAttributedString(attachment: attachment)
        titleStr.appendAttributedString(attStr)

        textNode.attributedString = titleStr
        textNode.placeholderEnabled = true
        textNode.placeholderColor = UIColor.whiteColor()
        textNode.placeholderFadeDuration = 0.25

        addSubnode(textNode)

        imageNode.dataSource = self
        imageNode.imageIdentifiers = nil
        imageNode.imageIdentifiers = images

        addSubnode(imageNode)

        imageNode.placeholderEnabled = true
        imageNode.placeholderFadeDuration = 0.25
        imageNode.placeholderColor = imageNode.backgroundColor

        divider.backgroundColor = UIColor.lightGrayColor()
        addSubnode(divider)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let textSize = textNode.measure(CGSizeMake(constrainedSize.width - marginH * 2 - imageWidth, CGFloat.max))
        return CGSizeMake(constrainedSize.width, max(minimumHeight, textSize.height + marginV * 2))
    }

    override func layout() {
        let textSize = textNode.calculatedSize
        textNode.frame = CGRectMake(imageWidth + marginH, marginV, textSize.width, textSize.height)
        imageNode.frame = CGRect(x: 0.0, y: 0.0, width: imageWidth, height: calculatedSize.height)
        let pixelHeight: CGFloat = 1.0 / UIScreen.mainScreen().scale
        divider.frame = CGRectMake(0.0, 0.0, calculatedSize.width, pixelHeight)
    }

    // MARK: ASMultiplexImageNodeDataSource

    func multiplexImageNode(imageNode: ASMultiplexImageNode!, URLForImageIdentifier imageIdentifier: AnyObject!) -> NSURL! {
        return NSURL(string: imageIdentifier as! String)
    }
}
