//
//  MuseumInfoView.swift
//  KidsInMuseums
//
//  Created by Yuri Karabatov on 20.02.15.
//  Copyright (c) 2015 Golova Media. All rights reserved.
//

class MuseumInfoView: UIScrollView {

    required init(museum: Museum, maxWidth: CGFloat) {
        super.init(frame: CGRectZero)

        let zeroHeightSize = CGSizeMake(maxWidth, 0)
        var height: CGFloat = 0.0

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
            let addrTitleParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0)]
            let addrParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.kimColor()]
            let directionsParams = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName: UIColor.blackColor()]

            var addressStr = NSMutableAttributedString()

            let addrTitleStr = NSAttributedString(string: NSLocalizedString("Address: ", comment: "Address, museum info card"), attributes: addrTitleParams)
            addressStr.appendAttributedString(addrTitleStr)

            let addrAddressStr = NSAttributedString(string: museum.address, attributes: addrParams)
            addressStr.appendAttributedString(addrAddressStr)

            if !museum.directions.isEmpty {
                let dirStr = NSAttributedString(string: "\n\(museum.directions)", attributes: directionsParams)
                addressStr.appendAttributedString(dirStr)
            }

            let addrNode = TextDividerNode(attributedText: addressStr)
            let addrSize = addrNode.measure(zeroHeightSize)

            addrNode.frame = CGRectMake(0, height, maxWidth, addrSize.height)
            self.addSubview(addrNode.view)

            height += addrSize.height
        }

        self.frame = CGRectMake(0, 0, maxWidth, height)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
