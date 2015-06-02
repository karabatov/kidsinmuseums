//
//  MuseumInfoView.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 20.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class MuseumInfoView: UIScrollView {
    let ownMuseum: Museum

    required init(museum: Museum, maxWidth: CGFloat) {
        ownMuseum = museum
        super.init(frame: CGRectZero)

        let zeroHeightSize = CGSizeMake(maxWidth, 0)
        var height: CGFloat = 0.0

        let greyTextParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0)]
        let purpleTextParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.kimColor()]
        let blackTextParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.blackColor()]

        if !museum.name.isEmpty {
            let titleParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), NSForegroundColorAttributeName: UIColor.blackColor()]
            let titleStr = NSAttributedString(string: museum.name, attributes: titleParams)
            let museumTitleView = TextDividerNode(attributedText: titleStr)
            let titleSize = museumTitleView.measure(zeroHeightSize)

            museumTitleView.frame = CGRectMake(0, height, maxWidth, titleSize.height)
            self.addSubview(museumTitleView.view)

            height += titleSize.height
        }

        if !museum.address.isEmpty {
            var addressStr = NSMutableAttributedString()

            let addrTitleStr = NSAttributedString(string: NSLocalizedString("Address: ", comment: "Address, museum info card"), attributes: greyTextParams)
            addressStr.appendAttributedString(addrTitleStr)

            let addrAddressStr = NSAttributedString(string: museum.address, attributes: purpleTextParams)
            addressStr.appendAttributedString(addrAddressStr)

            if !museum.directions.isEmpty {
                let dirStr = NSAttributedString(string: "\n\(museum.directions)", attributes: blackTextParams)
                addressStr.appendAttributedString(dirStr)
            }

            let addrNode = TextDividerNode(attributedText: addressStr)
            let addrSize = addrNode.measure(zeroHeightSize)

            addrNode.frame = CGRectMake(0, height, maxWidth, addrSize.height)
            self.addSubview(addrNode.view)

            height += addrSize.height
        }

        if !museum.phone.isEmpty {
            var phoneStr = NSMutableAttributedString()

            let phoneTitleStr = NSAttributedString(string: NSLocalizedString("Phone: ", comment: "Phone, museum info card"), attributes: greyTextParams)
            phoneStr.appendAttributedString(phoneTitleStr)

            let phoneTextStr = NSAttributedString(string: museum.phone, attributes: blackTextParams)
            phoneStr.appendAttributedString(phoneTextStr)

            let phoneNode = PhoneDividerNode(attributedText: phoneStr)
            let phoneSize = phoneNode.measure(zeroHeightSize)

            phoneNode.frame = CGRectMake(0, height, maxWidth, phoneSize.height)
            self.addSubview(phoneNode.view)

            height += phoneSize.height
        }

        if !museum.email.isEmpty {
            let emailStr = NSMutableAttributedString()

            let emailTitleStr = NSAttributedString(string: NSLocalizedString("Email: ", comment: "Email, museum info card"), attributes: greyTextParams)
            emailStr.appendAttributedString(emailTitleStr)

            let emailTextStr = NSMutableAttributedString(string: museum.email, attributes: blackTextParams)
            emailTextStr.addAttribute(NSLinkAttributeName, value: "mailto:\(museum.email)", range: NSMakeRange(0, emailTextStr.length))
            emailStr.appendAttributedString(emailTextStr)

            let emailNode = TextDividerNode(attributedText: emailStr)
            let emailSize = emailNode.measure(zeroHeightSize)

            emailNode.frame = CGRectMake(0, height, maxWidth, emailSize.height)
            self.addSubview(emailNode.view)
            
            height += emailSize.height
        }

        if !museum.site.isEmpty {
            let siteStr = NSMutableAttributedString()

            let siteTitleStr = NSAttributedString(string: NSLocalizedString("Website: ", comment: "Website, museum info card"), attributes: greyTextParams)
            siteStr.appendAttributedString(siteTitleStr)

            let siteTextStr = NSMutableAttributedString(string: museum.site, attributes: blackTextParams)
            siteTextStr.addAttribute(NSLinkAttributeName, value: museum.site, range: NSMakeRange(0, siteTextStr.length))
            siteStr.appendAttributedString(siteTextStr)

            let siteNode = TextDividerNode(attributedText: siteStr)
            let siteSize = siteNode.measure(zeroHeightSize)

            siteNode.frame = CGRectMake(0, height, maxWidth, siteSize.height)
            self.addSubview(siteNode.view)
            
            height += siteSize.height
        }

        let openEventsStr = NSLocalizedString("Events in this museum", comment: "Events in this museum button in map callout")
        let openEventNode = MuseumEventButtonNode(text: openEventsStr)
        openEventNode.addTarget(self, action: "eventsInMuseumButtonTapped", forControlEvents: ASControlNodeEvent.TouchUpInside)
        let openEventSize = openEventNode.measure(zeroHeightSize)

        openEventNode.frame = CGRectMake(0, height, maxWidth, openEventSize.height)
        self.addSubview(openEventNode.view)

        height += openEventSize.height

        self.frame = CGRectMake(0, 0, maxWidth, height)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func eventsInMuseumButtonTapped() {
        DataModel.sharedInstance.filter = Filter(ageRanges: [AgeRange](), tags: [String](), museums: [ownMuseum.id], days: [NSDate]())
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if let
                mapNav = delegate.tabController?.selectedViewController as? UINavigationController,
                map = mapNav.topViewController as? MapViewController
            {
                map.calloutView.dismissCalloutAnimated(false)
            }
            delegate.tabController?.selectedIndex = 0
        }
    }
}
