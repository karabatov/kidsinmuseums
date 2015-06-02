//
//  MuseumTitleView.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 20.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class TextDividerNode: ASDisplayNode, ASTextNodeDelegate {
    let textView = ASTextNode()
    let divider = ASDisplayNode()
    let kTextDividerNodeMarginV: CGFloat = 8.0
    let kTextDividerNodeMarginH: CGFloat = 10.0

    required init(attributedText: NSAttributedString) {
        super.init()

        let divColor = UIColor(red: 200.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        divider.backgroundColor = divColor

        textView.attributedString = attributedText
        textView.delegate = self
        textView.linkAttributeNames = [ NSLinkAttributeName ]
        textView.userInteractionEnabled = true

        addSubnode(textView)
        addSubnode(divider)
    }

    func showDivider(shouldHide: Bool) {
        divider.hidden = shouldHide
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let textSize = textView.measure(CGSizeMake(constrainedSize.width - kTextDividerNodeMarginH * 2, CGFloat.max))
        return CGSizeMake(constrainedSize.width, textSize.height + kTextDividerNodeMarginV * 2)
    }

    override func layout() {
        let textSize = textView.calculatedSize
        textView.frame = CGRectMake(kTextDividerNodeMarginH, kTextDividerNodeMarginV, textSize.width, textSize.height)

        let pixelSize: CGFloat = 1.0 / UIScreen.mainScreen().scale
        divider.frame = CGRectMake(0, calculatedSize.height - pixelSize, calculatedSize.width, pixelSize)
    }

    // MARK: ASTextNodeDelegate

    func textNode(textNode: ASTextNode!, tappedLinkAttribute attribute: String!, value: AnyObject!, atPoint point: CGPoint, textRange: NSRange) {
        if let
            text = value as? String,
            url = NSURL(string: text)
            where attribute == NSLinkAttributeName
        {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    func textNode(textNode: ASTextNode!, shouldHighlightLinkAttribute attribute: String!, value: AnyObject!, atPoint point: CGPoint) -> Bool {
        if attribute == NSLinkAttributeName {
            return true
        }
        return false
    }
}
