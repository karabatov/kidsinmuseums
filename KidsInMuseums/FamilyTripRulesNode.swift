//
//  FamilyTripRulesNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 05.08.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

import UIKit

class FamilyTripRulesNode: ASCellNode, UIScrollViewDelegate {
    let marginH: CGFloat = 16.0
    let marginV: CGFloat = 8.0
    let marginPageControl: CGFloat = 32.0
    let tripRules: [FamilyTripRule]
    var titleNodes: [ASTextNode] = []
    var textNodes: [ASTextNode] = []
    let scrollNode = ASScrollNode()
    var pageControl: UIPageControl?

    required init(rules: [FamilyTripRule]) {
        tripRules = rules
        super.init()

        addSubnode(scrollNode)

        let titleParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.kimGrayColor()]
        let textParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.kimGrayColor()]

        for rule in tripRules {
            let titleStr = NSAttributedString(string: rule.title, attributes: titleParams)
            let textStr = NSAttributedString(string: rule.text, attributes: textParams)

            let titleNode = ASTextNode()
            titleNode.attributedString = titleStr
            titleNode.placeholderEnabled = true
            titleNode.placeholderColor = UIColor.whiteColor()
            titleNode.placeholderFadeDuration = 0.25
            scrollNode.addSubnode(titleNode)
            titleNodes.append(titleNode)

            let textNode = ASTextNode()
            textNode.attributedString = textStr
            textNode.placeholderEnabled = true
            textNode.placeholderColor = UIColor.whiteColor()
            textNode.placeholderFadeDuration = 0.25
            scrollNode.addSubnode(textNode)
            textNodes.append(textNode)
        }
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        var maxHeight: CGFloat = 0.0

        for (index, _) in enumerate(tripRules) {
            let titleSize = titleNodes[index].measure(CGSize(width: constrainedSize.width - marginH * 2, height: CGFloat.max))
            let textSize = textNodes[index].measure(CGSize(width: constrainedSize.width - marginH * 2, height: CGFloat.max))
            maxHeight = max(maxHeight, titleSize.height + textSize.height + marginV * 3)
        }

        return CGSize(width: constrainedSize.width, height: maxHeight + marginPageControl)
    }

    override func layout() {
        scrollNode.frame = CGRect(x: 0, y: 0, width: calculatedSize.width, height: calculatedSize.height - marginPageControl)

        for (index, _) in enumerate(tripRules) {
            let offset: CGFloat = calculatedSize.width * CGFloat(index)

            let titleSize = titleNodes[index].calculatedSize
            let textSize = textNodes[index].calculatedSize

            titleNodes[index].frame = CGRect(x: offset + (calculatedSize.width - titleSize.width) / 2.0, y: marginV, width: titleSize.width, height: titleSize.height)
            textNodes[index].frame = CGRect(x: offset + marginH, y: titleSize.height + marginV * 2, width: textSize.width, height: textSize.height)
        }

        scrollNode.view.directionalLockEnabled = true
        scrollNode.view.pagingEnabled = true
        scrollNode.view.showsHorizontalScrollIndicator = false
        scrollNode.view.contentSize = CGSize(width: calculatedSize.width * CGFloat(tripRules.count), height: calculatedSize.height - marginPageControl)
        scrollNode.view.delegate = self

        if pageControl == nil {
            pageControl = UIPageControl()
            view.addSubview(pageControl!)
            pageControl?.numberOfPages = tripRules.count
            pageControl?.currentPage = 0
            pageControl?.pageIndicatorTintColor = UIColor.lightGrayColor()
            pageControl?.currentPageIndicatorTintColor = UIColor.blackColor()
        }

        pageControl?.setNeedsLayout()
        pageControl?.layoutIfNeeded()
        pageControl?.center = CGPoint(x: calculatedSize.width / 2.0, y: calculatedSize.height - marginPageControl / 2.0)
    }

    // UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl?.currentPage = Int(ceil(scrollView.contentOffset.x / scrollView.frame.width))
    }
}
