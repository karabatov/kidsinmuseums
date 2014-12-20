//
//  NewsListCell.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 20.12.14.
//  Copyright (c) 2014 Golova Media. All rights reserved.
//

import Foundation
import UIKit

public class NewsListCell : UITableViewCell {
    public class var sharedCell : NewsListCell {
        struct Static {
            static let instance : NewsListCell = NewsListCell(style: UITableViewCellStyle.Default, reuseIdentifier: NewsListCell.reuseIdentifier())
        }
        return Static.instance
    }
    private var label: UILabel

    required public init(coder: NSCoder) {
        self.label = UILabel(coder: coder)
        super.init(coder: coder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.label = UILabel()
        self.label.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.label.numberOfLines = 0
        self.label.lineBreakMode = .ByWordWrapping
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.label)
        let views: [NSObject: AnyObject] = ["label": self.label]
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[label]-15-|", options: .allZeros, metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[label]-15-|", options: .allZeros, metrics: nil, views: views))

    }

    public func configureWithNewsItem(newsItem: NewsItem) {
        let dateParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), NSForegroundColorAttributeName: UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0)]
        let headingParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.blackColor()]
        let descriptionParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor(red: 71.0/255.0, green: 71.0/255.0, blue: 71.0/255.0, alpha: 1.0)]
        var df = NSDateFormatter()
        df.dateStyle = NSDateFormatterStyle.LongStyle
        df.timeStyle = NSDateFormatterStyle.NoStyle

        var labelStr = NSMutableAttributedString()
        let dateStr = NSAttributedString(string: df.stringFromDate(newsItem.updatedAt) + "\n", attributes: dateParams)
        let titleStr = NSAttributedString(string: newsItem.title, attributes: headingParams)
        let descriptionStr = NSAttributedString(string: "\n" + newsItem.description, attributes: descriptionParams)
        labelStr.appendAttributedString(dateStr)
        labelStr.appendAttributedString(titleStr)
        labelStr.appendAttributedString(descriptionStr)
        self.label.attributedText = labelStr
    }

    public func heightForCellWithNewsItem(newsItem: NewsItem) -> CGFloat {
        self.configureWithNewsItem(newsItem)
        return self.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
    }

    public class func reuseIdentifier() -> String {
        return "NewsListCell"
    }
}