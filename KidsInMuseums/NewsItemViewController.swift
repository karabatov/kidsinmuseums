//
//  NewsItemViewController.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 24.12.14.
//  Copyright (c) 2014 Golova Media. All rights reserved.
//

import Foundation

public class NewsItemViewController: UIViewController, ASMultiplexImageNodeDataSource, ASMultiplexImageNodeDelegate {
    var newsItem: NewsItem
    var scrollView: ASScrollNode
    var dateLabel: ASTextNode
    var newsImage: ASMultiplexImageNode
    var newsText: ASTextNode
    var images = NSMutableArray()

    required public init(newsItem: NewsItem, frame b: CGRect) {
        self.newsItem = newsItem

        scrollView = ASScrollNode()
        scrollView.backgroundColor = UIColor.whiteColor()

        dateLabel = ASTextNode()
        newsImage = ASMultiplexImageNode(cache: nil, downloader: ASBasicImageDownloader())
        newsText = ASTextNode()

        scrollView.addSubnode(dateLabel)
        scrollView.addSubnode(newsImage)
        scrollView.addSubnode(newsText)

        super.init(nibName: nil, bundle: nil)

        newsImage.dataSource = self
        newsImage.delegate = self

        self.edgesForExtendedLayout = UIRectEdge.None
        self.view.backgroundColor = UIColor.whiteColor()

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var contentHeight: CGFloat = 0.0
            let kMargin: CGFloat = 15.0
            let kRatio: CGFloat = 2.33
            let dateParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0)]
            let headingParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline), NSForegroundColorAttributeName: UIColor.blackColor()]
            let descriptionParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), NSForegroundColorAttributeName: UIColor(red: 71.0/255.0, green: 71.0/255.0, blue: 71.0/255.0, alpha: 1.0)]

            self.scrollView.frame = b

            let dateText = NSAttributedString(string: newsItem.formattedDate(), attributes: dateParams)
            self.dateLabel.attributedString = dateText
            let dateSize = self.dateLabel.measure(CGSizeMake(b.width - 2 * kMargin, CGFloat.max))
            self.dateLabel.frame = CGRectMake(kMargin, kMargin, dateSize.width, dateSize.height)

            if let hugeURL = newsItem.image?.url {
                self.images.addObject(hugeURL)
            }
            if let bigURL = newsItem.image?.big?.url {
                self.images.addObject(bigURL)
            }
            if let thumbURL = newsItem.image?.thumb?.url {
                self.images.addObject(thumbURL)
            }
            self.newsImage.backgroundColor = UIColor(white: 0.1, alpha: 0.1)
            self.newsImage.contentMode = UIViewContentMode.ScaleAspectFill
            self.newsImage.imageIdentifiers = nil
            self.newsImage.imageIdentifiers = self.images
            self.newsImage.frame = CGRectMake(kMargin, self.dateLabel.frame.origin.y + self.dateLabel.frame.height + kMargin, b.width - 2 * kMargin, round((b.width - 2 * kMargin) / kRatio))

            var newsActualText = NSMutableAttributedString()
            let header = NSAttributedString(string: "\n" + self.newsItem.title + "\n\n", attributes: headingParams)
            let text = NSAttributedString(string: self.newsItem.text, attributes: descriptionParams)
            newsActualText.appendAttributedString(header)
            newsActualText.appendAttributedString(text)
            self.newsText.attributedString = newsActualText
            let textSize = self.newsText.measure(CGSizeMake(b.width - 2 * kMargin, CGFloat.max))
            self.newsText.frame = CGRectMake(kMargin, self.newsImage.frame.origin.y + self.newsImage.frame.height, textSize.width, textSize.height)

            dispatch_async(dispatch_get_main_queue(), {
                self.view.addSubview(self.scrollView.view)
                let scroll = self.scrollView.view as UIScrollView
                scroll.contentSize = CGSizeMake(b.width, self.newsText.frame.origin.y + textSize.height + kMargin)
            })
        })
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("CRASH ALL THE THINGS")
    }

    public func multiplexImageNode(imageNode: ASMultiplexImageNode!, URLForImageIdentifier imageIdentifier: AnyObject!) -> NSURL! {
        return NSURL(string: imageIdentifier as String)
    }
}