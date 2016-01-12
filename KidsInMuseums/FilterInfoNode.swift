//
//  FilterInfoNode.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 12.04.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class FilterInfoNode: ASDisplayNode {
    let textNode = ASTextNode()
    let font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
    let plainParams: [String: AnyObject]
    let boldParams: [String: AnyObject]
    let marginH: CGFloat = 16.0
    let marginV: CGFloat = 8.0
    var filter: Filter {
        didSet {
            var filterArr = [String]()
            if !filter.isEmpty() {
                if !filter.museums.isEmpty {
                    filterArr.append(NSLocalizedString("museums", comment: "Museums filter text"))
                }
                if !filter.ageRanges.isEmpty {
                    filterArr.append(NSLocalizedString("ages", comment: "Ages filter text"))
                }
                if !filter.tags.isEmpty {
                    filterArr.append(NSLocalizedString("tags", comment: "Tags filter text"))
                }
                if !filter.days.isEmpty {
                    filterArr.append(NSLocalizedString("dates", comment: "Dates filter text"))
                }
            }
            let titleStart = NSLocalizedString("Filter applied: ", comment: "Filter node beginning text")
            let titleStr = NSMutableAttributedString(string: titleStart, attributes: plainParams)
            var filterStr = ""
            for (index, value) in filterArr.enumerate() {
                if index != 0 {
                    filterStr += ", "
                }
                filterStr += value
            }
            titleStr.appendAttributedString(NSAttributedString(string: filterStr, attributes: boldParams))
            textNode.attributedString = titleStr
            textNode.placeholderEnabled = true
            textNode.placeholderColor = UIColor.kimOrangeColor()
            textNode.placeholderFadeDuration = 0.25
            invalidateCalculatedSize()
        }
    }

    required init(filter: Filter) {
        plainParams = [ NSFontAttributeName: UIFont.systemFontOfSize(font.pointSize), NSForegroundColorAttributeName: UIColor.whiteColor() ]
        boldParams = [ NSFontAttributeName: UIFont.boldSystemFontOfSize(font.pointSize), NSForegroundColorAttributeName: UIColor.whiteColor() ]
        self.filter = filter
        super.init()

        backgroundColor = UIColor.kimOrangeColor()

        addSubnode(textNode)
    }

    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let textSize = textNode.measure(CGSizeMake(constrainedSize.width - marginH * 2.0, CGFloat.max))
        return CGSizeMake(constrainedSize.width, textSize.height + marginV * 2.0)
    }

    override func layout() {
        let textSize = textNode.calculatedSize
        textNode.frame = CGRectMake(marginH, marginV, textSize.width, textSize.height)
    }
}
